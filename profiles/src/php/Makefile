DOCKERFILE := .Dockerfile.template
NODE_DOCKERFILE := .Dockerfile.node.template
PHP_VERSIONS := 7.2 7.3 7.4 8.0 8.1 8.2 8.3

.PHONY: all
all:
	@for version in $(PHP_VERSIONS); do \
		case $$version in \
			5.5 | 5.6 | 7.0 | 7.1) \
				XDEBUG=xdebug-2.5.5 \
				;; \
			7.2 | 7.3 | 7.4) \
				XDEBUG=xdebug-2.9.8 \
				;; \
			8.0 | 8.1 | 8.2 | 8.3) \
				XDEBUG=xdebug-3.3.2 \
				;; \
		esac ; \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%php-version%/$$version/g" $(DOCKERFILE) | sed "s/%xdebug%/$$XDEBUG/g" > $$OUTPUT_FILE ; \
		OUTPUT_FILE="Dockerfile.$$version-node" ; \
		sed "s/%php-version%/$$version/g" $(NODE_DOCKERFILE) | sed "s/%xdebug%/$$XDEBUG/g" > $$OUTPUT_FILE ; \
	done

.PHONY: clean
clean:
	@for version in $(PHP_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
		rm -f Dockerfile.$$version-node ; \
	done