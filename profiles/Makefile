DOCKERFILES := $(wildcard Dockerfile.*)

.PHONY: all $(DOCKERFILES)
all: $(DOCKERFILES)

$(DOCKERFILES):
	@IMAGE_NAME=`basename $@` ; \
    mkdir -p code ; \
    mkdir -p code-insiders ; \
	sed 's/%image%/code:latest/g' $@ > code/$$IMAGE_NAME ; \
	sed 's/%image%/code:insiders-latest/g' $@ > code-insiders/$$IMAGE_NAME

.PHONY: clean
clean:
	@rm -f code/Dockerfile.* code-insiders/Dockerfile.*