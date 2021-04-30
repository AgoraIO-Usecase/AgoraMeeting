#!/bin/sh
function getApkVersionName(){
  apkPath=$1
  apkanalyzerPath="${HOME}/Library/Android/sdk/cmdline-tools/latest/bin/apkanalyzer"
  versionName=$(${apkanalyzerPath} --human-readable manifest version-name ${apkPath})
  echo versionName
}

function getApkAppId(){
  apkPath=$1
  apkanalyzerPath="${HOME}/Library/Android/sdk/cmdline-tools/latest/bin/apkanalyzer"
  appId=$(${apkanalyzerPath} --human-readable manifest application-id ${apkPath})
  echo "${appId}"
}

function getApkVersionName(){
  apkPath=$1
  apkanalyzerPath="${HOME}/Library/Android/sdk/cmdline-tools/latest/bin/apkanalyzer"
  versionName=$(${apkanalyzerPath} --human-readable manifest version-name ${apkPath})
  echo "$(echo ${versionName})"
}

function getCurrentTime() {
  echo "$(date "+%m%d%H%M")"
}

function copyFile(){
  fromPath=$1
  toPath=$2
  mkdir -p $(dirname ${toPath}) && cp "${fromPath}" "${toPath}"
}

function parseJson(){
  echo "$1" | sed "s/\"//g" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

function splitValue(){
  key=$1
  content=$2
  echo $content | grep $key | cut -d'=' -f2 | sed 's/\r//'
}

function localProp(){
  cat local.properties | grep $1 | cut -d'=' -f2 | sed 's/\r//'
}

function setCompileDependencies() {
   isCompile=$1
   if [ $isCompile = "true" ]; then
      sed -ie 's#compileDependencies=false#compileDependencies=true#g' settings.gradle
   else
      sed -ie 's#compileDependencies=true#compileDependencies=false#g' settings.gradle
   fi
}

function copyApkRelease(){
  releaseDirPath=$1
  finalDirPath=$2

  outApkPath="${releaseDirPath}/apk/release/app-release.apk"
  finalApkName="$(echo $(getApkAppId ${outApkPath}) | sed 's/\./_/g')_$(getCurrentTime)_$(echo $(getApkVersionName ${outApkPath}) | sed 's/\./_/g')"
  copyFile "$outApkPath" "${finalDirPath}/${finalApkName}.apk"
  copyFile "${releaseDirPath}/mapping/release/mapping.txt" "${finalDirPath}/${finalApkName}_mapping.txt"
  export apkPath="${finalDirPath}/${finalApkName}.apk"
  export mappingPath="${finalDirPath}/${finalApkName}_mapping.txt"
}

function publish2Maven() {
  echo ">>> BUILDING: publish2Maven start"
  setCompileDependencies true
  ./publish.sh
  echo ">>> BUILDING: publish2Maven end"
}

function buildApk() {
  echo ">>> BUILDING: buildApk start"
  setCompileDependencies false
  ./gradlew :app:assembleRelease
  setCompileDependencies true
  copyApkRelease 'app/build/outputs' 'build/release'
  echo ">>> BUILDING: buildApk end"
}

function uploadBuglySymbol(){
  echo ">>> BUILDING: uploadBuglySymbol start"
  enableUpload=$(localProp 'bugly.symbol.upload')
  appId=$(localProp 'bugly.app.id')
  appKey=$(localProp 'bugly.app.key')
  bundleId=$(getApkAppId $apkPath)
  productVersion=$(getApkVersionName $apkPath)
  fileName=$(basename $mappingPath)
  echo "enableUpload=$enableUpload"
  echo "apkPath=$apkPath"
  echo "mappingPath=$mappingPath"
  echo "appId=$appId"
  echo "appKey=$appKey"
  echo "bundleId=$bundleId"
  echo "productVersion=$productVersion"

  if [[ $enableUpload = "true" ]] ; then
    curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=${appKey}&app_id=${appId}" \
    --form "api_version=1" \
    --form "app_id=${appId}" \
    --form "app_key=${appKey}" \
    --form "symbolType=1" \
    --form "bundleId=${bundleId}" \
    --form "fileName=$fileName" \
    --form "productVersion=${productVersion}" \
    --form "file=@${mappingPath}" \
    --verbose
  fi
  echo ">>> BUILDING: uploadBuglySymbol end"
}

function publish2Fir(){
  echo ">>> BUILDING: publish2Fir start"
  enable=$(localProp 'publish.fir.enable')
  type="android"
  bundleId=$(getApkAppId $apkPath)
  apiToken=$(localProp 'publish.fir.token')
  file=$apkPath
  xName="AgoraMeeting"
  xVersion=$(getApkVersionName $apkPath)
  xBuild=3

  echo "enable=$enable"
  echo "type=$type"
  echo "bundleId=$bundleId"
  echo "apiToken=$apiToken"
  echo "file=$file"
  echo "xName=$xName"
  echo "xVersion=$xVersion"

  if [[ $enable = "true" ]] ; then
    echo "requesting......"
    curl "http://api.bq04.com/apps/latest/$bundleId?api_token=$apiToken" > tmp.txt
    xBuild=$(($(parseJson "$(cat tmp.txt)" 'build') + 1))
    echo "xBuild=$xBuild"

    echo "requesting......"
    curl -X "POST" "http://api.bq04.com/apps" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"$type\", \"bundle_id\":\"$bundleId\", \"api_token\":\"$apiToken\"}" \
    > tmp.txt
    uploadUrl=$(parseJson "$(cat tmp.txt)" 'upload_url')
    qiniuKey=$(parseJson "$(cat tmp.txt)" 'key')
    qiniuToken=$(parseJson "$(cat tmp.txt)" 'token')
    echo "uploadUrl=$uploadUrl"
    echo "qiniuKey=$qiniuKey"
    echo "qiniuToken=$qiniuToken"
    echo ""

    echo "uploading......"
    curl -F "key=$qiniuKey" \
    -F "token=$qiniuToken" \
    -F "file=@$file" \
    -F "x:name=$xName" \
    -F "x:version=$xVersion" \
    -F "x:build=$xBuild" \
    "https://up.qbox.me"

    rm tmp.txt
    echo ""
  fi
  echo ">>> BUILDING: publish2Fir end"
}

function main() {
  startTime=$(date +%s)
  echo ">>> BUILD START: $startTime"
  publish2Maven
  buildApk
  uploadBuglySymbol
  publish2Fir
  endTime=$(date +%s)
  echo ">>> BUILD COMPLETE: Time consuming $(($endTime-$startTime))s"
}

main