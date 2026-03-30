.DEFAULT_GOAL := build-package

.PHONY: help
help: ## Display this help screen
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: clean-build clean-test clean-pyc ## Clean project

.PHONY: clean-build
clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	rm -fr .mypy_cache
	rm -fr .ruff_cache
	rm -rf .py-build-cmake_cache
	find . -name '*.egg-info' -not -path '.venv/*' -exec rm -fr {} +
	find . -name '*.egg' -not -path '.venv/*' -exec rm -f {} +

.PHONY: clean-pyc
clean-pyc:
	find . -name '*.pyc' -not -path '.venv/*' -exec rm -f {} +
	find . -name '*.pyo' -not -path '.venv/*' -exec rm -f {} +
	find . -name '*~' -not -path '.venv/*' -exec rm -f {} +
	find . -name '__pycache__' -not -path '.venv/*' -exec rm -fr {} +

.PHONY: clean-test
clean-test:
	rm -fr .tox/
	rm -fr .nox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

.PHONY: build-library
build-library: clean ## Build shared library
	cmake -B build .
	cmake --build build --parallel

.PHONY: build-package
build-package: clean ## Build python package
	uv build

.PHONY: tests
tests: clean-test ## Run pytest
	uvx nox

.PHONY: build-ca
build-ca: ## Create Test CA
	sudo /opt/cprocsp/bin/amd64/genkpim 2 00000001 /var/opt/cprocsp/dsrf/
	sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -add cpsd -name 'cpsd rng' -level 3
	sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -configure cpsd -add string /db1/kis_1 /var/opt/cprocsp/dsrf/db1/kis_1
	sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -configure cpsd -add string /db2/kis_1 /var/opt/cprocsp/dsrf/db2/kis_1
	sudo /opt/cprocsp/bin/amd64/csptest -minica -root -dn "CN=Test Root" -provtype 80 -until 3650
	sudo /opt/cprocsp/bin/amd64/csptest -minica -leaf -dn "CN=Test User" -provtype 80 -issuer "CN=Test Root" -until 3650
	sudo /opt/cprocsp/bin/amd64/csptest -minica -crl -fcrl tests/certs/test.crl -issuer "CN=Test Root" -until 3650
	sudo cp -r /var/opt/cprocsp tests/certs/cprocsp
	sudo cp -r /etc/opt/cprocsp tests/certs/etc/opt
	sudo mv test.crl tests/certs
	sudo chown -R $(whoami): tests/certs

.PHONY: install-ca
install-ca:	## Install Test CA
	sudo cp -r tests/certs/cprocsp /etc/opt/cprocsp 
	sudo cp -r tests/certs/cprocsp /var/opt

