个人的一些小脚本和工具代码整理

# utils

* sysinfo.sh 系统信息
* decompress 多格式解压脚本
* whoseport 打印出使用某个端口的进程PID,也可以使用lsof -i:<port>
* proxychains proxychains 默认会将系统代理与自己的代理配置组成多级代理。这个脚本取消系统代理，仅使用代理配置。
* neighbour.py 显示指定文件的指定行的上下几行。

# android
* my\_envsetup.sh 在当前目录中支持jgrep/cgrep/segrep/mgrep/sgrep。参照AOSP 中 build/envsetup.sh来实现。
	* 安装：`echo source my\_envsetup.sh >> ~/.bashrc`
* pushmm    将mm编译的文件直接推送到开发手机的对应位置
	* 要求: 按照脚本中的说明，修改build/envsetup.sh中的mm命令
* segrep    当前ANDROID项目sepolicy文件的**多关键字grep**,支持**全匹配/部分匹配**
* mkgrep 	当前目录**多关键字grep**，支持**全匹配/部分匹配**，可以指定需要搜索的文件类型
* pylosf.py 通过adb 查询手机上某个pid的信息 

# private
* mergepatch.sh <patchfile/patchpath> [commnit info]

