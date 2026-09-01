DOCKER_IMAGE := python:3.11-slim

DOCKER_RUN = docker run --rm -v $(PWD):/app -w /app $(DOCKER_IMAGE) bash -c

DOCKER_PREPARE = apt-get update -qq && apt-get install -y -qq make git > /dev/null && \
	git config --global --add safe.directory /app && \
	pip install -q --upgrade pip wheel setuptools && \
	pip install -q -r requirements-dev.txt

format:
	$(DOCKER_RUN) '$(DOCKER_PREPARE) && make format-local'

format-local:
	black .
	isort --skip-gitignore .

lint:
	$(DOCKER_RUN) '$(DOCKER_PREPARE) && make lint-local'

lint-local:
	black --check .
	isort --check --skip-gitignore .
	flake8 --inline-quotes '"'
	pylint $(shell git ls-files '*.py')
	PYTHONPATH=/ mypy --namespace-packages --show-error-codes . --check-untyped-defs --ignore-missing-imports --show-traceback

dep-vulnerabilities:
	$(DOCKER_RUN) '$(DOCKER_PREPARE) && make dep-vulnerabilities-local'

dep-vulnerabilities-local:
	pip-audit

build:
	docker build -t yandex-tracker-action .
