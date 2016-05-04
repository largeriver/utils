#! /bin/bash
#The scripts will return the system infomation
#return hostname and version infomation  // 返回主机名和系统版本信息
echo -e "\e[31;43m***** HOSTNAME INFOMATION *****\e[0m"
hostname
uname -r
cat /proc/version
echo -e "\e[31;43m***** Linux Release Version INFOMATION *****\e[0m"
lsb_release -a
echo ""
#File system disk space usage            // 文件系统磁盘可用空间
echo -e "\e[31;43m***** File System Disk Space usage INFOMATION *****\e[0m"
df -h
echo ""
#Idie time system and use of memory    //系统空闲和使用中的内存
echo -e "\e[31;43m***** Idie system And use of memory infomation *****\e[0m"
free
echo ""
#system start time                    //系统启动时间
echo -e "\e[31;43m***** System start time INFOMATION *****\e[0m"
uptime
echo ""
#User logged on                        //登录的用户
echo -e "\e[31;43m***** User logged on INFOMATION *****\e[0m"
who
echo ""
#Use memory up to five processes        //使用内存最多的五个进程
echo -e "\e[31;43m***** Use memory up to five processes INFOMATION *****\e[0m"
ps -eo %mem,%cpu,comm --sort=-%mem | head -n 6
echo ""
echo -e "\e[1;32mDone.\e[0m"

