{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "lil-pwny";
  version = "2.0.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "PaperMtn";
    repo = "lil-pwny";
    tag = version;
    hash = "sha256-EE6+PQTmvAv5EvxI9QR/dQcPby13BBk66KSc7XDNAZA=";
  };

  # Project has no test
  doCheck = false;

  pythonImportsCheck = [
    "lil_pwny"
  ];

  meta = {
    description = "Offline auditing of Active Directory passwords";
    mainProgram = "lil-pwny";
    homepage = "https://github.com/PaperMtn/lil-pwny";
    changelog = "https://github.com/PaperMtn/lil-pwny/blob/${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
