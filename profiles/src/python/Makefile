DOCKERFILE := .Dockerfile.template
PYTHON_VERSIONS := 3

.PHONY: all
all:
	@for version in $(PYTHON_VERSIONS); do \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%python-version%/$$version/g" $(DOCKERFILE) > $$OUTPUT_FILE ; \
	done

.PHONY: clean
clean:
	@for version in $(PYTHON_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
	done