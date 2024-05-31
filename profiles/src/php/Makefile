DOCKERFILE := .Dockerfile.template
NODE_DOCKERFILE := .Dockerfile.node.template
PHP_VERSIONS := 7.2 7.3 7.4 8.0 8.1 8.2 8.3
NODE_VERSIONS := 14 18 22

.PHONY: all
all:
	@for version in $(PHP_VERSIONS); do \
		case $$version in \
			5.5 | 5.6 | 7.0 | 7.1) \
				XDEBUG=xdebug-2.5.5 \
				;; \
			7.2 | 7.3 | 7.4 | 8.0) \
				XDEBUG=xdebug-2.9.8 \
				;; \
			8.1 | 8.2 | 8.3 | 8.4) \
				XDEBUG=xdebug \
				;; \
		esac ; \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%php-version%/$$version/g" $(DOCKERFILE) | sed "s/%xdebug%/$$XDEBUG/g" > $$OUTPUT_FILE ; \
		for node_version in $(NODE_VERSIONS); do \
			OUTPUT_FILE="Dockerfile.$$version-node-$$node_version" ; \
			sed "s/%php-version%/$$version/g" $(NODE_DOCKERFILE) | sed "s/%node-version%/$$node_version/g" | sed "s/%xdebug%/$$XDEBUG/g" > $$OUTPUT_FILE ; \
		done ; \
	done

.PHONY: clean
clean:
	@for version in $(PHP_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
		for node_version in $(NODE_VERSIONS); do \
			rm -f Dockerfile.$$version-node-$$node_version ; \
		done ; \
	done