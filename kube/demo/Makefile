.DEFAULT_GOAL := help

LINT_DIR ?= .

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "[32m%-40s[0m %s\n", $$1, $$2}'

.PHONY: lint-staging
lint-staging: ## Lint
	helm lint $(LINT_DIR) -f $(LINT_DIR)/values.yaml -f $(LINT_DIR)/values-staging.yaml

.PHONY: lint-production
lint-production: ## Lint
	helm lint $(LINT_DIR) -f $(LINT_DIR)/values.yaml -f $(LINT_DIR)/values-production.yaml

.PHONY: manifest-staging
manifest-staging: ## Lint
	helm template $(LINT_DIR) -f $(LINT_DIR)/values.yaml -f $(LINT_DIR)/values-staging.yaml > $(LINT_DIR)/manifest-staging.yaml

.PHONY: manifest-production
manifest-production: ## Lint
	helm template $(LINT_DIR) -f $(LINT_DIR)/values.yaml -f $(LINT_DIR)/values-production.yaml > $(LINT_DIR)/manifest-production.yaml