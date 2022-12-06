#!/bin/bash

# global variables
validDatabases=(mongodb redis orientdb)
workloadArray=(a b c d e f)
jmp="\n\n\n-------------------- "

echo -e ""

# ---------------------- STEP 1: VALIDATE SHELL PARAMETERS ------------------------
printParams() {
   echo ""
   echo "Usage: $0 -d database -w workloadAlphabet -e executionNb"
   echo -e "\t-d  database         : ${validDatabases[0]} | ${validDatabases[1]} | ${validDatabases[2]}"
   echo -e "\t-w  workloadAlphabet : a | b | c | d | e | f"
   echo -e "\t-e  executionNb      : 1 | 2 | 3"
   exit 1 # Exit script after printing help
}

while getopts "d:w:e:" opt
do
   case "$opt" in
      d ) db="$OPTARG" ;;
      w ) workload="$OPTARG" ;;
      e ) execution="$OPTARG" ;;
      ? ) printParams ;; # Print parameters in case parameter is non-existent
   esac
done

# Print parameters in case parameters are empty
if [ -z "$db" ] || [ -z "$workload" ] || [ -z "$execution" ]
then
   echo "Some or all of the parameters are empty";
   printParams
fi

# check if database is valid
if [[ ${validDatabases[*]} =~ (^|[[:space:]])"$db"($|[[:space:]]) ]]; then
    echo -e "Database    : $db";
else
    echo -e "Invalid database entered";
    printParams
fi

# check if workload is correct
if [[ ${workloadArray[*]} =~ (^|[[:space:]])"$workload"($|[[:space:]]) ]]; then
    echo -e "Workload    : $workload";
else
    echo -e "Invalid workload";
    printParams
fi

echo -e "Execution # : $execution"

# sets the YCSB arguments for individual databases
if [ $db = ${validDatabases[0]} ]; then
    # mongodb
    ycsbArgs="-p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003,mongo4:30004,mongo5:30005,mongo6:30006/?replicaSet=my-replica-set"
elif [ $db = ${validDatabases[1]} ]; then
    # redis
    ycsbArgs="-p "redis.host=172.31.26.51" -p "redis.port=6379" -p "redis.cluster=true""
else
    # orientdb
    ycsbArgs="-p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin"
fi






# ---------------------- STEP 2: BEGIN BENCHMARKING ------------------------

cd $db

# start docker
echo -e $jmp "Starting Docker"
docker-compose -f ./docker-compose-${db}.yml up -d

# wait for nodes
sleep_time=10
echo -e $jmp "Waiting for ${sleep_time} seconds"
sleep $sleep_time

cd ../../ycsb-0.17.0/

# load data
echo -e $jmp "Loading data"
./bin/ycsb.sh load $db -s -P workloads/workload"$workload" -p recordcount=1000 $ycsbArgs > ../targetDB/$db/workload_"$workload"/load/output_load_"$workload"_"$execution".txt

# execute workload
echo -e $jmp "Executing workload"
./bin/ycsb.sh run $db -s -P workloads/workload"$workload" -p recordcount=1000 $ycsbArgs > ../targetDB/$db/workload_"$workload"/run/output_run_"$workload"_"$execution".txt

# clean
echo -e $jmp "Cleaning"

cd ../targetDB/$db/
docker-compose -f docker-compose-${db}.yml down
sudo rm -rf data
