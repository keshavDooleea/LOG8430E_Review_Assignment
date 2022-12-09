# LOG8430E_Review_Assignment

## Directory structure

1. targetDB: 

- generic script file in root
- 3 sub databases folders: mongodb, redis, orientdb. In each folder, we have the docker-compose file of the database as well as 6 folders for the workload (a to f). In each workload folder, we have 2 sub folders: /load: one to save the load files and /run: one to save the run output files

2. ycsb-0.17.0: YCSB release directory

3. Average_Benchmark_Results.xlsx: Excel file containing our average benchmark results and charts 


## Benchmarking Script instructions

Navigate to targetDB folder.
To run the script, three arguments must be passed:

1. -d : refers to the database. Options are mongodb | redis | orientdb
2. -w : workload alphabet. Options are a | b | c | d | e | f
3. -e : execution number. Options are 1 | 2 | 3 but can be anything. It's just a number to concatenate to the output file.


- Example 1:

This following command will execute the benchmark on mongodb database with the workloada and will save the result in /targetDB/mongodb/workload_a/run/output_run_a_1.txt

```
./script.sh -d mongodb -w a -e 1
```


- Example 2:

To perform 3 benchmarking processes for mongodb based on workloada, three commands need to be run one after another like so:

```
./script.sh -d mongodb -w a -e 1
./script.sh -d mongodb -w a -e 2
./script.sh -d mongodb -w a -e 3
```
