#!/usr/bin/env bash


function usage(){
cat <<USAGE
usage: 
 $0 <patchdir>|<zipfile> [commit info]
 examples:
   $0 patch21.zip  fix bugs
   $0 /data/patch21.zip  fix bugs
   $0 patch21      fix some bugs
USAGE
}

# 本程序功能
#    自动解压zip文件
#    自动svn add 新文件
#    自动检查是否有文件存在漏加
#    svn 提交

# SVN提交目录
SVNDIR=/home/berg/Work/prj_H1/trunk
# SVN验证目录
SVNDIR2=/home/berg/Work/svnRepos/prj_H1/trunk


#参数解析
test -z $1 && { usage; exit 1; }
case $1 in
    -h|--help) usage;exit 0;;
    *.zip)  PATCHZIP=$1;
            PATCH=$(basename ${PATCHZIP%.zip}) ; 
            test ! -f $PATCHZIP && { echo "zip $PATCHZIP not exists"; exit 1; } ;
            test ! -d $PATCH && unzip $PATCHZIP ;;
    *)      PATCH=$1 ;
            test ! -d $PATCH && { echo "dir $PATCH not exists"; exit 1; } ;;
esac
echo -e "\n>>>Files in $PATCH:"
find  $PATCH -type f
echo -e "\n"

#display info
cp patch*.zip -fuv /Public/H1/src/
cd $SVNDIR && svn update &&  cd -

echo -e "\n>>>Press any key to COPY FILES ... " && read c

#copy files
echo -e "\n>>>Copying files ...." 
#srcpath=$PATCH/branch/temp/CU55C61/TSYSTEM
srcpath=$PATCH/branch/CU55C61/TSYSTEM
test -d $srcpath/android && cp -frv $srcpath/android/* $SVNDIR/H1_SECU/sources/android/
test -d $srcpath/modem   && cp -frv $srcpath/modem/* $SVNDIR/H1_SECU/sources/modem/

#srcpath=$PATCH/branch/temp/CU55C61/ASYSTEM
srcpath=$PATCH/branch/CU55C61/ASYSTEM
test -d $srcpath/android && cp -frv $srcpath/android/* $SVNDIR/H1_OPEN/sources/android/
test -d $srcpath/modem &&   cp -frv $srcpath/modem/* $SVNDIR/H1_OPEN/sources/modem/

#svn commit
echo -e "\n>>>检查svn 状态 ...."
cd $SVNDIR && svn status

#对新文件调用 svn add
svn status|grep '?'|cut -c2-|xargs -I "{}" svn add  "{}"

svn_status=`svn status`
if [ -z "$svn_status" ]; then
	echo -e ">>>看起来没什么文件需要提交呢 ..."
	exit 0
fi

echo -e "\n>>>Press any key to SVN COMMIT ... " && read c
echo -e "\n>>>svn commit -m merge $@"

echo merged $@ > commit.log
svn commit -F ./commit.log
rm ./commit.log

echo -e "\n>>>本次代码提交的详细信息 ..."
svn update
svn log -l 1 -v  #显示最后一次代码提交的详细信息

#svn verify
#验证是否有文件遗漏
cd $SVNDIR2 && svn update
diff -q -r $SVNDIR{,2}/H1_OPEN/sources -r 
diff -q -r $SVNDIR{,2}/H1_SECU/sources -r
