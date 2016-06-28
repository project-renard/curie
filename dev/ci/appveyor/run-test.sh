#!/bin/sh

cd $APPVEYOR_BUILD_FOLDER

. external/project-renard/devops/ENV.sh
prove -lvr t

#dzil test
