#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
import os
import re


def main():
    appId = sys.argv[1]
    customId = sys.argv[2]
    customCer = sys.argv[3]

    # if need reset
    f = open('./app/src/main/res/values/string_configs.xml', 'r+')
    content = f.read()

    contentNew = content
    contentNew = re.sub(r'<#YOUR APP ID#>', appId, contentNew)
    contentNew = re.sub(r'<#YOUR CUSTOM ID#>', customId, contentNew)
    contentNew = re.sub(r'<#YOUR CUSTOM CER#>', customCer, contentNew)

    f.seek(0)
    f.write(contentNew)
    f.truncate()

if __name__ == "__main__":
    main()
