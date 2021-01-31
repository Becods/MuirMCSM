#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#          ┌─┐       ┌─┐
#       ┌──┘ ┴───────┘ ┴──┐
#       │                 │
#       │       ───       │
#       │  ─┬┘       └┬─  │
#       │                 │
#       │       ─┴─       │
#       │                 │
#       └───┐         ┌───┘
#           │         │ 看不懂别请骚扰我
#           │         │ 我水平也就这么烂
#           │         │ 怎么写是我的自由
#           │         └──────────────┐
#           │                        │
#           │                        ├─┐
#           │                        ┌─┘
#           │                        │
#           └─┐  ┐  ┌───────┬──┐  ┌──┘
#             │ ─┤ ─┤       │ ─┤ ─┤
#             └──┴──┘       └──┴──┘ 
dir=`pwd`
Server_Name=$1
action=$2

for file in `ls $dir"/module/"`;do #就是防止你权限没设对
	chmod +x $dir"/module/"$file
done

. $dir"/module/function"
init

if [ -z $Server_Name ]; then
    UseMenu="1" && MainMenu
elif [ $Server_Name == "web" ]; then
	Web_control
else
	UseMenu="0" && Server_List
fi
