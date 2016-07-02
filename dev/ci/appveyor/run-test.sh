#!/bin/sh

cd $APPVEYOR_BUILD_FOLDER

export TEST_JOBS=4
. external/project-renard/devops/ENV.sh
prove -j${TEST_JOBS} -lvr t

#dzil test
