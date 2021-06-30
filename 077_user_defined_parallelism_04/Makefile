#
# Copyright (c) 2021 Xavier R. Guérin xguerin@users.noreply.github.com
# 
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

DOCKER_NAMESPACE ?= $(USER)
DOCKER_REGISTRY ?= localhost:5000

APP_NAME ?= UDP4
NAMESPACE?= com.acme.test

lower_app_name=`echo $(APP_NAME) | tr A-Z a-z`

SPLC_FLAGS = -a
SPL_CMD_ARGS ?= 

BUILD_TYPE ?= x86_64.debug

.PHONY: all clean 

all: app

clean:
	@rm -rf build toolkit.xml

ifeq ($(DOCKER),)

app : $(NAMESPACE)/$(APP_NAME).spl
	@docker run -it --rm \
		-v $(PWD):$(PWD):rw \
		-v $(HOME)/.m2:/home/builder/.m2:rw \
		$(DOCKER_REGISTRY)/$(DOCKER_NAMESPACE)/streams-runtime:6.$(BUILD_TYPE) \
		doas $(shell id -u) $(shell id -g) $(PWD) \
		make app


else

app : $(NAMESPACE)/$(APP_NAME).spl
	@$(STREAMS_INSTALL)/bin/sc \
		$(SPLC_FLAGS) \
		--output-dir=build/$(lower_app_name)  \
		-M $(NAMESPACE)::$(APP_NAME) \
		$(SPL_CMD_ARGS)
	@echo ""
	@echo "Generating :  $(lower_app_name).yaml"
	@echo "To submit application : kubectl apply -f $(lower_app_name).yaml"
	@echo ""

	@echo "apiVersion: streams.ibm.com/v1"> $(lower_app_name).yaml
	@echo "kind: Job" >> $(lower_app_name).yaml
	@echo "metadata:" >> $(lower_app_name).yaml
	@echo "   name: $(lower_app_name)" >> $(lower_app_name).yaml
	@echo "spec:" >> $(lower_app_name).yaml
	@echo  "   bundle:" >> $(lower_app_name).yaml
	@echo  "      name: $(NAMESPACE).$(APP_NAME).sab" >> $(lower_app_name).yaml
	@echo  "      file:" >> $(lower_app_name).yaml
	@echo  "         path: \"./build/$(lower_app_name)/$(NAMESPACE).$(APP_NAME).sab\"" >> $(lower_app_name).yaml

endif
