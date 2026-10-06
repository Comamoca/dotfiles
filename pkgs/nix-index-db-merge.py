#!/usr/bin/env python3
"""Append a locally built package to a prebuilt nix-index database.

nix-index のデータベースファイルは次の形式:

    b"NIXI" | u64le(format_version) | zstd frame | zstd frame | ...

各フレームは frcode で符号化されたパッケージブロックの列で、1 ブロックは
``<meta>\\0<path>\\n`` のエントリ列と、その末尾に置かれる
``p\\0<StorePath の JSON>\\n`` のフッターからなる。
フッターを書くとデコーダの共有プレフィックス状態が 0 に戻るため、
独立したフレームを既存 DB の末尾に連結するだけでパッケージを追加できる。

nix-index-database のプリビルド DB は Hydra がビルドした (= cache.nixos.org に
存在する) パッケージしか含まない。Hydra 未ビルドのパッケージを comma から
実行できるようにするため、ローカルでビルドした出力のエントリを追記する。
"""

import argparse
import json
import os
import stat
import subprocess
import sys

# nix-index の frcode エンコーダと同じ上限 (src/frcode.rs)。
MAX_SHARED = 32767


def encode_diff(diff):
    """共有プレフィックス長の差分を可変長で符号化する。"""
    if abs(diff) < 127:
        return bytes([diff & 0xFF])
    return bytes([0x80, (diff >> 8) & 0xFF, diff & 0xFF])


class FrcodeWriter:
    """nix-index の frcode エンコーダ (1 パッケージ分)。"""

    def __init__(self, footer_meta, footer_path):
        self._out = bytearray()
        self._last = b""
        self._shared = 0
        self._footer_meta = footer_meta
        self._footer_path = footer_path

    def entry(self, meta, path):
        self._out += meta
        self._out += b"\0"

        shared = 0
        for a, b in zip(self._last, path):
            if a != b or shared > MAX_SHARED:
                break
            shared += 1

        self._out += encode_diff(shared - self._shared)
        self._out += path[shared:]
        self._out += b"\n"

        self._last = path
        self._shared = shared

    def finish(self):
        # フッターで共有プレフィックス長を 0 に戻す。次のフレームの先頭が
        # この状態を前提にしているため必須。
        self._out += self._footer_meta
        self._out += b"\0"
        self._out += encode_diff(-self._shared)
        self._out += self._footer_path
        self._out += b"\n"
        return bytes(self._out)


def walk(root):
    """(path, meta) を FileTree::to_list と同じ順 (LIFO な DFS) で列挙する。

    path はストアパスからの相対パスで、先頭に "/" が付く (ルートは "")。
    meta は files.rs の FileNode::encode と同じ形式。
    """
    stack = [("", root)]
    while stack:
        path, fs_path = stack.pop()
        st = os.lstat(fs_path)
        if stat.S_ISDIR(st.st_mode):
            names = sorted(os.listdir(fs_path))
            stack.extend((f"{path}/{name}", os.path.join(fs_path, name)) for name in names)
            yield path, f"{len(names)}d".encode()
        elif stat.S_ISLNK(st.st_mode):
            yield path, os.readlink(fs_path).encode() + b"s"
        else:
            kind = "x" if st.st_mode & 0o111 else "r"
            yield path, f"{st.st_size}{kind}".encode()


def store_path_json(out_path, attr, system):
    base = os.path.basename(out_path)
    store_hash, name = base.split("-", 1)
    return json.dumps(
        {
            "store_dir": os.path.dirname(out_path),
            "hash": store_hash,
            "name": name,
            "origin": {
                "attr": attr,
                "output": "out",
                "toplevel": True,
                "system": system,
            },
        },
        separators=(",", ":"),
    ).encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="ベースとなる nix-index DB")
    parser.add_argument("--package", required=True, help="追記するパッケージの出力パス")
    parser.add_argument("--attr", required=True, help="nixpkgs の属性名")
    parser.add_argument("--system", required=True, help="対象システム")
    parser.add_argument(
        "--filter-prefix",
        default="",
        help="DB に含めるパスのプレフィックス (small DB では /bin/)",
    )
    parser.add_argument("--out", required=True, help="出力先 DB ファイル")
    args = parser.parse_args()

    with open(args.base, "rb") as f:
        base = f.read()

    writer = FrcodeWriter(b"p", store_path_json(args.package, args.attr, args.system))
    for path, meta in walk(args.package):
        if path.startswith(args.filter_prefix):
            writer.entry(meta, path.encode())

    frame = subprocess.run(
        ["zstd", "-q", "-c", "--no-check"],
        input=writer.finish(),
        stdout=subprocess.PIPE,
        check=True,
    ).stdout

    with open(args.out, "wb") as f:
        f.write(base)
        f.write(frame)

    print(f"merged {args.attr} into {args.base}", file=sys.stderr)


if __name__ == "__main__":
    main()
