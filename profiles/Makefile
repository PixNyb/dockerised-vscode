DOCKERFILES := $(wildcard Dockerfile.*)

.PHONY: all $(DOCKERFILES)
all: $(DOCKERFILES)

$(DOCKERFILES):
	@IMAGE_NAME=`basename $@` ; \
    mkdir -p code ; \
    mkdir -p code-insiders ; \
	sed 's/%image%/code/g' $@ > code/$$IMAGE_NAME ; \
	sed 's/%image%/code:insiders/g' $@ > code-insiders/$$IMAGE_NAME

.PHONY: clean
clean:
	@rm -f code/Dockerfile.* code-insiders/Dockerfile.*