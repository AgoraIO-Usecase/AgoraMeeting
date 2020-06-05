#!/bin/sh
ArchivePathQA=VideoConferenceQA.xcarchive
IPANameQA="IPAQA"

sh install.sh

xcodebuild clean -workspace "VideoConference.xcworkspace" -scheme "VideoConference" -configuration QARelease
xcodebuild -workspace "VideoConference.xcworkspace" -scheme "VideoConference" -configuration QARelease -archivePath ${ArchivePathQA} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePathQA} -exportPath ${IPANameQA} -quiet || exit
cp ${IPANameQA}/VideoConference.ipa VideoConferenceQA.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F  "file=@VideoConferenceQA.ipa"
