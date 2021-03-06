SHELL := /bin/bash 
VERSION = $(shell sed 's/^__version__ = "\(.*\)"/\1/' ./tempo/version.py)

.PHONY: install
install:
	pip install -e .

install-dev:
	pip install -r requirements-dev.txt

.PHONY: test
test: tempo
	pytest tempo

fmt:
	black ./ --exclude "(mlops/metadata/|.eggs|.tox)"


.PHONY: lint
lint:
	flake8 .

.PHONY: mypy
mypy:
	mypy .

tempo/metadata/grpc_core_service.proto:
	wget https://raw.githubusercontent.com/triton-inference-server/server/master/docs/protocol/grpc_core_service.proto -O tempo/metadata/grpc_core_service.proto

install-rclone:
	curl https://rclone.org/install.sh | sudo bash

build-protos: tempo
	cd tempo && python \
	-m grpc.tools.protoc \
	-I./ \
	-I./metadata/ \
	--python_out=./ \
	--grpc_python_out=./ \
	--mypy_out=./ \
	./metadata/grpc_core_service.proto


.PHONY: tempo/tests/examples
tempo/tests/examples:
	mkdir -p tempo/tests/examples
	cd tempo/tests/examples && \
		gsutil cp -r gs://seldon-models/sklearn . && \
		gsutil cp -r gs://seldon-models/xgboost . && \
		gsutil cp -r gs://seldon-models/mlflow . && \
		gsutil cp -r gs://seldon-models/keras . && \
		gsutil cp -r gs://seldon-models/tfserving .


clean_test_data:
	rm -rf tempo/tests/examples


build: clean
	python setup.py sdist bdist_wheel

clean:
	rm -rf ./dist ./build *.egg-info

push-test:
	twine upload --repository-url https://test.pypi.org/legacy/ dist/*

push:
	twine upload dist/*


version:
	@echo ${VERSION}
