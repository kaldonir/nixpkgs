{ stdenv, fetchFromGitHub, sqlite, pkgconfig, autoreconfHook, pmccabe
, xapian, glib, gmime3, texinfo , emacs, guile
, gtk3, webkitgtk, libsoup, icu
, withMug ? false
, batchSize ? null }:

stdenv.mkDerivation rec {
  pname = "mu";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner  = "djcb";
    repo   = "mu";
    rev    = version;
    sha256 = "1i9chd8ks1q4g5pyscsir6pw4kahkx3k8ckzbi8j3gr6jz1qzzsg";
  };

  postPatch = stdenv.lib.optionalString (batchSize != null) ''
    sed -i lib/mu-store.cc --regexp-extended \
      -e 's@(constexpr auto BatchSize).*@\1 = ${toString batchSize};@'
  '';

  buildInputs = [
    sqlite xapian glib gmime3 texinfo emacs guile libsoup icu
  ] ++ stdenv.lib.optionals withMug [ gtk3 webkitgtk ];

  nativeBuildInputs = [ pkgconfig autoreconfHook pmccabe ];

  enableParallelBuilding = true;

  preBuild = ''
    # Fix mu4e-builddir (set it to $out)
    substituteInPlace mu4e/mu4e-meta.el.in \
      --replace "@abs_top_builddir@" "$out"
  '';

  # Install mug
  postInstall = stdenv.lib.optionalString withMug ''
    for f in mug ; do
      install -m755 toys/$f/$f $out/bin/$f
    done
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A collection of utilties for indexing and searching Maildirs";
    license = licenses.gpl3Plus;
    homepage = "https://www.djcbsoftware.nl/code/mu/";
    maintainers = with maintainers; [ antono peterhoeg ];
    platforms = platforms.mesaPlatforms;
  };
}
