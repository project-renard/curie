#!/bin/sh

cd $APPVEYOR_BUILD_FOLDER

git clone https://github.com/project-renard/test-data.git test-data
export RENARD_TEST_DATA_PATH="`( cd test-data && pwd )`"
prove -lvr t

#dzil test
