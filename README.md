Network performance benchmarks for AWS Fargate and AWS Lambda.

## Results (Fargate)

Here are some results from benchmarks performed on eu-west-1 and eu-north-1
regions on 2020-05-17. See [analysis/2020/results.ipynb](analysis/2020/results.ipynb)
for more detailed graphs.

### eu-west-1

|vCPU|Memory (MB)|Baseline (Gbps)|Burst (Gbps)|Burst Duration (seconds)|
|----|-----------|---------------|------------|------------------------|
|0.25|512        |0.254          |0.850       |80                      |
|0.25|1024       |0.254          |0.849       |80                      |
|0.25|2048       |0.254          |0.841       |80                      |
|0.5 |1024       |0.620          |0.620       |-                       |
|0.5 |2048       |0.620          |0.620       |-                       |
|0.5 |4096       |1.240          |1.241       |-                       |
|1   |2048       |0.620          |0.620       |-                       |
|1   |4096       |1.240          |1.240       |-                       |
|1   |8192       |0.745          |10.093      |270                     |
|2   |4096       |1.240          |1.240       |-                       |
|2   |8192       |0.745          |10.093      |290                     |
|2   |16384      |0.694          |0.695       |-                       |
|4   |8192       |0.744          |0.744       |-                       |
|4   |16384      |0.694          |0.695       |-                       |
|4   |30720      |0.694          |0.695       |-                       |

Observations:

* All tasks have very stable baseline performance.
  * Bigger tasks seem to have slightly faster network.
* Some tasks are able to burst up-to 10 Gbps.
  * Most tasks are not able to burst beyond baseline capacity.


### eu-north-1

| vCPU | Memory (MB) | Baseline (Gbps) | Burst (Gbps) | Burst Duration (seconds) |
|------|-------------|-----------------|--------------|--------------------------|
| 0.25 | 512         | 0.254           | 4.974        | 630                      |
| 0.25 | 1024        | 0.254           | 4.974        | 480                      |
| 0.25 | 2048        | 0.254           | 4.974        | 540                      |
| 0.5  | 1024        | 0.509           | 4.974        | 1050                     |
| 0.5  | 2048        | 0.509           | 4.974        | 930                      |
| 0.5  | 4096        | 0.509           | 4.974        | 940                      |
| 1    | 2048        | 0.745           | 10.039       | 350                      |
| 1    | 4096        | 0.745           | 10.039       | 270                      |
| 1    | 8192        | 0.745           | 10.039       | 260                      |
| 2    | 4096        | 0.745           | 10.039       | 300                      |
| 2    | 8192        | 0.745           | 10.039       | 290                      |
| 2    | 16384       | 1.243           | 10.039       | 580                      |
| 4    | 8192        | 1.243           | 10.039       | 550                      |
| 4    | 16384       | 1.243           | 10.039       | 430                      |
| 4    | 30720       | 1.243           | 10.039       | 490                      |

Observations:

* Tasks with < 1 vCPU are able to burst to 5 Gbps.
  * Length of burst depends primarily on CPU allocation.
  * Length is a bit longer for containers with largest possible memory allocation for a vCPU configuration.
* Tasks with >= 1 vCPUs are able to burst to 10 Gbps
  * Length of burst depends on CPU & Memory allocation
  * Tasks with largest memory allocation get slightly longer burst.
  * Length of burst is shorter than that of smaller containers (but has 2x more bandwidth)
* Network performance is much better than in eu-west-1.
  * Burst capacity is available for all containers sizes.
  * Baseline capacity increases linearly as the container grows (except for the biggest containers)


## Results (Lambda)

Here are some results from benchmarks performed on eu-west-1 and eu-north-1
regions on 2024-06-15. See [analysis/2024/results-lambda.ipynb](analysis/2024/results-lambda.ipynb)
for more detailed graphs.

### eu-west-1

