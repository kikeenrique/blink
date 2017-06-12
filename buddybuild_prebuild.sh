#!/usr/bin/env bash

echo "BEGIN pwd:"
pwd

echo "git clone and submodules"
git clone --recursive git@github.com:blinksh/blink.git

cd blink 
echo "get frameworks"
./get_frameworks.sh

echo "END"
