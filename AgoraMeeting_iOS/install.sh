#!/bin/bash

echo "======install start======"

echo "downing framework..."
curl -OL https://github.com/AgoraIO-Community/eConferencing-iOS/releases/download/v0.0.1/AgoraRtcKit.framework.zip

echo "unzip framework..."
unzip -n AgoraRtcKit.framework.zip -d Modules/AgoraRoom/AgoraRoom
rm -f AgoraRtcKit.framework.zip

echo "======install success======"


