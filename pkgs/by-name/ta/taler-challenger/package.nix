{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  libgcrypt,
  pkg-config,
  texinfo,
  curl,
  gnunet,
  jansson,
  libgnurl,
  libmicrohttpd,
  libsodium,
  libtool,
  libpq,
  taler-exchange,
  taler-merchant,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-challenger";
  version = "1.0.0";

  src = fetchgit {
    url = "https://git.taler.net/challenger.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZKRqNlva3LZCuAva7h6Wk2NIuHF3rReR+yNETqbCv1k=";
  };

  # https://git.taler.net/challenger.git/tree/bootstrap
  preAutoreconf = ''
    # Generate Makefile.am in contrib/
    pushd contrib
    rm -f Makefile.am
    find wallet-core/challenger/ -type f -printf '  %p \\\n' | sort > Makefile.am.ext
    # Remove extra '\' at the end of the file
    truncate -s -2 Makefile.am.ext
    cat Makefile.am.in Makefile.am.ext >> Makefile.am
    # Prevent accidental editing of the generated Makefile.am
    chmod -w Makefile.am
    popd
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    libgcrypt
    pkg-config
    texinfo
  ];

  buildInputs = [
    curl
    gnunet
    jansson
    libgcrypt
    libgnurl
    libmicrohttpd
    libpq
    libsodium
    libtool
    taler-exchange
    taler-merchant
  ];

  preFixup = ''
    substituteInPlace $out/bin/challenger-{dbconfig,send-post.sh} \
      --replace-fail "/bin/bash" "${runtimeShell}"
  '';

  meta = {
    description = "OAuth 2.0-based authentication service that validates user can receive messages at a certain address";
    homepage = "https://git.taler.net/challenger.git";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    teams = with lib.teams; [ ngi ];
    platforms = lib.platforms.linux;
  };
})
