#! /bin/bash
function check(){
        host=$1;port=$2;prog=$3
        nc -v -z  -w 10 $host $port

        if [ $? -ne 0 ]; then
                echo "!!!restart $prog"
                supervisorctl restart $prog
        fi
}

#services=('kvm.andjoin.com 2222 sshkvm','kvm.andjoin.com 2224 sshkvm')
#for svc in ${services[@]}; do
#    echo $svc
#done
check $1 $2 $3

