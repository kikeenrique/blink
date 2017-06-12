#!/usr/bin/env bash

echo "BEGIN pwd:"
pwd
echo "list prebuild initial directory"
ls -la 


echo "git get submodules"
#cd blink 
#git clone --recursive git@github.com:blinksh/blink.git
git submodule update --init --recursive

echo "get frameworks"
./get_frameworks.sh

echo "END"
