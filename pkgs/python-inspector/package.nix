{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "python-inspector";
  version = "0.15.2";
  pyproject = true;

  src = fetchPypi {
    pname = "python_inspector";
    inherit version;
    format = "setuptools";
    hash = "sha256-FvD7D4X7JnexNT7L9HBzeSiAtOEyaTVeeQKfqpJebmw=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    aiofiles
    aiohttp
    attrs
    click
    colorama
    commoncode
    dparse2
    fasteners
    importlib-metadata
    mock
    packageurl-python
    packvers
    pip-requirements-parser
    pkginfo2
    pydantic
    pydantic-settings
    requests
    resolvelib
    saneyaml
    setuptools # provides the `distutils` shim used by setup_py_live_eval
    toml
  ];

  doCheck = false;

  # The sdist ships an aboutcode `configure` script that requires curl and
  # network access; the setuptools build does not need it.
  dontConfigure = true;

  meta = {
    description = "Utilities to collect PyPI package metadata and resolve Python package dependencies";
    homepage = "https://github.com/aboutcode-org/python-inspector";
    license = lib.licenses.asl20;
    mainProgram = "python-inspector";
    platforms = lib.platforms.all;
  };
}
