{ lib
, rustPlatform
, fetchFromGitHub
, help2man
, installShellFiles
, pkg-config
, bzip2
, xz
, zlib
, zstd
}:

rustPlatform.buildRustPackage rec {
  pname = "ouch";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "ouch-org";
    repo = pname;
    rev = version;
    sha256 = "";
  };

  cargoSha256 = "";

  nativeBuildInputs = [ help2man installShellFiles pkg-config ];

  buildInputs = [ bzip2 xz zlib zstd ];

  buildFeatures = [ "zstd/pkg-config" ];

  postInstall = ''
    help2man $out/bin/ouch > ouch.1
    installManPage ouch.1

    completions=($releaseDir/build/ouch-*/out/completions)
    installShellCompletion $completions/ouch.{bash,fish} --zsh $completions/_ouch
  '';

  GEN_COMPLETIONS = 1;

  meta = with lib; {
    description = "A command-line utility for easily compressing and decompressing files and directories";
    homepage = "https://github.com/ouch-org/ouch";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda psibi ];
  };
}
