{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "abom";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "JulietSecurity";
    repo = "abom";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yUB9uqxIP3UrShObzNJjwAt/4cu6Eo1rSAXmjPKdONQ=";
  };

  vendorHash = "sha256-oEqjA1n5o1UBh7vV6xx7xhAGC7pTb/Vvgd4gmYbMr4Y=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/julietsecurity/abom/cmd.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Generate an SBOM for GitHub Actions workflows";
    homepage = "https://github.com/JulietSecurity/abom";
    license = lib.licenses.asl20;
    mainProgram = "abom";
    platforms = lib.platforms.unix;
  };
})
