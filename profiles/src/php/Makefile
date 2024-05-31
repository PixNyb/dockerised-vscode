DOCKERFILE := .Dockerfile.template
PHP_VERSIONS := 7.2 7.3 7.4 8.0 8.1 8.2 8.3

.PHONY: all
all:
	@for version in $(PHP_VERSIONS); do \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%php-version%/$$version/g" $(DOCKERFILE) > $$OUTPUT_FILE ; \
	done

.PHONY: clean
clean:
	@for version in $(PHP_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
	done