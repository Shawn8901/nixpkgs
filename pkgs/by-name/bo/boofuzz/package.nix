{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "boofuzz";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jtpereyda";
    repo = "boofuzz";
    tag = "v${version}";
    hash = "sha256-ffZVFmfDAJ+Qn3hbeHY/CvYgpDLxB+jaYOiYyZqZ7mo=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    attrs
    click
    colorama
    flask
    funcy
    future
    psutil
    pyserial
    pydot
    six
    tornado
  ];

  nativeCheckInputs = with python3.pkgs; [
    mock
    netifaces
    pytest-bdd
    pytestCheckHook
  ];

  disabledTests =
    [
      "TestNetworkMonitor"
      "TestNoResponseFailure"
      "TestProcessMonitor"
      "TestSocketConnection"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "test_time_repeater"
    ];

  pythonImportsCheck = [
    "boofuzz"
  ];

  meta = {
    description = "Network protocol fuzzing tool";
    mainProgram = "boo";
    homepage = "https://github.com/jtpereyda/boofuzz";
    changelog = "https://github.com/jtpereyda/boofuzz/blob/v${version}/CHANGELOG.rst";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
