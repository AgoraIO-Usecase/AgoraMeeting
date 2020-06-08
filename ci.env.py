#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys

def main():
    os.system("pod install")
    agoraAppId = sys.argv[1]
    agoraAuth = sys.argv[2]
    agoraHost = sys.argv[3]
    
    f = open("./VideoConference/KeyCenter.m", 'r+')
    content = f.read()
    agoraAppIdString = "@\"" + agoraAppId + "\""
    agoraAuthString = "@\"" + agoraAuth + "\""
    
    contentNew = re.sub(r'<#Your Agora App Id#>', agoraAppIdString, content)
    contentNew = re.sub(r'<#Your Authorization#>', agoraAuthString, contentNew)

    f.seek(0)
    f.write(contentNew)
    f.truncate()
    
    f = open("./Modules/AgoraRoom/AgoraRoom/BaseManager/HTTP/URL.h", 'r+')
    content = f.read()
    agoraHostString = agoraHost
    
    contentNew = re.sub(r'https://api.agora.io/scenario', agoraHostString, content)

    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
