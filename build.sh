#!/bin/bash
./buildfiles/build-alib.sh
./buildfiles/build-loader.sh
lua buildfiles/make-default-json.lua