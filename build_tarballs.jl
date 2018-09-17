# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "GDBM"
version = v"1.18"

# Collection of sources required to build GDBMBuilder
sources = [
    "ftp://ftp.gnu.org/gnu/gdbm/gdbm-1.18.tar.gz" =>
    "b8822cb4769e2d759c828c06f196614936c88c141c3132b18252fe25c2b635ce",

    "https://raw.githubusercontent.com/Alexpux/MINGW-packages/master/mingw-w64-gdbm/gdbm-1.15-win32.patch" =>
    "4eeb6cb44c43f740e1908604aed5f219ac395d02dddf1c5371ac9511ca8223db",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd gdbm-1.18/
if [ $target = "x86_64-w64-mingw32" ] || [ $target = "i686-w64-mingw32" ]; then
patch -Np1 -i ../*gdbm-1.15-win32.patch
touch configure.ac
./configure --prefix=$prefix --host=$target --without-readline --disable-dependency-tracking --disable-silent-rules
touch Makefile.am
else
./configure --prefix=$prefix --host=$target --without-readline --disable-dependency-tracking --disable-silent-rules
fi
make
make install
exit

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libgdbm", Symbol(""))
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
