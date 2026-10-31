#!/usr/bin/env node
// OmniRoute の料金表 (key_value / namespace='pricing_synced') に、
// LiteLLM の同期では埋まらないモデルの推定料金を冪等に補完する。
//
// 背景:
//   OmniRoute の LiteLLM 同期は pricing_synced を全削除してから書き直すので、
//   手で入れた補完値は次の同期で消える。本スクリプトは同期後に再適用して
//   「料金なし」のモデルを減らすためのもので、何度実行しても結果は同じ。
//
// 前提:
//   - コンテナ内 (/app) で実行する (better-sqlite3 と /app/data/storage.sqlite
//     が見える形で docker exec する)。
//   - 補完データは /app/data/pricing-backfill.json に置かれていること。
//
// ルール:
//   - 既に料金がある (実データ) モデルは絶対に上書きしない。
//   - 料金表が存在しないプロバイダ (自動生成キーなど) には新しい表を作る。
//   - 反映後に pricing の読み取りキャッシュが再構築されるよう、
//     呼び出し側で OmniRoute を再起動するか GET /api/pricing を再取得する。

import Database from "better-sqlite3";
import { readFileSync } from "node:fs";
import process from "node:process";

const DB_PATH = process.env.OMNIROUTE_DB ?? "/app/data/storage.sqlite";
const BACKFILL_PATH =
  process.env.OMNIROUTE_PRICING_BACKFILL ?? "/app/data/pricing-backfill.json";
const NAMESPACE = "pricing_synced";

const patch = JSON.parse(readFileSync(BACKFILL_PATH, "utf8"));
const db = new Database(DB_PATH);

const rows = db
  .prepare("SELECT key, value FROM key_value WHERE namespace = ?")
  .all(NAMESPACE);

const tables = new Map();
for (const row of rows) {
  try {
    tables.set(row.key, JSON.parse(row.value));
  } catch {
    // 壊れた行は同期で作り直されるので、ここでは触らない。
  }
}

let added = 0;
let kept = 0;
for (const [provider, models] of Object.entries(patch)) {
  const table = tables.get(provider) ?? {};
  for (const [model, price] of Object.entries(models)) {
    if (table[model]) {
      kept += 1;
      continue;
    }
    table[model] = price;
    added += 1;
  }
  tables.set(provider, table);
}

const upsert = db.prepare(
  `INSERT INTO key_value (namespace, key, value) VALUES (?, ?, ?)
   ON CONFLICT(namespace, key) DO UPDATE SET value = excluded.value`,
);

db.transaction(() => {
  for (const [provider, table] of tables) {
    upsert.run(NAMESPACE, provider, JSON.stringify(table));
  }
})();

db.close();

console.log(
  `[pricing-backfill] providers=${Object.keys(patch).length} added=${added} kept(existing)=${kept}`,
);
