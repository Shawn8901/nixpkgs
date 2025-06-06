{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "openrisk";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "projectdiscovery";
    repo = "openrisk";
    tag = "v${version}";
    hash = "sha256-8DGwNoucLpdazf9r4PZrN4DEOMpTr5U7tal2Rab92pA=";
  };

  vendorHash = "sha256-BLowqqlMLDtsthS4uKeycmtG7vASG25CARGpUcuibcw=";

  ldflags = [
    "-w"
    "-s"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  meta = {
    description = "Tool that generates an AI-based risk score";
    homepage = "https://github.com/projectdiscovery/openrisk";
    changelog = "https://github.com/projectdiscovery/openrisk/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "openrisk";
  };
}
