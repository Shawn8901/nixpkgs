{
  lib,
  python3,
  fetchFromGitHub,
  git,
  testers,
  aws-sam-cli,
  nix-update-script,
  enableTelemetry ? false,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "aws-sam-cli";
  version = "1.135.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-sam-cli";
    tag = "v${version}";
    hash = "sha256-ccYpEznuU6d7gDyrDiuUmvdCJutXI7SAH2PH9Vdq8Fs=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  pythonRelaxDeps = [
    "aws-lambda-builders"
    "aws-sam-translator"
    "boto3-stubs"
    "cfn-lint"
    "cookiecutter"
    "docker"
    "jsonschema"
    "pyopenssl"
    "requests"
    "rich"
    "ruamel-yaml"
    "tomlkit"
    "tzlocal"
    "watchdog"
  ];

  dependencies =
    with python3.pkgs;
    [
      aws-lambda-builders
      aws-sam-translator
      boto3
      boto3-stubs
      cfn-lint
      chevron
      click
      cookiecutter
      dateparser
      docker
      flask
      jsonschema
      pyopenssl
      pyyaml
      requests
      rich
      ruamel-yaml
      tomlkit
      typing-extensions
      tzlocal
      watchdog
    ]
    ++ (with python3.pkgs.boto3-stubs.optional-dependencies; [
      apigateway
      cloudformation
      ecr
      iam
      kinesis
      lambda
      s3
      schemas
      secretsmanager
      signer
      sqs
      stepfunctions
      sts
      xray
    ]);

  postFixup = ''
    # Disable telemetry: https://github.com/aws/aws-sam-cli/issues/1272
    wrapProgram $out/bin/sam \
      --set SAM_CLI_TELEMETRY ${if enableTelemetry then "1" else "0"} \
      --prefix PATH : $out/bin:${lib.makeBinPath [ git ]}
  '';

  nativeCheckInputs = with python3.pkgs; [
    filelock
    flaky
    jaraco-text
    parameterized
    psutil
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export PATH="$PATH:$out/bin:${lib.makeBinPath [ git ]}"
  '';

  pytestFlags = [
    # Disable warnings
    "-Wignore::DeprecationWarning"
  ];

  enabledTestPaths = [
    "tests"
  ];

  disabledTestPaths = [
    # Disable tests that requires networking or complex setup
    "tests/end_to_end"
    "tests/integration"
    "tests/regression"
    "tests/smoke"
    "tests/unit/lib/telemetry"
    "tests/unit/hook_packages/terraform/hooks/prepare/"
    "tests/unit/lib/observability/cw_logs/"
    "tests/unit/lib/build_module/"
    # Disable flaky tests
    "tests/unit/lib/samconfig/test_samconfig.py"
  ];

  disabledTests = [
    # Disable flaky tests
    "test_update_stage"
    "test_delete_deployment"
    "test_request_with_no_data"
    "test_import_should_succeed_for_a_defined_hidden_package_540_pkg_resources_py2_warn"
  ];

  pythonImportsCheck = [ "samcli" ];

  passthru = {
    tests.version = testers.testVersion {
      package = aws-sam-cli;
      command = "sam --version";
    };
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v([0-9.]+)$"
      ];
    };
  };

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "CLI tool for local development and testing of Serverless applications";
    homepage = "https://github.com/aws/aws-sam-cli";
    changelog = "https://github.com/aws/aws-sam-cli/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "sam";
    maintainers = with lib.maintainers; [
      lo1tuma
      anthonyroussel
    ];
  };
}
