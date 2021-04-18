.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug restore_hyperthreading shielding_on shielding_off benchmark_env_setup benchmark_env_close micro_transition_benchmark micro_jpeg_benchmark macro_image_benchmark macro_image_random_benchmark macro_graphite_benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=lucet_sandbox_compiler Sandboxing_NaCl rlbox_lucet_sandbox zerocost_heavy_trampoline zerocost_testing_sandbox rlbox_lucetstock_sandbox rlbox_mpk_sandbox rlbox_segmentsfizerocost_sandbox rlbox_nacl_sandbox rlbox_sandboxing_api rlbox_lucet_directcall_benchmarks zerocost-libjpeg-turbo zerocost_testing_firefox web_resource_crawler zerocost_llvm

CURR_DIR := $(shell realpath ./)
OUTPUT_PATH := $(CURR_DIR)/ffbuilds
# OUTPUT_PATH := /mnt/sata/ffbuilds
CURR_USER := ${USER}
CURR_PATH := ${PATH}

CORE_COUNT= $(shell nproc --all)

lucet_sandbox_compiler:
	git clone git@github.com:PLSysSec/lucet_sandbox_compiler.git $@
	cd $@ && git checkout lucet-wasi-wasmsbx && git submodule update --init --recursive

Sandboxing_NaCl :
	git clone https://github.com/shravanrn/Sandboxing_NaCl.git $@

rlbox_lucet_sandbox:
	git clone git@github.com:PLSysSec/rlbox_lucet_sandbox.git $@
	cd $@ && git checkout zerocost

zerocost_heavy_trampoline:
	git clone git@github.com:PLSysSec/zerocost_heavy_trampoline.git $@

zerocost_testing_sandbox:
	git clone git@github.com:PLSysSec/zerocost_testing_sandbox.git $@

rlbox_lucetstock_sandbox:
	git clone git@github.com:PLSysSec/rlbox_lucet_sandbox.git $@
	cd $@ && git checkout lucet-transitions

rlbox_mpk_sandbox:
	git clone git@github.com:PLSysSec/rlbox_mpk_sandbox.git $@
	cd $@ && git checkout ideal

rlbox_segmentsfizerocost_sandbox:
	git clone git@github.com:PLSysSec/rlbox_segmentsfizerocost_sandbox.git $@

rlbox_nacl_sandbox:
	git clone git@github.com:PLSysSec/rlbox_nacl_sandbox.git $@

rlbox_sandboxing_api:
	git clone git@github.com:PLSysSec/rlbox_sandboxing_api.git $@
	cd $@ && git checkout gettimeofday

zerocost-libjpeg-turbo:
	git clone git@github.com:PLSysSec/zerocost-libjpeg-turbo.git $@

zerocost_testing_firefox:
	git clone git@github.com:PLSysSec/zerocost_testing_firefox.git $@

web_resource_crawler:
	git clone git@github.com:shravanrn/web_resource_crawler.git $@
	cd $@ && git checkout zerocost

rlbox_lucet_directcall_benchmarks:
	git clone git@github.com:PLSysSec/rlbox_lucet_directcall_benchmarks.git $@

zerocost_llvm:
	git clone git@github.com:PLSysSec/zerocost_llvm.git $@

$(OUTPUT_PATH)/zerocost_llvm_install/bin/clang: zerocost_llvm
	mkdir -p $(OUTPUT_PATH)/zerocost_llvm
	cd $(OUTPUT_PATH)/zerocost_llvm && \
	cmake -DCMAKE_C_FLAGS="-fuse-ld=gold" -DCMAKE_CXX_FLAGS="-fuse-ld=gold" \
		  -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;lld" \
		  -DLLVM_TARGETS_TO_BUILD="X86" \
		  -DLLVM_BINUTILS_INCDIR=/usr/include/ \
		  -DCMAKE_INSTALL_PREFIX=$(OUTPUT_PATH)/zerocost_llvm_install \
		  -DCMAKE_BUILD_TYPE=Debug \
		  $(CURR_DIR)/zerocost_llvm/llvm && \
	$(MAKE) -j${CORE_COUNT} install

get_source: $(DIRS)

