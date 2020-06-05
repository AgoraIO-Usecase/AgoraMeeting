#!/bin/sh
ArchivePath=VideoConferenceDev.xcarchive
IPAName="IPADEV"

xcodebuild clean -workspace "VideoConference.xcworkspace" -scheme "VideoConference" -configuration DevRelease
xcodebuild archive -workspace "VideoConference.xcworkspace" -scheme "VideoConference"  -configuration DevRelease -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/VideoConference.ipa VideoConferenceDev.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F  "file=@VideoConferenceDev.ipa"
