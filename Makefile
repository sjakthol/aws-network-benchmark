# Mapping from long region names to shorter ones that is to be
# used in the stack names
AWS_eu-north-1_PREFIX = en1
AWS_eu-west-1_PREFIX = ew1

# Some defaults
AWS ?= aws
AWS_REGION ?= eu-north-1
AWS_ACCOUNT_ID = $(eval AWS_ACCOUNT_ID := $(shell $(AWS_CMD) sts get-caller-identity --query Account --output text))$(AWS_ACCOUNT_ID)
AWS_CMD := $(AWS) --region $(AWS_REGION)

STACK_REGION_PREFIX := $(AWS_$(AWS_REGION)_PREFIX)-network-benchmark
STACK_SUFFIX ?=

TAGS ?= Deployment=$(STACK_REGION_PREFIX)

define stack_template =

deploy-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation package \
		--template-file $(1) \
		--s3-bucket $(AWS_ACCOUNT_ID)-$(AWS_REGION)-build-resources \
		--s3-prefix $(STACK_REGION_PREFIX) \
		--output-template-file $(1).packaged

	$(AWS_CMD) cloudformation deploy \
		--stack-name $(STACK_REGION_PREFIX)-$(basename $(notdir $(1)))$(STACK_SUFFIX) \
		--tags $(TAGS) \
		--parameter-overrides StackNamePrefix=$(STACK_REGION_PREFIX) $(EXTRA_PARAMETERS) \
		--template-file $(1).packaged \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(STACK_REGION_PREFIX)-$(basename $(notdir $(1)))$(STACK_SUFFIX)


endef

$(foreach template, $(wildcard stacks/*.yaml), $(eval $(call stack_template,$(template))))

DOCKER = docker

build:
	$(DOCKER) build -t iperf-server .

tag: build
	$(DOCKER) tag iperf-server $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/iperf-server

push: tag
	$(DOCKER) push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/iperf-server

benchmark-fargate:
ifndef $(or MEMORY, CPU)
	$(error Missing arguments. Must define CPU= and MEMORY= to run benchmark!)
endif
	@echo "Starting benchmark for Fargate task with $(CPU) CPU and $(MEMORY) memory units..."
	$(MAKE) deploy-fargate STACK_SUFFIX="-$(CPU)-$(MEMORY)" EXTRA_PARAMETERS="Cpu=$(CPU) Memory=$(MEMORY)"

	@echo "Benchmark complete. Cleaning up..."
	$(MAKE) delete-fargate STACK_SUFFIX="-$(CPU)-$(MEMORY)"

	@echo "All done!"

benchmark-fargate-all: benchmark-fargate-256-512 benchmark-fargate-256-1024 benchmark-fargate-256-2048 benchmark-fargate-512-1024 benchmark-fargate-512-2048 benchmark-fargate-512-4096 benchmark-fargate-1024-2048 benchmark-fargate-1024-4096 benchmark-fargate-1024-8192 benchmark-fargate-2048-4096 benchmark-fargate-2048-8192 benchmark-fargate-2048-16384 benchmark-fargate-4096-8192 benchmark-fargate-4096-16384 benchmark-fargate-4096-30720
benchmark-fargate-subset: benchmark-fargate-256-512 benchmark-fargate-512-1024 benchmark-fargate-1024-2048 benchmark-fargate-2048-4096 benchmark-fargate-4096-8192

benchmark-fargate-256-512:
	$(MAKE) benchmark-fargate CPU=256 MEMORY=512
benchmark-fargate-256-1024:
	$(MAKE) benchmark-fargate CPU=256 MEMORY=1024
benchmark-fargate-256-2048:
	$(MAKE) benchmark-fargate CPU=256 MEMORY=2048

benchmark-fargate-512-1024:
	$(MAKE) benchmark-fargate CPU=512 MEMORY=1024
benchmark-fargate-512-2048:
	$(MAKE) benchmark-fargate CPU=512 MEMORY=2048
benchmark-fargate-512-4096:
	$(MAKE) benchmark-fargate CPU=512 MEMORY=4096

benchmark-fargate-1024-2048:
	$(MAKE) benchmark-fargate CPU=1024 MEMORY=2048
benchmark-fargate-1024-4096:
	$(MAKE) benchmark-fargate CPU=1024 MEMORY=4096
benchmark-fargate-1024-8192:
	$(MAKE) benchmark-fargate CPU=1024 MEMORY=8192

benchmark-fargate-2048-4096:
	$(MAKE) benchmark-fargate CPU=2048 MEMORY=4096
benchmark-fargate-2048-8192:
	$(MAKE) benchmark-fargate CPU=2048 MEMORY=8192
benchmark-fargate-2048-16384:
	$(MAKE) benchmark-fargate CPU=2048 MEMORY=16384

benchmark-fargate-4096-8192:
	$(MAKE) benchmark-fargate CPU=4096 MEMORY=8192
benchmark-fargate-4096-16384:
	$(MAKE) benchmark-fargate CPU=4096 MEMORY=16384
benchmark-fargate-4096-30720:
	$(MAKE) benchmark-fargate CPU=4096 MEMORY=30720

benchmark-lambda:
ifndef $(or MEMORY)
	$(error Missing arguments. Must define MEMORY= to run Lambda benchmark!)
endif
	@echo "Starting benchmark for Lambda function with $(MEMORY) memory units..."
	$(MAKE) deploy-lambda STACK_SUFFIX="-$(MEMORY)" EXTRA_PARAMETERS="Memory=$(MEMORY)"

	@echo "Invoking Lambda function with $(MEMORY) memory units"
	$(AWS_CMD) --cli-read-timeout 910 lambda invoke --function-name $(STACK_REGION_PREFIX)-lambda-$(MEMORY)-function /dev/stdout

	@echo "Cleaning up"
	$(MAKE) delete-lambda STACK_SUFFIX="-$(MEMORY)"

benchmark-lambda_all: benchmark-lambda-128 benchmark-lambda-256 benchmark-lambda-512 benchmark-lambda-1024 benchmark-lambda-1792 benchmark-lambda-2048 benchmark-lambda-3008 benchmark-lambda-10240
benchmark-lambda-128:
benchmark-lambda-256:
benchmark-lambda-512:
benchmark-lambda-1024:
benchmark-lambda-1792:
benchmark-lambda-2048:
benchmark-lambda-3008:
benchmark-lambda-10240:

benchmark-lambda-%:
	$(MAKE) benchmark-lambda MEMORY=$*
