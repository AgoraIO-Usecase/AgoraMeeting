#!/bin/bash

echo "======install start======"

SDK_NAME="Agora_Native_SDK_for_iOS_v3_0_0_239_FULL_20200508_2756.zip"

echo "======downing framework======"
rm -f ${SDK_NAME}
curl -OL https://download.agora.io/sdk/release/${SDK_NAME}

if [ -f ${SDK_NAME} ];then
echo "======unzip framework======"
rm -rf Agora_Native_SDK/
mkdir Agora_Native_SDK
unzip -n ${SDK_NAME} -d Agora_Native_SDK/
else
echo "======downing framework error======"
exit 1
fi

if [ -d "Agora_Native_SDK" ];then
rm -f Modules/AgoraRoom/AgoraRoom/AgoraRtcKit.framework
mv Agora_Native_SDK/Agora_Native_SDK_for_iOS_FULL/libs/AgoraRtcKit.framework Modules/AgoraRoom/AgoraRoom

else
echo "======unzip framework error======"
exit 2
fi

echo "======clean======"
rm -f ${SDK_NAME}
rm -rf Agora_Native_SDK/

echo "======install success======"