| Memory (MB) | Baseline (Gbps) | Burst (Gbps) | Burst Duration (seconds) |
|-------------|-----------------|--------------|-------------------------|
| 128         | 0.597           | 2.109        | 0                       |
| 256         | 0.618           | 2.691        | 0                       |
| 512         | 0.611           | 2.735        | 0                       |
| 1024        | 0.611           | 2.740        | 0                       |
| 1792        | 0.611           | 2.738        | 0                       |
| 2048        | 0.609           | 2.752        | 0                       |
| 3008        | 0.600           | 2.750        | 0                       |


### eu-north-1

| Memory (MB) | Baseline (Gbps) | Burst (Gbps) | Burst Duration (seconds) |
|-------------|-----------------|--------------|-------------------------|
| 128         | 0.596           | 2.043        | 0                       |
| 256         | 0.614           | 2.675        | 0                       |
| 512         | 0.612           | 2.742        | 0                       |
| 1024        | 0.609           | 2.739        | 0                       |
| 1792        | 0.604           | 2.740        | 0                       |
| 2048        | 0.607           | 2.732        | 0                       |
| 3008        | 0.568           | 2.749        | 0                       |

### Observations

* Lambda functions have a stable 600 Mbps network throughput with a small burst to 2.7 Gbps in the beginning
* Burst throughput has increased from 1.7 Gbps (2020) to 2.7 Gbps (2024)
* No differences between regions

## Running Benchmarks (Fargate)

### Prerequisites

You must have the following setup to be able to run these benchmarks:
* AWS credentials with admin level privileges
* AWS account with VPC and Subnets from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).
* Docker

Once setup, you can deploy the benchmark infra (ECR, ECS, Roles, Security Groups, Log Groups) by running

```bash
make deploy-infra
```

in this directory. Once the ECR registry has been created, you'll need to build the Docker image
used for benchmarks:

```bash
make build tag push
```

### Execute Benchmarks

Use one of the benchmark targets from the Makefile to execute benchmarks:

```bash
make benchmark-fargate-512-1024 # benchmark of Fargate container with 0.5vCPU and 1GB memory
```

The targets will create a Fargate task of specified size, execute the benchmark
and delete the resources used in the benchmark.

## Running Benchmarks (Lambda)

### Prerequisites

You must have the following setup to be able to run these benchmarks:
* AWS credentials with admin level privileges
* AWS account with VPC and Subnets from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).
* Docker

Once setup, you can deploy the benchmark infra (ECR, ECS, Roles, Security Groups, Log Groups) by running

```bash
make deploy-infra
```

in this directory. Once done, you'll need to prepare the Lambda function by running

```bash
(cd lambda && make lib)
```

Finally, you'll need to deploy the iperf3 server run running
```bash
make deploy-lambda-server
```

### Execute Benchmarks

Use one of the benchmark targets from the Makefile to execute benchmarks:

```makefile
make benchmark-lambda-512 # benchmark of Lambda function 512 MB of memory
make benchmark-lambda_all # benchmark different configs one by one
```

The targets will create a Lambda function of specified size, execute the benchmark
and delete the resources used in the benchmark.

### Clean up

Delete the iperf3 server by running
```
make delete-lambda-server
```

## How it Works?

This project uses [iperf3](https://iperf.fr/) to measure network performance.

For Fargate, we package an iperf3 server into a Docker container, deploy the
container as a Fargate task and create an EC2 instance to execute iperf3 client
against the iperf3 server in Fargate. Benchmarks configure iperf3 client to use
10 connections to execute a 15 minute benchmark in reverse mode (server sends the
data to the client, not the other way around).

For Lambda, we package an iperf3 client into a Lambda function, deploy an iperf3
server into EC2 and execute iperf3 client in Lambda against an iperf3 server in
EC2. Benchmarks configure iperf3 client to use 1 connection to execute a 60 minute
benchmark (client sends data to server).

Benchmark results are saved to Amazon S3 as JSON with the output from iperf3
as well as some custom metadata from the execution.

## Credits

* https://github.com/widdix/ec2-network-benchmark

## License

MIT
