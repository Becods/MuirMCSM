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
Server_Name=$1
action=$2

#载入配置
. $dir"/.config"


#============================== other ==============================#
WebPid(){ #查找服务器pid
WebPid=`ps -ef|grep ttyd|grep -iv 'grep\|screen'|awk '{print $2}'`
}

pid(){ #查找服务器pid
Pid=`ps -ef|grep "$Server_Path/"$Server_Name"/"|grep -iv 'grep\|screen'|awk '{print $2}'`
}

Back(){
if [[ $UseMenu -eq "1" ]];then
	echo -e "\n回车返回"&&read&& MainMenu
fi
}

WBack(){
if [[ $UseMenu -eq "1" ]];then
	echo -e "\n回车返回"&&read&&clear&&Web_Menu
fi
}

Permission_Check(){ #权限设置
	for file in `ls $dir"/module/"`;do
		chmod +x $dir"/module/"$file
	done
	clear
	logo
	echo -e "${Info}权限检查${Font_suffix}"
	if [ $action == "p-single" ];then
		chown -R $User $Server_Path"/"$Server_Name
		echo -e "${Info}${Server_Name} 权限设置完成！"
		sleep 2
		MainMenu
	elif [ $action == "permission" ];then
		echo "1. 全部服务器"
		echo "2. 单个服务器"
		echo "0. 返回主菜单"
		read PermissionChoice
		case "$PermissionChoice" in
			0)MainMenu;;
			1)action=all && clear && Permission_Check;;
			2)action=p-single && clear && Server_List;;
			*)echo -e "${Error} 请重新选择" && read && Permission_Check;;
		esac
	elif [ $action == "all" ];then
		for Server in $list;do
			chown -R $User $Server_Path"/"$Server
			echo -e "${Info}${Server} 权限设置完成！"
		done
		sleep 2
		MainMenu
	else
		echo -e "${Error} 传参错误，请检查参数是否正确！"
	fi
}
#============================== other ==============================#


#============================== web ==============================#
WebPid

Web_Start(){
if [ -z $WebPid ]; then
	echo -e "${Info}网页控制台 正在启动..."
	cd $dir
	screen=`ls /var/run/screen/S-root | grep ttyd | tr -cd "[0-9]"`
	if [ -z $screen ];then
		screen -dmS ttyd
	fi
	screen -x -S ttyd -p 0 -X stuff "$dir/module/ttyd -t titleFixed='MCServerConsole' -p $WebPort $dir/mc"
	screen -x -S ttyd -p 0 -X stuff $'\n'
	echo -e "${Info}网页控制台 启动信号发送成功！"
	echo -e "${Info}请使用 $WebPort 端口访问！"
else
	echo -e "${Info}网页控制台 正在运行！"
fi
WBack
}

Web_Stop(){
echo -e "${Red_font}[警告]${Font_suffix}停止网页控制台将会导致连接的用户断开，确认吗？[y/N]"
read Stop_Web
if [ -z `echo $Stop_Web|grep -i 'yes\|y'` ];then
	echo -e "${Info}操作已取消"
	WBack
else
	if [ -z $WebPid ]; then
		echo -e "${Error}网页控制台 未运行！"
	else
		echo -e "${Info}网页控制台 正在停止..."
		cd $dir
		screen -x -S ttyd -p 0 -X stuff "^c"
		usleep 200
		screen -x -S ttyd -p 0 -X stuff "exit"
		screen -x -S ttyd -p 0 -X stuff $'\n'
		echo -e "${Info}网页控制台停止信号发送成功！"
	fi
fi
}

Web_S(){
if [ -z $WebPid ]; then
	W_S="${Yellow_font}未运行！${Font_suffix}"
else
	if [[ $UseMenu -eq "1" ]];then
		W_S="${Green_font}正在运行${Font_suffix}\n   请使用 $WebPort 端口访问"
	else
		W_S="${Green_font}正在运行${Font_suffix}\n${Info}请使用 $WebPort 端口访问"
	fi
fi
}

Web_Status(){
Web_S
echo -e "${Info}网页控制台 $W_S"
WBack
}

Web_Restart(){
if [ -z $WebPid ]; then
	echo -e "${Error}网页控制台 未运行！"
else
	echo -e "${Info}网页控制台 正在重启..."
	screen -x -S ttyd -p 0 -X stuff "^c"
	usleep 200
	screen -x -S ttyd -p 0 -X stuff "$dir/module/ttyd -t titleFixed='MCServerConsole' -p $WebPort $dir/mc"
	screen -x -S ttyd -p 0 -X stuff $'\n'
	echo -e "${Info}网页控制台 重启信号发送成功！"
fi
WBack
}

