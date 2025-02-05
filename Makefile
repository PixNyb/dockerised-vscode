MAKEFILES := $(shell find profiles/src -type f -name Makefile)
EXCLUDED := \
	profiles/src/tex/Dockerfile \
	profiles/src/php/Dockerfile.7.2 \
	profiles/src/php/Dockerfile.7.2-node \
	profiles/src/php/Dockerfile.7.3 \
	profiles/src/php/Dockerfile.7.3-node \
	profiles/src/php/Dockerfile.7.4 \
	profiles/src/php/Dockerfile.7.4-node \
	profiles/src/php/Dockerfile.8.0 \
	profiles/src/php/Dockerfile.8.0-node

define DOCKERFILES =
$(shell find profiles/src -type f -name Dockerfile*)
endef

define SCRIPT_FOLDERS =
$(shell find profiles/src -type d -name scripts)
endef

define TEMPLATE_FOLDERS =
$(shell find profiles/src -type d -name templates)
endef

.PHONY: all
all: run-makefiles generate-dockerfiles export-scripts export-templates generate-json

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

.PHONY: export-scripts
export-scripts:
	@for dir in $(call SCRIPT_FOLDERS); do \
        PROFILE_PATH=`dirname $$dir` ; \
        PROFILE_NAME=`basename $$PROFILE_PATH` ; \
		mkdir -p profiles/dist/code/bin/$$PROFILE_NAME ; \
		mkdir -p profiles/dist/code-insiders/bin/$$PROFILE_NAME ; \
		cp -r $$dir/* profiles/dist/code/bin/$$PROFILE_NAME ; \
		cp -r $$dir/* profiles/dist/code-insiders/bin/$$PROFILE_NAME ; \
	done

.PHONY: export-templates
export-templates:
	@for dir in $(call TEMPLATE_FOLDERS); do \
		PROFILE_PATH=`dirname $$dir` ; \
		PROFILE_NAME=`basename $$PROFILE_PATH` ; \
		mkdir -p profiles/dist/code/templates/$$PROFILE_NAME ; \
		mkdir -p profiles/dist/code-insiders/templates/$$PROFILE_NAME ; \
		cp -r $$dir/* profiles/dist/code/templates/$$PROFILE_NAME ; \
		cp -r $$dir/* profiles/dist/code-insiders/templates/$$PROFILE_NAME ; \
	done

.PHONY: generate-json
generate-json:
	@echo "[" > profiles/dist/manifest.json; \
	for file in $(DOCKERFILES); do \
		echo $$file; \
		EXCLUDE=0; \
		for exclude in $(EXCLUDED); do \
			if [ "$$file" = "$$exclude" ]; then \
				EXCLUDE=1; \
				break; \
			fi; \
		done; \
		if [ "$$EXCLUDE" -eq 0 ]; then \
			PROFILE_PATH=`dirname $$file` ; \
			PROFILE_NAME=`basename $$PROFILE_PATH` ; \
			PROFILE_VERSION=`basename $$file | sed 's/Dockerfile//g'` ; \
			PROFILE_TAG=$$PROFILE_NAME ; \
			if [ "$$PROFILE_VERSION" != "" ]; then \
				PROFILE_VERSION=`echo $$PROFILE_VERSION | sed 's/\.//'` ; \
				PROFILE_TAG=$$PROFILE_TAG-$$PROFILE_VERSION ; \
			fi ; \
			echo "\"$$PROFILE_TAG\"," >> profiles/dist/manifest.json; \
		fi; \
	done; \
	sed -i '$$ s/.$$//' profiles/dist/manifest.json; \
	echo "]" >> profiles/dist/manifest.json

.PHONY: clean
clean:
	@rm -rf profiles/dist
	@for file in $(MAKEFILES); do \
		make -C $$(dirname $$file) clean; \
	done