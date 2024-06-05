DOCKERFILE := .Dockerfile.template
DOTNET_VERSIONS := 6.0 7.0 8.0

.PHONY: all
all:
	@for version in $(DOTNET_VERSIONS); do \
		OUTPUT_FILE="Dockerfile.$$version" ; \
		sed "s/%dotnet-version%/$$version/g" $(DOCKERFILE) > $$OUTPUT_FILE ; \
	done

.PHONY: clean
clean:
	@for version in $(DOTNET_VERSIONS); do \
		rm -f Dockerfile.$$version ; \
	done