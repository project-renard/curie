@echo off

cd %APPVEYOR_BUILD_FOLDER%

echo Compiler: %COMPILER%
echo Architecture: %MSYS2_ARCH%
echo Platform: %PLATFORM%
echo MSYS2 directory: %MSYS2_DIR%
echo MSYS2 system: %MSYSTEM%
echo Bits: %BIT%

IF %COMPILER%==msys2 (
  @echo on
  SET "PATH=C:\%MSYS2_DIR%\%MSYSTEM%\bin;C:\%MSYS2_DIR%\usr\bin;%PATH%"
  bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
  bash -lc "pacman -S --needed --noconfirm git"
  
  REM build tools
  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-toolchain autoconf automake libtool make patch mingw-w64-x86_64-libtool"
  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-perl"
  bash -lc "yes | cpan App::cpanminus"

  REM Work around so that dmake does not delete required C file
  bash -lc "cpanm --notest ExtUtils::MakeMaker"

  REM See <https://github.com/maddingue/Sys-Syslog/pull/6>
  bash -lc "cpanm --verbose https://github.com/chorny/Sys-Syslog.git"
  bash -lc "cpanm --verbose Log::Dispatch"

  REM Need to stub out RM so it does not remove cchars.h
  bash -lc "cpanm --verbose Term::ReadKey --build-args RM=echo"

  bash -lc ". $APPVEYOR_BUILD_FOLDER/ci/appveyor/EUMMnosearch.sh; cpanm --notest IO::Socket::SSL"

  bash -lc "cpanm --notest Dist::Zilla"

  bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-cairo mingw-w64-x86_64-gtk3 mingw-w64-x86_64-expat mingw-w64-x86_64-openssl"

  bash -lc "dzil authordeps --missing | cpanm --notest"
  bash -lc ". $APPVEYOR_BUILD_FOLDER/ci/appveyor/EUMMnosearch.sh; dzil listdeps | cpanm --notest"
)
