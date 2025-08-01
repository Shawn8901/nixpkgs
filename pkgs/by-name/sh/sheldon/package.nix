{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  installShellFiles,
  curl,
}:

rustPlatform.buildRustPackage rec {
  pname = "sheldon";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "rossmacarthur";
    repo = "sheldon";
    rev = version;
    hash = "sha256-zVwqVYaUY8LJhWENDiD89p/CzvsEVkpaPnYVyCJUf3s=";
  };

  cargoHash = "sha256-4TDDNqlcs7LTmL9uHBjE8SHft38juUJUj8sLCimnTyc=";

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];
  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  # Needs network connection
  checkFlags = [
    "--skip lock::plugin::tests::external_plugin_lock_git_with_matches"
    "--skip lock::plugin::tests::external_plugin_lock_git_with_matches_not_each"
    "--skip lock::plugin::tests::external_plugin_lock_git_with_uses"
    "--skip lock::plugin::tests::external_plugin_lock_remote"
    "--skip lock::source::git::tests::git_checkout_resolve_branch"
    "--skip lock::source::git::tests::git_checkout_resolve_rev"
    "--skip lock::source::git::tests::git_checkout_resolve_tag"
    "--skip lock::source::git::tests::lock_git_and_reinstall"
    "--skip lock::source::git::tests::lock_git_https_with_checkout"
    "--skip lock::source::local::tests::lock_local"
    "--skip lock::source::remote::tests::lock_remote_and_reinstall"
    "--skip lock::source::tests::lock_with_git"
    "--skip lock::source::tests::lock_with_remote"
    "--skip lock::tests::locked_config_clean"
    "--skip directories_default"
    "--skip directories_old"
    "--skip directories_xdg_from_env"
    "--skip lock_and_source_github"
    "--skip lock_and_source_hooks"
    "--skip lock_and_source_inline"
    "--skip lock_and_source_profiles"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sheldon \
      --bash <($out/bin/sheldon completions --shell bash) \
      --zsh <($out/bin/sheldon completions --shell zsh)
  '';

  meta = with lib; {
    description = "Fast and configurable shell plugin manager";
    homepage = "https://github.com/rossmacarthur/sheldon";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ seqizz ];
    platforms = platforms.unix;
    mainProgram = "sheldon";
  };
}
