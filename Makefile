MAKEFILES := $(shell find profiles/src -type f -name Makefile)

define DOCKERFILES =
$(shell find profiles/src -type f -name Dockerfile*)
endef

.PHONY: all
all: run-makefiles generate-dockerfiles generate-json

.PHONY: run-makefiles
run-makefiles:
	@for file in $(MAKEFILES); do \
		make -C $$(dirname $$file); \
	done

.PHONY: generate-dockerfiles
generate-dockerfiles:
	@for file in $(call DOCKERFILES); do \
        PROFILE_PATH=`dirname $$file` ; \
        PROFILE_NAME=`basename $$PROFILE_PATH` ; \
        PROFILE_VERSION=`basename $$file | sed 's/Dockerfile//g'` ; \
        PROFILE_TAG=$$PROFILE_NAME ; \
        if [ "$$PROFILE_VERSION" != "" ]; then \
            PROFILE_VERSION=`echo $$PROFILE_VERSION | sed 's/\.//'` ; \
            PROFILE_TAG=$$PROFILE_TAG-$$PROFILE_VERSION ; \
        fi ; \
        mkdir -p profiles/dist/code profiles/dist/code-insiders ; \
        sed 's/%image%/code:latest/g' $$file > profiles/dist/code/Dockerfile.$$PROFILE_TAG ; \
        sed 's/%image%/code:insiders-latest/g' $$file > profiles/dist/code-insiders/Dockerfile.$$PROFILE_TAG ; \
    done

.PHONY: generate-json
generate-json:
	@echo "[" > profiles/dist/manifest.json; \
	for file in $(DOCKERFILES); do \
		PROFILE_PATH=`dirname $$file` ; \
		PROFILE_NAME=`basename $$PROFILE_PATH` ; \
		PROFILE_VERSION=`basename $$file | sed 's/Dockerfile//g'` ; \
		PROFILE_TAG=$$PROFILE_NAME ; \
		if [ "$$PROFILE_VERSION" != "" ]; then \
			PROFILE_VERSION=`echo $$PROFILE_VERSION | sed 's/\.//'` ; \
			PROFILE_TAG=$$PROFILE_TAG-$$PROFILE_VERSION ; \
		fi ; \
		echo "\"$$PROFILE_TAG\"," >> profiles/dist/manifest.json; \
	done; \
	sed -i '$$ s/.$$//' profiles/dist/manifest.json; \
	echo "]" >> profiles/dist/manifest.json

.PHONY: clean
clean:
	@rm -rf profiles/dist
	@for file in $(MAKEFILES); do \
		make -C $$(dirname $$file) clean; \
	done