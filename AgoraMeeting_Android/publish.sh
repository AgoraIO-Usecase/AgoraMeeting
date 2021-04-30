#!/bin/sh

function exePublish() {
  echo "1:$1, 2:$2"
  moduleName="$1"
  relativePath="$2"

  absPath="$(pwd)/${relativePath}"

  if [ -a "${absPath}" ]; then
    ./gradlew :${moduleName}:publish
    else
    echo "the ${moduleName} module path no exist ------ ${absPath}"
  fi
}

function main() {
    exePublish "rte"            "common-scene-sdk/Android/AgoraRte/rte"
    exePublish "statistic"      "Tools/AgoraSceneStatistic-Android/statistic"
    exePublish "whiteboard"     "whiteboard"
    exePublish "screensharing"  "screensharing"
    exePublish "meeting-core"   "meeting-core"
    exePublish "meeting-ui"     "meeting-ui"
}

main