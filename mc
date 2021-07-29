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
dir="/home/mc/control" #脚本位置
Server_Name=$1
action=$2

for file in `ls $dir"/module/"`;do #就是防止你权限没设对
	chmod +x $dir"/module/"$file
done

. $dir"/module/function"
init

if [ -z $1 ]; then
    UseMenu="1" && MainMenu
elif [ $1 == "web" ]; then
	Web_control
elif [ $1 == "action" ]; then
	$2
else
	UseMenu="0" && Server_List
fi