Web_control(){
if [ -z $action ]; then
    Web_Menu
else
	case "$action" in
		start)Web_Start;;
		stop)Web_Stop;;
		restart)Web_Restart;;
		reload)Web_Restart;;
		status)Web_Status;;
		*)echo -e "${Error}参数错误，请使用：{start|stop|restart|reload|status}";;
	esac
fi
}
#============================== web ==============================#


#============================== control ==============================#
Server_Start(){ 
pid
if [ -z $Pid ]; then
	echo -e "${Info}${Server_Name} 正在启动..."
	su $User << BASH
cd $Server_Path"/"$Server_Name
screen -dmS $Server_Name $Server_Parameter
BASH
	echo -e "${Info}${Server_Name} 启动信号发送成功！"
else
	echo -e "${Info}${Server_Name} 正在运行！"
fi
Back
}

Server_Stop(){
pid
if [ -z $Pid ]; then
	echo -e "${Error}${Server_Name} 未运行！"
else
echo -e "${Info}${Server_Name} 正在停止..."
su $User << BASH
cd $Server_Path"/"$Server_Name
screen -x -S $Server_Name -p 0 -X stuff "^c"
BASH
echo -e "${Info}${Server_Name} 停止信号发送成功！"
fi
Back
}

Server_Status(){
pid
if [[ $UseMenu -eq "1" ]];then
	clear
	logo
fi
if [ -z $Pid ]; then
	echo -e "${Info}${Server_Name} 未运行！"
else
	echo -e "${Info}${Server_Name} 正在运行！"
fi
Back
}

Console(){
pid
if [[ $UseMenu -eq "1" ]];then
	clear
	logo
fi
if [ -z $Pid ]; then
	echo -e "${Info}${Server_Name} 未运行！"
	Back
else
	echo -e "${Info}请使用${Red_font}Ctrl+A+D${Font_suffix}以返回界面，否则将会直接结束服务器进程！"
	echo -e "按回车进入"&&read
	sudo -u $User screen -R $Server_Name
fi
}

Server_Restart(){
pid
if [ -z $Pid ]; then
	echo -e "${Error}${Server_Name} 未运行！"
else
	echo -e "${Info}${Server_Name} 正在重启..."
	su $User << BASH
	screen -x -S $Server_Name -p 0 -X stuff "^c"
BASH
	export Server_Name
	export Server_Parameter
	export Server_Path
	export dir
	nohup $dir"/module/restart" >/dev/null 2>&1 &
	#$dir"/module/restart"
	echo -e "${Info}${Server_Name} 重启信号发送成功！"
fi
Back
}
#============================== control ==============================#


#============================== menus ==============================#
MainMenu(){
	echo -ne "\033]0;MuirMCSM\007"
	clear&&logo
	echo -e "${Info}欢迎使用 MuirMCSM ${Powered}
   ${Yellow_font}1.${Font_suffix}开启服务器
   ${Yellow_font}2.${Font_suffix}关闭服务器
   ${Yellow_font}3.${Font_suffix}服务器状态
   ${Yellow_font}4.${Font_suffix}重启服务器
   ${Yellow_font}5.${Font_suffix}新建服务器
   ${Yellow_font}6.${Font_suffix}进入控制台
   ${Yellow_font}7.${Font_suffix}网页控制台
   ${Yellow_font}8.${Font_suffix}权限检查
   #${Yellow_font}9.${Font_suffix}在线玩家
   ${Yellow_font}0.${Font_suffix}退出脚本${Font_suffix}"
	read -p "请选择:" Menu_Choice
	case "$Menu_Choice" in
		q)clear && exit 1;;
		0)clear && exit 1;;
		1)action=start && clear && Server_List;;
		2)action=stop && clear && Server_List;;
		3)action=status && clear && Server_List;;
		4)action=restart && clear && Server_List;;
		5)action=new && clear && Server_List;;
		6)action=console && clear && Server_List;;
		7)action="" && clear && Web_control;;
		8)action=permission && clear && Permission_Check;;
		9)action=list && clear && Server_List;;
		r)$0;;
		*)echo -e "${Error}请重新选择, 回车返回" && read && MainMenu;;
	esac
}

