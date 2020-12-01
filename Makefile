.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug benchmark_setup micro_transition_benchmark micro_jpeg_benchmark macro_image_benchmark macro_graphite_benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=lucet_sandbox_compiler rlbox_lucet_sandbox zerocost_testing_sandbox rlbox_lucetstock_sandbox rlbox_mpk_sandbox rlbox_mpkzerocost_sandbox zerocost-libjpeg-turbo zerocost_testing_firefox web_resource_crawler

CURR_DIR := $(shell realpath ./)

lucet_sandbox_compiler:
	git clone git@github.com:PLSysSec/lucet_sandbox_compiler.git $@
	cd $@ && git checkout lucet-wasi-wasmsbx && git submodule update --init --recursive

rlbox_lucet_sandbox:
	git clone git@github.com:PLSysSec/rlbox_lucet_sandbox.git $@

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

web_resource_crawler:
	git clone git@github.com:shravanrn/web_resource_crawler.git $@
	cd $@ && git checkout zerocost

get_source: $(DIRS)

bootstrap: get_source
	if [ -x "$(shell command -v apt)" ]; then \
		sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm xvfb; \
	elif [ -x "$(shell command -v dnf)" ]; then \
		sudo dnf -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm xvfb; \
	elif [ -x "$(shell command -v trizen)" ]; then \
		trizen -S curl cmake msr-tools cpuid cpupower npm clang llvm xvfb; \
	else \
		echo "Unknown installer. apt/dnf/trizen not found"; \
		exit 1; \
	fi
	if [ ! -x "$(shell command -v rustc)" ] ; then \
		curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.43.0 -y; \
	fi
	if [ ! -d /opt/wasi-sdk/ ]; then \
		wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz -P /tmp/ && \
		tar -xzf /tmp/wasi-sdk-10.0-linux.tar.gz && \
		sudo mv wasi-sdk-10.0 /opt/wasi-sdk; \
	fi
	cd ./zerocost_testing_firefox && ./mach create-mach-environment
	cd ./zerocost_testing_firefox && ./mach bootstrap --no-interactive --application-choice browser
	pip3 install simplejson tldextract
	touch ./bootstrap

pull: $(DIRS)
	git pull
	cd lucet_sandbox_compiler && git pull
	cd rlbox_lucet_sandbox && git pull
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
	cd rlbox_lucet_sandbox       && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd zerocost_testing_sandbox  && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_lucetstock_sandbox  && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_mpk_sandbox         && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_mpkzerocost_sandbox && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd zerocost-libjpeg-turbo/build && make -j8 build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_release ./mach build

build_debug:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi
	cd lucet_sandbox_compiler && cargo build --release
	cd rlbox_lucet_sandbox       && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd zerocost_testing_sandbox  && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_lucetstock_sandbox  && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_mpk_sandbox         && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_mpkzerocost_sandbox && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd zerocost-libjpeg-turbo/build && make -j8 build_debug
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_debug ./mach build

benchmark_setup:
	sudo bash -c "echo off > /sys/devices/system/cpu/smt/control"
	if [ -x "$(shell command -v cpupower)" ]; then \
		sudo cpupower -c 1 frequency-set --min 2200MHz --max 2200MHz; \
	else \
		sudo cpufreq-set -c 1 --min 2200MHz --max 2200MHz; \
	fi
	if [ -z "$(shell pgrep Xvfb)" ]; then \
		Xvfb :99 & \
	fi

micro_transition_benchmark:
	echo > ./benchmarks/micro_transition_benchmark.txt
	echo "---------"
	echo "Transition: Zero"     | tee -a ./benchmarks/micro_transition_benchmark.txt
	cd rlbox_lucet_sandbox/build_release       && taskset -c 1 ctest -V | tee -a $(CURR_DIR)/benchmarks/micro_transition_benchmark.txt
	echo "Transition: Heavy"    | tee -a ./benchmarks/micro_transition_benchmark.txt
	cd zerocost_testing_sandbox/build_release  && taskset -c 1 ctest -V | tee -a $(CURR_DIR)/benchmarks/micro_transition_benchmark.txt
	echo "Transition: Lucet"    | tee -a ./benchmarks/micro_transition_benchmark.txt
	cd rlbox_lucetstock_sandbox/build_release  && taskset -c 1 ctest -V | tee -a $(CURR_DIR)/benchmarks/micro_transition_benchmark.txt
	echo "Transition: Mpkheavy" | tee -a ./benchmarks/micro_transition_benchmark.txt
	cd rlbox_mpk_sandbox/build_release         && taskset -c 1 ctest -V | tee -a $(CURR_DIR)/benchmarks/micro_transition_benchmark.txt
	echo "Transition: Mpkzero"  | tee -a ./benchmarks/micro_transition_benchmark.txt
	cd rlbox_mpkzerocost_sandbox/build_release && taskset -c 1 ctest -V | tee -a $(CURR_DIR)/benchmarks/micro_transition_benchmark.txt
	echo "---------" >> ./benchmarks/micro_transition_benchmark.txt
	cat ./benchmarks/micro_transition_benchmark.txt | grep "\(Transition:\)\|\(Filters:\)\|\(time:\)" | tee -a ./benchmarks/micro_transition_benchmark.txt
	mv ./benchmarks/micro_transition_benchmark.txt "./benchmarks/micro_transition_benchmark_$(shell date --iso=seconds).txt"

micro_jpeg_benchmark: benchmark_setup
	cd zerocost-libjpeg-turbo/build && make run

macro_image_benchmark: benchmark_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

macro_graphite_benchmark: benchmark_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunGraphiteTest "../benchmarks/graphite_test_$(shell date --iso=seconds)"

clean:
	-rm -rf ./ff_builds

