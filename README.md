Network performance benchmarks for AWS Fargate.

## Running Benchmarks

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
make login build tag push
```

### Execute Benchmarks

Use one of the benchmark targets from the Makefile to execute benchmarks:

```makefile
make benchmark-fargate-512-1024 # benchmark of Fargate container with 0.5vCPU and 1GB memory
```

The targets will create a Fargate task of specified size, execute the benchmark
and delete the resources used in the benchmark.

## How it Works?

This project uses [iperf3](https://iperf.fr/) to measure network performance. It
packages an iperf3 server into a Docker container, deploys the container as a
Fargate task and creates an EC2 instance to execute iperf3 client against the
iperf3 server in Fargate.

Benchmarks configure iperf3 client to use 10 connections to execute a 15 minute
benchmark in reverse mode (server sends the data to the client, not the other
way around).

Benchmark results are saved to Amazon S3 as JSON with the output from iperf3
as well as some custom metadata from the execution.

## Credits

* https://github.com/widdix/ec2-network-benchmark

## License

MIT