.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=zerocost_testing_sandbox rlbox_mpk_sandbox zerocost_testing_firefox

CURR_DIR := $(shell realpath ./)

zerocost_testing_sandbox:
	git clone git@github.com:PLSysSec/zerocost_testing_sandbox.git $@

rlbox_mpk_sandbox:
	git clone git@github.com:PLSysSec/rlbox_mpk_sandbox.git $@

zerocost_testing_firefox:
	git clone git@github.com:PLSysSec/zerocost_testing_firefox.git $@

get_source: $(DIRS)

bootstrap: get_source
	if [ -x "$(shell command -v apt)" ]; then \
		sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm; \
	elif [ -x "$(shell command -v dnf)" ]; then \
		sudo dnf -y install curl cmake msr-tools cpuid cpufrequtils npm; \
	elif [ -x "$(shell command -v trizen)" ]; then \
		trizen -S curl cmake msr-tools cpuid cpupower npm; \
	else \
		echo "Unknown installer. apt/dnf/trizen not found"; \
		exit 1; \
	fi
	cd ./zerocost_testing_firefox && ./mach create-mach-environment
	cd ./zerocost_testing_firefox && ./mach bootstrap --no-interactive --application-choice browser
	touch ./bootstrap

pull: $(DIRS)
	git pull
	cd zerocost_testing_sandbox && git pull
	cd rlbox_mpk_sandbox && git pull
	cd zerocost_testing_firefox && git pull

build:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_release ./mach build

build_debug:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_debug ./mach build

benchmark:
	if [ -x "$(shell command -v cpupower)" ]; then \
		sudo cpupower -c 1 frequency-set --min 2200MHz --max 2200MHz \
	else \
		sudo cpufreq-set -c 1 --min 2200MHz --max 2200MHz \
	fi
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

clean:
	-rm -rf ./ff_builds

