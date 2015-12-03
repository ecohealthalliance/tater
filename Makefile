all: help

help:
	@echo ""
	@echo "make:"
	@echo "      model   - Run model unit tests"
	@echo "      test    - Run end-to-end tests"
	@echo "      devtest - Perform a single test"
	@echo "      install - Install required tools" # TODO: include brew, node and npm installations
	@echo "      data    - Copy production database to local machine"
	@echo "      build   - Compile tater into binaries"
	@echo "      docker  - Build the docker image"
	@echo ""

model:
	spacejam test-packages packages/models/

test:
	VELOCITY_CI=1 CHIMP_OPTIONS="--browser=chrome --chai --sync=false" meteor --test

devtest:
	CHIMP_OPTIONS="--tags=@dev --browser=chrome --chai --sync=false" meteor

install:
	npm install -g spacejam

data:
	./scripts/restore_database

build:
	rm -fr build/
	meteor build build --directory --architecture os.linux.x86_64

docker:
	docker build -t tater .
