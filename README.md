<div align="center">

# MuirMCSM

_✨ 基于 Shell 的 Minecraft 服务端控制工具 ✨_

</div>

---

## Usage
- 修改`mc`中的`dir`变量
- `vi .config`
- `chmod +x ./mc&&./mc`
- Enjoy!

## Config
1.参数说明
```
Server_Path="" #服务端路径 [必须] 
User="mc" #服务端运行用户 [必须] 
check_time_out="1200" #这里填写重启脚本超时时间，单位1/10秒 [必须]
WebPort=8080 #网页控制台端口

Server_Java=8 #服务器Java版本，可选hotspot8/11/16 openj98/11/16 zulu8/11/16 dragonwell8/11
Server_Jar="Example*.jar" #服务端文件名,可用通配符 [必须] 
Server_memMin="2048M" #最小占用内存 [必须] 
Server_memMax="16384M" #最大占用内存 [必须] 
Server_pre="" #服务端启动前置参数
Server_suf="" #服务端启动后置参数
Server_Classpath="" #用户定义的类和包
Server_MainClass="" #服务端的主类

Group="true" #是否为群组服
Velocity_MysqlFix="true" #是否要给Velocity打个Mysql的连接器补丁
```

2.单端
```
Example(){
	Server_Jar="Example*.jar"
	Server_memMin="2048M"
	Server_memMax="16384M"
}
```

3.群组服
群组服请将主服的Group设置为true，并使用 <主服务器名>.<字服务器名> 命名规则命名

一级菜单将会仅显示群组服主服名，二级菜单将会显示该主服下所有子服
```
Example_Group(){ #主服名
	Server_Jar="Example*.jar"
	Server_memMin="2048M"
	Server_memMax="16384M"
	Group="true" #是否为群组服
}

Example_Group.lobby(){ #子服名
	Server_Jar="Example*.jar"
	Server_memMin="2048M"
	Server_memMax="16384M"
}
```

## Project
- Docker
- 全模块化 (是的没错现在伪模块化只是方便区分功能)
- 优化亿下代码

## Used open source projects
- [ttyd](https://github.com/tsl0922/ttyd)

## License
[GPL-3.0 License](https://github.com/BecodReyes/MuirMCSM/blob/master/LICENSE) © [BecodReyes](https://github.com/BecodReyes)