bootstrap: get_source
	sudo dpkg --add-architecture i386
	sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm xvfb cpuset \
		nghttp2-client wget python python3 python3-pip binutils-dev \
		gcc-multilib g++-multilib libdbus-glib-1-dev:i386 libgtk2.0-dev:i386 libgtk-3-dev:i386 libpango1.0-dev:i386 libxt-dev:i386 libx11-xcb-dev:i386 libpulse-dev:i386 libdrm-dev:i386 \
		flex bison libc6-dev-i386 texinfo libtinfo5;
	# Have to install separately due to conflicts
	sudo apt -y install gcc-arm-linux-gnueabihf
	if [ ! -x "$(shell command -v rustc)" ] ; then \
		curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.46.0 -y; \
		source ~/.cargo/env && rustup target install i686-unknown-linux-gnu; \
	else \
		rustup target install i686-unknown-linux-gnu; \
	fi
	if [ ! -d /opt/wasi-sdk/ ]; then \
		wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz -P /tmp/ && \
		tar -xzf /tmp/wasi-sdk-10.0-linux.tar.gz && \
		sudo mv wasi-sdk-10.0 /opt/wasi-sdk; \
	fi
	cd ./zerocost_testing_firefox && ./mach create-mach-environment
	cd ./zerocost_testing_firefox && ./mach bootstrap --no-interactive --application-choice browser
	pip3 install simplejson tldextract matplotlib
	touch ./bootstrap

pull: $(DIRS)
	git pull --rebase --autostash
	cd lucet_sandbox_compiler && git pull --rebase --autostash
	cd Sandboxing_NaCl && git pull --rebase --autostash
	cd rlbox_lucet_sandbox && git pull --rebase --autostash
	cd zerocost_heavy_trampoline && git pull --rebase --autostash
	cd zerocost_testing_sandbox && git pull --rebase --autostash
	cd rlbox_lucetstock_sandbox && git pull --rebase --autostash
	cd rlbox_mpk_sandbox && git pull --rebase --autostash
	cd rlbox_segmentsfizerocost_sandbox && git pull --rebase --autostash
	cd rlbox_nacl_sandbox && git pull --rebase --autostash
	cd rlbox_sandboxing_api && git pull --rebase --autostash
	cd zerocost-libjpeg-turbo && git pull --rebase --autostash
	cd zerocost_testing_firefox && git pull --rebase --autostash
	cd web_resource_crawler && git pull --rebase --autostash
	cd rlbox_lucet_directcall_benchmarks && git pull --rebase --autostash
	cd zerocost_llvm && git pull --rebase --autostash

build_check:
	@if [ ! -e "$(CURR_DIR)/bootstrap" ]; then \
		echo "Before building, run the following commands" ; \
		echo "make bootstrap" ; \
		echo "source ~/.profile" ; \
		exit 1; \
	fi

zerocost_clang: $(OUTPUT_PATH)/zerocost_llvm_install/bin/clang

build: build_check zerocost_clang
	cd lucet_sandbox_compiler && cargo build --release
	cd Sandboxing_NaCl && make init
	cd rlbox_lucet_sandbox               && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd zerocost_testing_sandbox          && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_lucetstock_sandbox          && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_mpk_sandbox                 && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_sandboxing_api              && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_sandboxing_api              && CFLAGS="-m32" CXXFLAGS="-m32" LDFLAGS="-m32" cmake -DCMAKE_BUILD_TYPE=Release -S . -B ./build_release_32bit && cd ./build_release_32bit && make -j${CORE_COUNT}
	cd rlbox_segmentsfizerocost_sandbox  && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_nacl_sandbox                && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd rlbox_lucet_directcall_benchmarks && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j${CORE_COUNT}
	cd zerocost-libjpeg-turbo/build && make -j${CORE_COUNT} build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave32_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_segmentsfizerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_naclfullsave32_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stockindirect32_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock32_release ./mach build

build_debug: build_check zerocost_clang
	cd lucet_sandbox_compiler && cargo build --release
	cd Sandboxing_NaCl && make init
	cd rlbox_lucet_sandbox               && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd zerocost_testing_sandbox          && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_lucetstock_sandbox          && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_mpk_sandbox                 && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_sandboxing_api              && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_sandboxing_api              && CFLAGS="-m32" CXXFLAGS="-m32" LDFLAGS="-m32" cmake -DCMAKE_BUILD_TYPE=Debug -S . -B ./build_debug_32bit && cd ./build_debug_32bit && make -j${CORE_COUNT}
	cd rlbox_segmentsfizerocost_sandbox  && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_nacl_sandbox                && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd rlbox_lucet_directcall_benchmarks && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j${CORE_COUNT}
	cd zerocost-libjpeg-turbo/build && make -j${CORE_COUNT} build_debug
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave32_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_segmentsfizerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_naclfullsave32_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stockindirect32_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock32_debug ./mach build

run_xvfb:
	if [ -z "$(shell pgrep Xvfb)" ]; then \
		Xvfb :99 & \
	fi

shielding_on: run_xvfb
	sudo cset shield -c 1 -k on
	sudo cset shield -e sudo -- -u ${CURR_USER} env "PATH=${CURR_PATH}" bash

shielding_off:
	sudo cset shield --reset

restore_hyperthreading:
	sudo bash -c "echo on > /sys/devices/system/cpu/smt/control"

