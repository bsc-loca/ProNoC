my_passwd="amonemi@epi1423" 


server1="amonemi@epi01.bsc.es"
server2="amonemi@epi02.bsc.es"
server3="amonemi@epi03.bsc.es"

servers=( $server1 $server2 $server3 )

function login_in_server {
	sshpass -p amonemi@epi1423 ssh  -o "StrictHostKeyChecking no" -X amonemi@epi03.bsc.es
	source /eda/env.sh
	export PATH=$PATH:/opt/verilator/bin
	cd ~/pronoc_verify/mpsoc/verify
}

