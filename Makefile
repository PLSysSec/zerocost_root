.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=zerocost_testing_sandbox rlbox_mpk_sandbox zerocost_testing_firefox

CURR_DIR := $(shell realpath ./)

bootstrap:
	if [ -x "$(shell command -v apt)" ]; then \
		sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm; \
	elif [ -x "$(shell command -v dnf)" ]; then \
		sudo dnf -y install curl cmake msr-tools cpuid cpufrequtils npm; \
	else \
		echo "Unknown installer. apt/dnf not found"; \
		exit 1; \
	fi
	touch ./bootstrap

zerocost_testing_sandbox:
	git clone git@github.com:PLSysSec/zerocost_testing_sandbox.git $@

rlbox_mpk_sandbox:
	git clone git@github.com:PLSysSec/rlbox_mpk_sandbox.git $@

zerocost_testing_firefox:
	git clone git@github.com:PLSysSec/zerocost_testing_firefox.git $@

get_source: $(DIRS)

pull: $(DIRS)
	git pull
	cd zerocost_testing_sandbox && git pull
	cd rlbox_mpk_sandbox && git pull
	cd zerocost_testing_firefox && git pull

build: get_source
	cd zerocost_testing_firefox && \
	MOZCONFIG=mozconfig_fullsave_release ./mach build && \
	MOZCONFIG=mozconfig_mpkfullsave_release ./mach build && \
	MOZCONFIG=mozconfig_zerocost_release ./mach build && \
	MOZCONFIG=mozconfig_regsave_release ./mach build && \
	MOZCONFIG=mozconfig_stock_release ./mach build && \
	echo "Done"

build_debug: get_source
	cd zerocost_testing_firefox && \
	MOZCONFIG=mozconfig_fullsave_debug ./mach build && \
	MOZCONFIG=mozconfig_mpkfullsave_debug ./mach build && \
	MOZCONFIG=mozconfig_zerocost_debug ./mach build && \
	MOZCONFIG=mozconfig_regsave_debug ./mach build && \
	MOZCONFIG=mozconfig_stock_debug ./mach build && \
	echo "Done"

benchmark:
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

clean:
	-rm -rf ./ff_builds

