DOCKERFILE := .Dockerfile.template
JAVA_VERSIONS := 8 11 17 21

.PHONY: all
all:
	@for version in $(JAVA_VERSIONS); do \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%java-version%/$$version/g" $(DOCKERFILE) > $$OUTPUT_FILE ; \
	done

.PHONY: clean
clean:
	@for version in $(JAVA_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
	done