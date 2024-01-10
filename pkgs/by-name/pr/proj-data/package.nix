{ lib
, stdenv
, callPackage
, fetchFromGitHub

# Install only selected proj-data grid packages. By default all grids are
# installed.
, gridPackages ? [ ]
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proj-data";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "PROJ-data";
    rev = finalAttrs.version;
    hash = "sha256-/EgDeWy2+KdcI4DLsRfWi5OWcGwO3AieEJQ5Zh+wdYE=";
  };

  installPhase =
  let
    selectedGridPackages = if (gridPackages == []) then
      "ALL"
    else
      builtins.toString gridPackages;
  in
  ''
    runHook preInstall
    shopt -s extglob

    mkdir -p $out
    cp files.geojson $out/files.geojson

    if [ "${selectedGridPackages}" == "ALL" ]; then
      echo "Installing all available grids ..."
      grids=$(find . -maxdepth 1 -type d -not -path '.' -not -path '*.github' -not -path '*grid_tools' -not -path '*travis')
    else
      echo "Installing selected grids (${selectedGridPackages}) ..."
      grids=${selectedGridPackages}
    fi

    for grid in $grids; do
      if [ ! -d $grid ]; then
        echo "ERROR: Grid ($grid) does not exist."
        exit 1
      fi
      cp $grid/!(*.sh|*.py) $out/
    done

    shopt -u extglob
    runHook postInstall
  '';

  passthru.tests = {
    proj-data = callPackage ./tests.nix {
      proj-data = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    description = "Repository for proj datum grids (for use by PROJ 7 or later)";
    homepage = "https://proj4.org";
    # Licensing note:
    # All grids in the package are released under permissive licenses. New grids
    # are accepted into the package as long as they are released under a license that
    # is compatible with the Open Source Definition and the source of the grid is
    # clearly stated and verifiable. Suitable licenses include:
    # Public domain
    # X/MIT
    # BSD 2/3/4 clause
    # CC0
    # CC-BY (v3.0 or later)
    # CC-BY-SA (v3.0 or later)
    license = licenses.mit;
    maintainers = teams.geospatial.members;
  };
})
