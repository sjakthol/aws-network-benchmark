Network performance benchmarks for AWS Fargate and AWS Lambda.

## Results (Fargate)

Here are some results from benchmarks performed on eu-west-1 and eu-north-1
regions on 2024-06-15. See [analysis/2024/results.ipynb](analysis/2024/results.ipynb)
for more detailed graphs.

### eu-west-1

| vCPU | Memory (MB) | Baseline (Gbps) | Burst (Gbps) | Burst Duration (seconds)
|------|-------------|-----------------|--------------|-------------------------|
| 0.25 | 512         | 0.063           | 4.214        | 410                     |
| 0.25 | 1024        | 0.127           | 4.525        | 560                     |
| 0.25 | 2048        | 0.254           | 4.688        | 710                     |
| 0.50 | 1024        | 0.127           | 4.571        | 630                     |
| 0.50 | 2048        | 0.254           | 4.705        | 780                     |
| 0.50 | 4096        | 0.508           | 4.888        | 1000                    |
| 1.00 | 2048        | 0.254           | 4.577        | 730                     |
| 1.00 | 4096        | 0.508           | 4.895        | 1120                    |
| 1.00 | 8192        | 0.744           | 9.719        | 300                     |
| 2.00 | 4096        | 0.744           | 9.720        | 340                     |
| 2.00 | 8192        | 0.744           | 9.556        | 310                     |
| 2.00 | 16384       | 1.241           | 9.827        | 710                     |
| 4.00 | 8192        | 1.241           | 9.829        | 640                     |
| 4.00 | 16384       | 1.241           | 9.869        | 750                     |
| 4.00 | 30720       | 1.241           | 9.735        | 550                     |

Observations:

* Baseline performance seems to change based on allocated memory
  * With 1024 MB you get ~125 Mbps
  * With 2048 MB you get ~250 Mbps
  * With 4096 MB you get ~500 Mbps (1 vCPU or less) or ~750 Mbps (2 vCPUs)
  * With 8192 MB you get ~750 Mbps (2 vCPU or less) or ~1250 Mbps (4 vCPUs)
  * With 16 GB or 32 GB you get ~1250 Mbps
* Burst performance is either around 5 Gbps (smaller tasks) or 10 Gbps (larger tasks)
* Burst duration is longer for larger tasks (but not always)
* Performance is very similar to that in eu-north-1


### eu-north-1

| vCPU | Memory (MB) | Baseline (Gbps) | Burst (Gbps) | Burst Duration (seconds) |
|------|-------------|-----------------|--------------|-------------------------|
| 0.25 | 512         | 0.063           | 4.185        | 410                     |
| 0.25 | 1024        | 0.127           | 4.547        | 570                     |
| 0.25 | 2048        | 0.254           | 4.683        | 920                     |
| 0.50 | 1024        | 0.127           | 4.584        | 540                     |
| 0.50 | 2048        | 0.254           | 4.738        | 820                     |
| 0.50 | 4096        | 0.508           | 4.819        | 900                     |
| 1.00 | 2048        | 0.254           | 4.706        | 920                     |
| 1.00 | 4096        | 0.508           | 4.782        | 1080                    |
| 1.00 | 8192        | 0.744           | 9.720        | 310                     |
| 2.00 | 4096        | 0.775           | 11.802       | 260                     |
| 2.00 | 8192        | 0.744           | 9.720        | 350                     |
| 2.00 | 16384       | 1.241           | 9.729        | 660                     |
| 4.00 | 8192        | 1.241           | 9.828        | 710                     |
| 4.00 | 16384       | 1.241           | 9.827        | 700                     |
| 4.00 | 30720       | 1.241           | 9.747        | 710                     |

Observations:

* Baseline performance seems to change based on allocated memory
  * With 1024 MB you get ~125 Mbps
  * With 2048 MB you get ~250 Mbps
  * With 4096 MB you get ~500 Mbps (1 vCPU or less) or ~750 Mbps (2 vCPUs)
  * With 8192 MB you get ~750 Mbps (2 vCPU or less) or ~1250 Mbps (4 vCPUs)
  * With 16 GB or 32 GB you get ~1250 Mbps
* Burst performance is either around 5 Gbps (smaller tasks) or 10 Gbps (larger tasks)
* Burst duration is longer for larger tasks
* Performance is very similar to that in eu-west-1


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
| 10240*      | 0.580           | 2.696        | 0                       |

\* Benchmark with 10240 MB of memory was performed separately from others on 2024-07-22.

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
