#!/bin/sh

unzip -n Photos-Demo.zip -x __MACOSX/* -d photos-demo
IP_ADDRESS=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
find photos-demo/ -type f \( -iname \*.jpg -o -iname \*.png \) -exec ./openphoto -p -v -X POST -h $IP_ADDRESS -e /photo/upload.json -F 'photo=@{}' --encode \;