benchmark_env_setup:
	sudo cset shield -c 1 -k on
	(taskset -c 1 echo "testing shield..." > /dev/null 2>&1 && echo "Shielded shell not running!") || (echo "Shielded shell not running. Run make shielding_on first!" && sudo cset shield --reset && exit 1)
	sudo bash -c "echo off > /sys/devices/system/cpu/smt/control"
	if [ -x "$(shell command -v cpupower)" ]; then \
		sudo cpupower -c 1 frequency-set -g performance && sudo cpupower -c 1 frequency-set --min 2200MHz --max 2200MHz; \
	else \
		sudo cpufreq-set -c 1 -g performance && sudo cpufreq-set -c 1 --min 2200MHz --max 2200MHz; \
	fi

benchmark_env_close: restore_hyperthreading shielding_off

micro_transition_benchmark: benchmark_env_setup
	echo > ./benchmarks/micro_transition_benchmark.txt
	taskset -c 1 ./run_transitions_benchmark.sh | tee -a ./benchmarks/micro_transition_benchmark.txt
	mv ./benchmarks/micro_transition_benchmark.txt "./benchmarks/micro_transition_benchmark_$(shell date --iso=seconds).txt"

micro_jpeg_benchmark: benchmark_env_setup
	echo > ./benchmarks/micro_jpeg_benchmark.txt
	cd zerocost-libjpeg-turbo/build && $(MAKE) run | tee -a $(CURR_DIR)/benchmarks/micro_jpeg_benchmark.txt
	mv ./benchmarks/micro_jpeg_benchmark.txt "./benchmarks/micro_jpeg_benchmark_$(shell date --iso=seconds).txt"

macro_image_benchmark: benchmark_env_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

macro_image_random_benchmark: benchmark_env_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)" "random"

macro_graphite_benchmark: benchmark_env_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunGraphiteTest "../benchmarks/graphite_test_$(shell date --iso=seconds)"

macro_graphite_benchmark_ui: benchmark_env_setup
	cd zerocost_testing_firefox && \
	./newRunGraphiteTest "../benchmarks/graphite_test_$(shell date --iso=seconds)"

./docker/id_rsa:
	@echo -n "This will copy SSH keys for the current user to the created docker image. You can also say no and create a new key pair in the docker folder and re-reun this makefile. Please confirm if you want to proceed with the system key pair? [y/N] " && read ans; \
	if [ ! $${ans:-N} = y ]; then \
		exit 1; \
	fi
	cp ~/.ssh/id_rsa ./docker/id_rsa
	cp ~/.ssh/id_rsa.pub ./docker/id_rsa.pub

docker_setup_host_ubuntu_debian:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(shell ./get_os.sh) $(shell lsb_release -cs) stable"
	sudo apt update
	sudo apt install -qq -y curl git apt-transport-https ca-certificates curl gnupg-agent software-properties-common docker-ce docker-ce-cli containerd.io

docker_setup_host: ./docker/id_rsa
	chmod 604 ./docker/id_rsa
	$(MAKE) -C $(CURR_DIR) docker_setup_host_ubuntu_debian
	touch ./docker_setup_host

build_docker_img: docker_setup_host
	sudo docker build --network host ./docker --tag zerocostff
	sudo docker run --cap-add SYS_ADMIN --network host -it --name zerocostff_inst zerocostff
	touch ./build_docker_img

run_docker_img: build_docker_img
	sudo docker exec -it zerocostff_inst bash

clean:
	-rm -rf $(OUTPUT_PATH)
	# optimized builds
	-rm -rf ./rlbox_lucet_sandbox/build_release
	-rm -rf ./zerocost_testing_sandbox/build_release
	-rm -rf ./rlbox_lucetstock_sandbox/build_release
	-rm -rf ./rlbox_mpk_sandbox/build_release
	-rm -rf ./rlbox_sandboxing_api/build_release
	-rm -rf ./rlbox_sandboxing_api/build_release_32bit
	-rm -rf ./rlbox_segmentsfizerocost_sandbox/build_release
	-rm -rf ./rlbox_nacl_sandbox/build_release
	-rm -rf ./rlbox_lucet_directcall_benchmarks/build_release
	# debug builds
	-rm -rf ./rlbox_lucet_sandbox/build_debug
	-rm -rf ./zerocost_testing_sandbox/build_debug
	-rm -rf ./rlbox_lucetstock_sandbox/build_debug
	-rm -rf ./rlbox_mpk_sandbox/build_debug
	-rm -rf ./rlbox_sandboxing_api/build_debug
	-rm -rf ./rlbox_sandboxing_api/build_debug_32bit
	-rm -rf ./rlbox_segmentsfizerocost_sandbox/build_debug
	-rm -rf ./rlbox_nacl_sandbox/build_debug
	-rm -rf ./rlbox_lucet_directcall_benchmarks/build_debug

