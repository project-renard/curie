#!/bin/bash

# bash -lc "cd $APPVEYOR_BUILD_FOLDER; . $APPVEYOR_BUILD_FOLDER/dev/ci/appveyor/EUMMnosearch.sh; cpanm --verbose --configure-args verbose --build-args NOECHO=' ' -n Gtk3 Glib"

cd $APPVEYOR_BUILD_FOLDER;
. external/project-renard/devops/script/mswin/EUMMnosearch.sh
export MAKEFLAGS='-j4 -P4'

# Install via cpanfile
cpanm --notest --installdeps .
