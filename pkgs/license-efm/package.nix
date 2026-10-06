{
  lib,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "license-efm";
  version = "0.1.0";

  src = ./.;

  # Standard library only, so there is nothing to vendor.
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Report Gleam package licences in efm (errorformat) style";
    longDescription = ''
      Scans a Gleam project's gleam.toml and manifest.toml and prints the
      licence of every package it references as one line per package in
      errorformat shape, which efm-langserver turns into LSP diagnostics.
      Licences are read from local state only: the resolved dependency tree
      under build/packages and the shared hex cache.
    '';
    homepage = "https://github.com/Comamoca/dotfiles";
    license = lib.licenses.unlicense;
    mainProgram = "license-efm";
    platforms = lib.platforms.unix;
  };
})
