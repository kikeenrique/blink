#!/usr/bin/env bash

echo "BEGIN pwd:"
pwd

echo "git submodules ops"
git submodule init
git submodule update

cd Frameworks
echo "curl Blink-Frameworks"
curl -OL https://github.com/blinksh/blink/releases/download/v1.019/Blink-Frameworks.tar.gz
echo "tar"
tar -zxvf Blink-Frameworks.tar.gz

echo "END"
