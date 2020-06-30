#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
import os
import re


def main():
    appId = sys.argv[1]
    auth = sys.argv[2]
    host = sys.argv[3]

    # if need reset
    f = open('./app/src/main/res/values/string_configs.xml', 'r+')
    content = f.read()

    contentNew = content
    contentNew = re.sub(r'<#YOUR APP ID#>', appId, contentNew)
    contentNew = re.sub(r'<#YOUR AUTH#>', auth, contentNew)

    f.seek(0)
    f.write(contentNew)
    f.truncate()

    # if need reset
    f = open('./app/build.gradle', 'r+')
    content = f.read()

    contentNew = content
    contentNew = re.sub(r'https://api.agora.io/scenario', host, contentNew)

    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
