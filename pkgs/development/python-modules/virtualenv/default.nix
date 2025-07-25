{
  lib,
  buildPythonPackage,
  pythonOlder,
  isPyPy,
  cython,
  distlib,
  fetchPypi,
  filelock,
  flaky,
  hatch-vcs,
  hatchling,
  importlib-metadata,
  platformdirs,
  pytest-freezegun,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
  time-machine,
}:

buildPythonPackage rec {
  pname = "virtualenv";
  version = "20.31.2";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4QwKnQKDXlklIb5IszK2yu5oh/MywRGqeaCbnnnvwq8=";
  };

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = [
    distlib
    filelock
    platformdirs
  ]
  ++ lib.optionals (pythonOlder "3.8") [ importlib-metadata ];

  nativeCheckInputs = [
    cython
    flaky
    pytest-freezegun
    pytest-mock
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.optionals (!isPyPy) [ time-machine ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabledTestPaths = [
    # Ignore tests which require network access
    "tests/unit/create/test_creator.py"
    "tests/unit/seed/embed/test_bootstrap_link_via_app_data.py"
  ];

  disabledTests = [
    # Network access
    "test_create_no_seed"
    "test_seed_link_via_app_data"
    # Permission Error
    "test_bad_exe_py_info_no_raise"
  ]
  ++ lib.optionals (pythonOlder "3.11") [ "test_help" ]
  ++ lib.optionals (isPyPy) [
    # encoding problems
    "test_bash"
    # permission error
    "test_can_build_c_extensions"
    # fails to detect pypy version
    "test_discover_ok"
  ];

  pythonImportsCheck = [ "virtualenv" ];

  meta = with lib; {
    description = "Tool to create isolated Python environments";
    mainProgram = "virtualenv";
    homepage = "http://www.virtualenv.org";
    changelog = "https://github.com/pypa/virtualenv/blob/${version}/docs/changelog.rst";
    license = licenses.mit;
    maintainers = [ ];
  };
}
