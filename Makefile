all: help

help:
	@echo ""
	@echo "make:"
	@echo "      model   - Run model unit tests"
	@echo "      test    - Run end-to-end tests"
	@echo "      devtest - Perform a single test"
	@echo "      install - Install required tools and components"
	@echo "      tika    - Start a local Tika server to enable document parsing"
	@echo "      data    - Copy production database to local machine"
	@echo "      build   - Compile tater into binaries"
	@echo "      docker  - Build the docker image"
	@echo ""

model:
	spacejam test-packages packages/models/

test:
	TAGS=~@ignore ./.scripts/run-tests.sh

devtest:
	TAGS=@dev ./.scripts/run-tests.sh

install:
	curl https://install.meteor.com | sh
	xcode-select –install
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew install node
	npm -g install

tika:
	@if [ ! -e "tika-server.jar" ]; then \
		curl -L h http://mirror.cc.columbia.edu/pub/software/apache/tika/tika-server-1.11.jar > tika-server.jar; \
	fi
	java -jar tika-server.jar &

data:
	./.scripts/restore_database

build:
	rm -fr build/
	meteor build build --directory --architecture os.linux.x86_64

docker:
	docker build -t tater .
