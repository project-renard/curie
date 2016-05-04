@echo off

cd %APPVEYOR_BUILD_FOLDER%

IF %COMPILER%==msys2 (
  @echo on
  SET "PATH=C:\%MSYS2_DIR%\%MSYSTEM%\bin;C:\%MSYS2_DIR%\usr\bin;%PATH%"
  bash -lc ". $APPVEYOR_BUILD_FOLDER/dev/ci/appveyor/run-test.sh"
)