Web_Menu(){
	if [ ! -f "/etc/MuirMCSM/ttyd" ]; then
		wget -O "/etc/MuirMCSM/ttyd" "https://cdn.muir.fun/ttyd"&&chmod +x "/etc/MuirMCSM/ttyd"&&clear
	fi
	Web_S&&logo
	echo -e "${Info}网页控制台 ${Powered}
   ${Yellow_font}1.${Font_suffix}开启网页控制台
   ${Yellow_font}2.${Font_suffix}关闭网页控制台
   ${Yellow_font}3.${Font_suffix}重启网页控制台
   ${Yellow_font}0.${Font_suffix}退出脚本${Font_suffix}

   网页控制台运行状态：$W_S"
	read -p "请选择:" Web_Choice
	echo ""
	case "$Web_Choice" in
		q)clear && exit 1;;
		0)clear && exit 1;;
		1)Web_Start;;
		2)Web_Stop;;
		3)Web_Restart;;
		r)$0;;
		*)echo -e "${Error}请重新选择, 回车返回" &&read&&clear&&Web_Menu;;
	esac
}
#============================== menus ==============================#


#============================== list ==============================#
Server_Not_Found(){
	echo -e "\n${Error}输入错误或${Server_Name}服务器不存在！"
	if [[ $UseMenu -eq "1" ]];then
		read -e "回车返回"
		clear
		Server_List
	else
		exit 0
	fi
}

Server_Check(){
	if [ -z "`list&&echo "$alist"|grep -w $Server_Name`" ];then #查找服务器是否存在
		Server_Not_Found
	else
		$Server_Name
	fi
}

Server_List(){
	if [[ $action == "web" ]];then
		clear&&Web_contorl
	elif [[ $UseMenu -eq "1" ]];then #判断是否是从菜单进来的
		logo
		echo -e "${Info}服务器选择${Font_suffix} ${Powered}"
		list&&echo "$list"|awk '{print FNR". "$0}' #打印数字，方便选择
		echo -e "q. 返回主菜单\n"
		read -p "请选择:" ServerChoice
		if [ "$ServerChoice" == "0" ]||[[ "$ServerChoice" == "q" ]];then
			MainMenu
		elif [[ "$ServerChoice" =~ ^[0-9]+$ ]];then
			Server_Name=`list&&echo "$list"|sed -n "${ServerChoice}p"|sed 's/ //g'`
			Server_Check
		else
			Server_Not_Found
		fi
	else
		Server_Check
	fi
	if [[ $UseMenu -eq "0" ]];then
		Server_Action
	elif [[ $Group == "true" ]];then
		Group_List
	else
		Server_Action
	fi
}
#============================== list ==============================#


#============================== group ==============================#
Group_List(){
clear&&logo
echo -e "${Info}服务器选择 - ${Server_Name}群组服${Font_suffix} ${Powered}"
list&&echo "$glist"|awk '{print FNR". "$0}'
if [[ $action != "console" ]];then
echo -e "a. 全选\n"
fi
echo -e "q. 返回主菜单\n"
read -p "请选择:" GServerChoice
if [ "$GServerChoice" == "0" ]||[[ "$GServerChoice" == "q" ]];then
	MainMenu
elif [ "$GServerChoice" == "a" ];then
	Group_All
elif [[ "$GServerChoice" =~ ^[0-9]+$ ]];then
	Server_Name=`list&&echo "$glist"|sed -n "${GServerChoice}p"|sed 's/ //g'`
	Server_Check
	Server_Action
else
	Server_Not_Found
fi
}

Group_All(){
if [[ $UseMenu -eq "1" ]];then
	clear
	logo
	UseMenu=0
	for i in $glist;do
		Server_Name=$i
		Server_Check
		Server_Action
	done
	UseMenu=1
	Back
else
	for i in $glist;do
		Server_Name=$i
		Server_Check
		Server_Action
	done
fi
}
#============================== group ==============================#


#============================== install ==============================#
install_test(){
	if [[ -n `command -V curl|grep "not found"` ]];then
		echo -e "${Error}Curl安装失败"
		exit 1
	fi
	if [[ -n `command -V wget|grep "not found"` ]];then
		echo -e "${Error}wget安装失败"
		exit 1
	fi
	if [[ -n `command -V screen|grep "not found"` ]];then
		echo -e "${Error}screen安装失败"
		exit 1
	fi
	install_ok
}

install_ok(){
	clear
	if [ ! -d "/etc/MuirMCSM" ]; then
		mkdir "/etc/MuirMCSM"
	fi
cat << EOF > /etc/MuirMCSM/config
Server_Path="/home/server" #这里填写你的服务端路径
User="mc" #这里填写服务端运行用户
check_time_out="1200" #这里填写重启脚本超时时间，单位1/10秒
WebPort=8080 #网页控制台端口

#模板：普通服务器
Example(){ #服务器名
	Server_Jar="Example*.jar" #服务端文件名,可用通配符
	Server_memMin="2048M" #最小占用内存
	Server_memMax="16384M" #最大占用内存
	Server_pre="" #服务端启动前置参数
	Server_suf="" #服务端启动后置参数
}

#群组服务器 主控端
Example_Group(){ #服务器名
	Server_Jar="Example*.jar"
	Server_memMin="2048M"
	Server_memMax="16384M"
	Server_pre=""
	Server_suf=""
	Group="true" #是否为群组服
}

#群组服务器 子服
Example_Group.lobby(){ #子服务器名
	Server_Jar="Example*.jar" #服务端文件名,可用通配符
	Server_memMin="2048M" #最小占用内存
	Server_memMax="16384M" #最大占用内存
	Server_pre="" #服务端启动前置参数
	Server_suf="" #服务端启动后置参数
}
EOF
	logo
	echo -e "${Info}恭喜安装完成！"
	echo -e "${Info}请前往/etc/MuirMCSM/config进行配置"
	read -p "待您配置完成后，回车即可进入主菜单"
	$0
}

