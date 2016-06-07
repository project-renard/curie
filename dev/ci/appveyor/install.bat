@echo off

cd %APPVEYOR_BUILD_FOLDER%

echo Compiler: %COMPILER%
echo Architecture: %MSYS2_ARCH%
echo Platform: %PLATFORM%
echo MSYS2 directory: %MSYS2_DIR%
echo MSYS2 system: %MSYSTEM%
echo Bits: %BIT%

REM Create a writeable TMPDIR
mkdir %APPVEYOR_BUILD_FOLDER%\tmp
set TMPDIR=%APPVEYOR_BUILD_FOLDER%\tmp

IF %COMPILER%==msys2 (
  @echo on
  SET "PATH=C:\%MSYS2_DIR%\%MSYSTEM%\bin;C:\%MSYS2_DIR%\usr\bin;%PATH%"
  bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
  bash -lc "pacman -S --needed --noconfirm git"
  REM Update
  bash -lc "pacman -Syu --noconfirm"

  REM build tools
  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-toolchain autoconf automake libtool make patch mingw-w64-x86_64-libtool"

  REM Set up perl
  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-perl"
  bash -lc "pl2bat $(which pl2bat)"
  bash -lc "yes | cpan App::cpanminus"
  bash -lc "cpanm --notest ExtUtils::MakeMaker Module::Build"

  REM Native deps
  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-gobject-introspection mingw-w64-x86_64-cairo mingw-w64-x86_64-gtk3 mingw-w64-x86_64-expat mingw-w64-x86_64-openssl"

  REM There is not a corresponding cc for the mingw64 gcc. So we copy it in place.
  bash -lc "cp -pv /mingw64/bin/gcc /mingw64/bin/cc"

  REM Install via cpanfile
  REM bash -lc "cd $APPVEYOR_BUILD_FOLDER; . $APPVEYOR_BUILD_FOLDER/dev/ci/appveyor/EUMMnosearch.sh; cpanm --verbose --configure-args verbose --build-args NOECHO=' ' -n Gtk3 Glib"
  bash -lc "cd $APPVEYOR_BUILD_FOLDER; . $APPVEYOR_BUILD_FOLDER/dev/ci/appveyor/EUMMnosearch.sh; export MAKEFLAGS='-j4 -P4'; cpanm --notest --installdeps ."
)
