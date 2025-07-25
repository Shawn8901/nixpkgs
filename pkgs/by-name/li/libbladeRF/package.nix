{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  cmake,
  git,
  doxygen,
  help2man,
  ncurses,
  tecla,
  libusb1,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "libbladeRF";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "Nuand";
    repo = "bladeRF";
    rev = "libbladeRF_v${version}";
    hash = "sha256-H40w5YKp6M3QLrsPhILEnJiWutCYLtbgC4a63sV397Q=";
    fetchSubmodules = true;
  };

  patches = [
    # https://github.com/Nuand/bladeRF/issues/994
    ./gcc-14-calloc-fixes.diff
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    doxygen
    help2man
  ];
  # ncurses used due to https://github.com/Nuand/bladeRF/blob/ab4fc672c8bab4f8be34e8917d3f241b1d52d0b8/host/utilities/bladeRF-cli/CMakeLists.txt#L208
  buildInputs = [
    tecla
    libusb1
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ ncurses ];

  # Fixup shebang
  prePatch = "patchShebangs host/utilities/bladeRF-cli/src/cmd/doc/generate.bash";

  # Let us avoid net-tools as a dependency.
  postPatch = ''
    sed -i 's/$(hostname)/hostname/' host/utilities/bladeRF-cli/src/cmd/doc/generate.bash
  '';

  doInstallCheck = true;

  cmakeFlags = [
    "-DBUILD_DOCUMENTATION=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-DUDEV_RULES_PATH=etc/udev/rules.d"
    "-DINSTALL_UDEV_RULES=ON"
    "-DBLADERF_GROUP=bladerf"
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable";
  };

  hardeningDisable = [ "fortify" ];

  meta = with lib; {
    homepage = "https://nuand.com/libbladeRF-doc";
    description = "Supporting library of the BladeRF SDR opensource hardware";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ markuskowa ];
    platforms = platforms.unix;
  };
}
