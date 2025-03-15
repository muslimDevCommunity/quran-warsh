# بسم الله الرحمن الرحيم
# la ilaha illa Allah Mohammed Rassoul Allah
{ lib
, stdenv
, callPackage
, fetchzip
, fetchFromGitHub
, zig_0_13
, csfml
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quran-warsh";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "muslimDevCommunity";
    repo = "quran-warsh";
    rev = "1.0.0";
    hash = "sha256-sq0ks5fpHe5FCbtMKDVBH3Z2Uj2wHz3LB1YdxZgIgGk=";
  };

  deps = callPackage ./build.zig.zon.nix {
    zig = zig_0_13;
  };

  nativeBuildInputs = [
    csfml
    zig_0_13.hook
  ];

  zigBuildFlags =
    [
      "--system"
      "${finalAttrs.deps}"
    ];

  meta = with lib; {
    description = "warsh tajweed quran for desktop";
    homepage = "https://github.com/muslimDevCommunity/quran-warsh";
    # license = licenses.mit;
    mainProgram = "quran-warsh";
    inherit (zig_0_13.meta) platforms;
  };
})
