echo ">>>>>start date:`date`"
echo cmd=$@
ret=1
count=0
while true;do
	echo -e "\n*****try $count times*****\n"
	#repo sync -j8
	$@
	if [ $? -eq 0 ]; then
		break
	else
		sleep 10
		let count=$count+1
	fi
done
echo "<<<<<end date:`date`" 
