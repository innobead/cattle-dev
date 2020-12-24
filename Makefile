.PHONY: help
help:
	@grep -E '^[a-zA-Z%_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: package
package: ## Package tar.gz & build container image
	$(CURDIR)/hack/build-image.sh
	$(CURDIR)/hack/build-tar.sh
