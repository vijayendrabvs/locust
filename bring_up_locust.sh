#!/bin/bash
set -x

if [ $# -lt 1 ]; then
	echo "Usage: $0 <target_ip:target_port>"
	exit 1
fi

target=$1

num_cpus=`cat /proc/cpuinfo | grep processor | wc -l`

if [ $num_cpus -lt 2 ]; then
	echo "Only 1 core found, tests may not get the cycles they need."
fi

# Bring up a master locust container.

echo "Removing locust_master if present"

docker stop locust_master
docker rm locust_master

docker run -d --cpus $num_cpus --name locust_master -p 8089:8089 -p 5557:5557 --volume `pwd`:/mnt/locust -e LOCUSTFILE_PATH=/mnt/locust/locustfile.py -e TARGET_URL=http://$target -e LOCUST_OPTS="--master" lnplocust:v1
sleep 1

#locust_master_ip=`docker inspect locust_master | grep "IPAddress" | grep -v "Secondary" | head -1 | tr -d ' ' | cut -d':' -f2 | tr -d ',' | tr -d '"'`
locust_master_ip=`ifconfig eth0 | grep inet | head -1 | tr -s ' ' | cut -d' ' -f3`

echo "locust master's IP is: $locust_master_ip"

for n in `seq $num_cpus`; do
	slave_name="locust_slave_$n"
	echo "Removing locust slave $slave_name"
	docker rm -f $slave_name
	echo "Spinning up locust slave"
	docker run -d --name $slave_name --cpus $num_cpus --volume `pwd`:/mnt/locust -e LOCUSTFILE_PATH=/mnt/locust/locustfile.py -e TARGET_URL=http://$target -e LOCUST_OPTS="--clients=1 -r 1 --slave --master-host=$locust_master_ip" lnplocust:v1
done
