.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug micro_benchmark macro_benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=lucet_sandbox_compiler zerocost_testing_sandbox rlbox_lucetstock_sandbox rlbox_mpk_sandbox rlbox_mpkzerocost_sandbox zerocost-libjpeg-turbo zerocost_testing_firefox

CURR_DIR := $(shell realpath ./)

lucet_sandbox_compiler:
	git clone git@github.com:PLSysSec/lucet_sandbox_compiler.git $@
	cd $@ && git checkout lucet-wasi-wasmsbx && git submodule update --init --recursive

zerocost_testing_sandbox:
	git clone git@github.com:PLSysSec/zerocost_testing_sandbox.git $@

rlbox_lucetstock_sandbox:
	git clone git@github.com:PLSysSec/rlbox_lucet_sandbox.git $@
	cd $@ && git checkout lucet-transitions

rlbox_mpk_sandbox:
	git clone git@github.com:PLSysSec/rlbox_mpk_sandbox.git $@

rlbox_mpkzerocost_sandbox:
	git clone git@github.com:PLSysSec/rlbox_mpk_sandbox.git $@
	cd $@ && git checkout zerocost

zerocost-libjpeg-turbo:
	git clone git@github.com:PLSysSec/zerocost-libjpeg-turbo.git $@

zerocost_testing_firefox:
	git clone git@github.com:PLSysSec/zerocost_testing_firefox.git $@

get_source: $(DIRS)

bootstrap: get_source
	if [ -x "$(shell command -v apt)" ]; then \
		sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm; \
	elif [ -x "$(shell command -v dnf)" ]; then \
		sudo dnf -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm; \
	elif [ -x "$(shell command -v trizen)" ]; then \
		trizen -S curl cmake msr-tools cpuid cpupower npm clang llvm; \
	else \
		echo "Unknown installer. apt/dnf/trizen not found"; \
		exit 1; \
	fi
	if [ ! -d /opt/wasi-sdk/ ]; then \
		wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz -P /tmp/ && \
		tar -xzf /tmp/wasi-sdk-10.0-linux.tar.gz && \
		sudo mv wasi-sdk-10.0 /opt/wasi-sdk; \
	fi
	cd ./zerocost_testing_firefox && ./mach create-mach-environment
	cd ./zerocost_testing_firefox && ./mach bootstrap --no-interactive --application-choice browser
	pip3 install simplejson
	touch ./bootstrap

pull: $(DIRS)
	git pull
	cd lucet_sandbox_compiler && git pull
	cd zerocost_testing_sandbox && git pull
	cd rlbox_lucetstock_sandbox && git pull
	cd rlbox_mpk_sandbox && git pull
	cd rlbox_mpkzerocost_sandbox && git pull
	cd zerocost-libjpeg-turbo && git pull
	cd zerocost_testing_firefox && git pull

build:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi
	cd lucet_sandbox_compiler && cargo build --release
	cd zerocost-libjpeg-turbo/build && make -j8 build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_release ./mach build

build_debug:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi
	cd lucet_sandbox_compiler && cargo build --release
	cd zerocost-libjpeg-turbo/build && make -j8 build_debug
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_debug ./mach build

micro_benchmark:
	if [ -x "$(shell command -v cpupower)" ]; then \
		sudo cpupower -c 1 frequency-set --min 2200MHz --max 2200MHz; \
	else \
		sudo cpufreq-set -c 1 --min 2200MHz --max 2200MHz; \
	fi
	cd zerocost-libjpeg-turbo/build && make run

macro_benchmark:
	if [ -x "$(shell command -v cpupower)" ]; then \
		sudo cpupower -c 1 frequency-set --min 2200MHz --max 2200MHz; \
	else \
		sudo cpufreq-set -c 1 --min 2200MHz --max 2200MHz; \
	fi
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

clean:
	-rm -rf ./ff_builds

