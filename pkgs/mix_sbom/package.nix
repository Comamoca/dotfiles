{
  lib,
  beamPackages,
  fetchFromGitHub,
}:

let
  version = "0.10.0";

  # Upstream pins Erlang 28 / Elixir 1.19 in .tool-versions, and the escript is
  # rebuilt from source here, so use the matching elixir in the package set
  # (beamPackages defaults to 1.18).
  beam = beamPackages.overrideScope (final: prev: {
    elixir = prev.elixir_1_19;
  });

  src = fetchFromGitHub {
    owner = "erlef";
    repo = "mix_sbom";
    tag = "v${version}";
    hash = "sha256-ZvJH1cKKdZVqp8jP4vT72Rb93VV8grM/WJlyrAzPhFU=";
  };
in
(beam.mixRelease {
  pname = "mix_sbom";
  inherit version src;

  # mix.exs declares `escript: [main_module: SBoM.Escript, name: "mix_sbom"]`,
  # so mixRelease's escript support builds the standalone binary and installs
  # it as $out/bin/mix_sbom.
  escriptBinName = "mix_sbom";

  mixFodDeps = beam.fetchMixDeps {
    pname = "mix_sbom-deps";
    inherit src version;
    hash = "sha256-dbCiO59Llj+zX54A8p5hmfhAeoo5i3hpO32I90AkRMk=";
  };

  meta = {
    description = "Mix task to generate a Software Bill-of-Materials (SBoM) in CycloneDX format";
    homepage = "https://github.com/erlef/mix_sbom";
    downloadPage = "https://github.com/erlef/mix_sbom/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    mainProgram = "mix_sbom";
    platforms = lib.platforms.unix;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}).overrideAttrs (old: {
  # An escript is not self-contained: it re-executes itself through `escript`
  # from the OTP installation it was built with, so that runtime has to be on
  # PATH. This replaces mixRelease's postFixup, which only wires up the
  # coreutils/gawk the releases it normally installs shell out to.
  postFixup = ''
    wrapProgram $out/bin/mix_sbom \
      --prefix PATH : ${lib.makeBinPath [ beam.erlang ]}
  '';
})
