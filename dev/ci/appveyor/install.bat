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
  bash -lc "cd $APPVEYOR_BUILD_FOLDER; ./dev/script/get-aux-repo"
  bash -lc "cd $APPVEYOR_BUILD_FOLDER; ./dev/ci/appveyor/update-msys2.sh"
  bash -lc "cd $APPVEYOR_BUILD_FOLDER; ./dev/script/install-native-dep"
  bash -lc "cd $APPVEYOR_BUILD_FOLDER; ./dev/ci/appveyor/install-perl-dist.sh"
)
