#!/bin/sh

unset OPENSSL_CONF
export OPENSSL_PREFIX="/c/msys64/mingw64"
#echo PATH=$PATH
#set
#pkg-config --libs --cflags  openssl

BUILD_DIR=`(cd $APPVEYOR_BUILD_FOLDER && pwd)`
export PERL5OPT="-I$BUILD_DIR/dev/ci/appveyor -MEUMMnosearch"
echo PERL5OPT=$PERL5OPT;
