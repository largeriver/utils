#! /bin/bash
function check(){
        host=$1;port=$2;prog=$3
        nc -v -z  -w 10 $host $port

        if [ $? -ne 0 ]; then
                echo "`date +%D_%H:%M:%S`: restart $prog ......"
                supervisorctl restart $prog
        fi
}

#services=('kvm.andjoin.com 2222 sshkvm','kvm.andjoin.com 2224 sshkvm')
#for svc in ${services[@]}; do
#    echo $svc
#done

# use with crontab: 0,30 * * * *  /home/pi/bin/check_sshsvc.sh kvm.andjoin.com 2222  sshkvm  1>>/tmp/checksshkvm.log 2>&1

check $1 $2 $3