install(){
	clear
	check_sys&&logo
	echo -ne "\033]0;MuirMCSM安装中\007"
	echo -e "${Info}欢迎使用 MuirMCSM ${Powered}
${Info}检测到您是首次使用 MuirMCSM , 现在为您安装前置程序"
	echo -ne "\033]0;MuirMCSM安装中\007"
	if [[ $release == "centos" ]];then
		yum install screen curl wget -y
		install_test
	elif [[ $release == "debian" ]]||[[ $release == "ubuntu" ]];then
		apt-get install screen curl wget -y
		install_test
	else
		echo -e "${Error}MuirMCSM当前不支持您的系统！"
		echo -e "${Info}请复制下列信息提交至Issues"
		echo -e "==========^/proc/version^=========="
		cat /proc/version
		echo -e "==========^lsb_release -a^=========="
		lsb_release -a
		echo -e "==========^release^=========="
		cat /etc/*-release
		exit
	fi
}
#============================== install ==============================#


#============================== function ==============================#
Server_StartCommand(){ #服务器启动命令
Server_P1=" -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
-XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \
-XX:-OmitStackTraceInFastThrow -XX:+AlwaysPreTouch -XX:G1MaxNewSizePercent=40 \
-XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5"
Server_P2=" -XX:G1MixedGCCountTarget=8 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 \
-XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=true -Daikars.new.flags=true \
-server -Xms"$Server_memMin" -Xmx"$Server_memMax" \
-jar "$Server_Path"/"$Server_Name"/"$Server_Jar" nogui "
Server_Parameter="java $Server_pre$Server_P1$Server_P2$Server_suf" #合成
}

check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#screen用户目录
run="/var/run/screen/S-"$User

#字符颜色
Green_font="\033[32m"
Yellow_font="\033[33m"
Red_font="\033[31m"
Black_font="\033[30m"
Font_suffix="\033[0m"
Info="[${Green_font}Info${Font_suffix}] "
Error="[${Red_font}Error${Font_suffix}] "
Powered="${Black_font}Powered by Becod${Font_suffix}"

list(){
alist=`sed 's/#/\n#/g' $dir"/.config"|sed '/#/d'|grep '(){'|sed 's/(){//g'`
if [[ $Group == "true" ]];then
	glist=`echo "$alist"|grep $Server_Name`
fi
list=`echo "$alist"|grep -v '\.'`
}

Server_Action(){
Server_StartCommand
case "$action" in
	start)Server_Start;;
	stop)Server_Stop;;
	status)Server_Status;;
	reload)Server_Restart;;
	restart)Server_Restart;;
	console)Console;;
	p-single)Permission_Check;;
	list)no_function;;
	*)echo -e "${Error}参数错误\c"
	if [[ $UseMenu -eq "1" ]];then
		sleep 1
		MainMenu
	else
		echo "，请使用：{start|stop|restart|reload|status}"
	fi;;
esac
}

no_function(){ #功能未定义
echo -e "${Error}功能未实现！"
if [[ $UseMenu -eq "1" ]];then
	sleep 1
	MainMenu
fi
}

logo(){
echo -e "--------------------------------------------
   __  ___     _     __  ______________  ___
  /  |/  /_ __(_)___/  |/  / ___/ __/  |/  /
 / /|_/ / // / / __/ /|_/ / /___\ \/ /|_/ / 
/_/  /_/\_,_/_/_/ /_/  /_/\___/___/_/  /_/ 

 Copyright 2021 Becod_ All rights reserved.
--------------------------------------------"
}

trap "" HUP INT TSTP
#============================== function ==============================#


if [ ! -f "/etc/MuirMCSM/config" ]; then
	install
else
	. /etc/MuirMCSM/config
fi
if [ -z $1 ]; then
    UseMenu="1" && MainMenu
elif [ $1 == "web" ]; then
	Web_control
else
	UseMenu="0" && Server_List
fi
