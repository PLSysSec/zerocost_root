.NOTPARALLEL:
.PHONY : pull clean get_source build build_debug restore_hyperthreading shielding_on shielding_off benchmark_env_setup benchmark_env_close micro_transition_benchmark micro_jpeg_benchmark macro_image_benchmark macro_graphite_benchmark

.DEFAULT_GOAL := build

SHELL := /bin/bash

DIRS=lucet_sandbox_compiler rlbox_lucet_sandbox zerocost_testing_sandbox rlbox_lucetstock_sandbox rlbox_mpk_sandbox rlbox_mpkzerocost_sandbox rlbox_segmentsfizerocost_sandbox rlbox_sandboxing_api rlbox_lucet_directcall_benchmarks zerocost-libjpeg-turbo zerocost_testing_firefox web_resource_crawler zerocost_llvm zerocost-nodejs-benchmarks

CURR_DIR := $(shell realpath ./)
OUTPUT_PATH := $(CURR_DIR)/ffbuilds
# OUTPUT_PATH := /mnt/sata/ffbuilds
CURR_USER := ${USER}
CURR_PATH := ${PATH}

lucet_sandbox_compiler:
	git clone git@github.com:PLSysSec/lucet_sandbox_compiler.git $@
	cd $@ && git checkout lucet-wasi-wasmsbx && git submodule update --init --recursive

rlbox_lucet_sandbox:
	git clone git@github.com:PLSysSec/rlbox_lucet_sandbox.git $@
	cd $@ && git checkout zerocost

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

rlbox_segmentsfizerocost_sandbox:
	git clone git@github.com:PLSysSec/rlbox_segmentsfizerocost_sandbox.git $@

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

nginx:
	wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1i.tar.gz -O openssl.tar.gz
	tar xzvf openssl.tar.gz
	mv openssl-OpenSSL_1_1_1i openssl
	git clone git@github.com:PLSysSec/nginx-sandboxed.git nginx

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
	$(MAKE) -j8 install

# node-sandboxed:
# 	git clone git@github.com:PLSysSec/nodejs-sandboxed.git $@

zerocost-nodejs-benchmarks:
	git clone git@github.com:PLSysSec/zerocost-nodejs-benchmarks.git $@

get_source: $(DIRS)

bootstrap: get_source
	if [ -x "$(shell command -v apt)" ]; then \
		sudo apt -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm xvfb cpuset gcc-multilib g++-multilib libdbus-glib-1-dev:i386 libgtk2.0-dev:i386 libgtk-3-dev:i386 libpango1.0-dev:i386 libxt-dev:i386 libpulse-dev:i386 nghttp2-client; \
	elif [ -x "$(shell command -v dnf)" ]; then \
		sudo dnf -y install curl cmake msr-tools cpuid cpufrequtils npm clang llvm xvfb cpuset gcc-multilib g++-multilib libdbus-glib-1-dev:i386 libgtk2.0-dev:i386 libgtk-3-dev:i386 libpango1.0-dev:i386 libxt-dev:i386 libpulse-dev:i386 nghttp2-client; \
	elif [ -x "$(shell command -v trizen)" ]; then \
		trizen -S --noconfirm curl cmake msr-tools cpuid cpupower npm clang llvm xvfb cpuset gcc-multilib g++-multilib libdbus-glib-1-dev:i386 libgtk2.0-dev:i386 libgtk-3-dev:i386 libpango1.0-dev:i386 libxt-dev:i386 libpulse-dev:i386 nghttp2-client; \
	else \
		echo "Unknown installer. apt/dnf/trizen not found"; \
		exit 1; \
	fi
	if [ ! -x "$(shell command -v rustc)" ] ; then \
		curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.46.0 -y; \
	fi
	rustup target install i686-unknown-linux-gnu
	if [ ! -d /opt/wasi-sdk/ ]; then \
		wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz -P /tmp/ && \
		tar -xzf /tmp/wasi-sdk-10.0-linux.tar.gz && \
		sudo mv wasi-sdk-10.0 /opt/wasi-sdk; \
	fi
	cd ./zerocost_testing_firefox && ./mach create-mach-environment
	cd ./zerocost_testing_firefox && ./mach bootstrap --no-interactive --application-choice browser
	cd ./zerocost-nodejs-benchmarks && npm install && npm install autocannon-compare
	pip3 install simplejson tldextract matplotlib
	touch ./bootstrap

pull: $(DIRS)
	git pull --rebase --autostash
	cd lucet_sandbox_compiler && git pull --rebase --autostash
	cd rlbox_lucet_sandbox && git pull --rebase --autostash
	cd zerocost_testing_sandbox && git pull --rebase --autostash
	cd rlbox_lucetstock_sandbox && git pull --rebase --autostash
	cd rlbox_mpk_sandbox && git pull --rebase --autostash
	cd rlbox_mpkzerocost_sandbox && git pull --rebase --autostash
	cd rlbox_segmentsfizerocost_sandbox && git pull --rebase --autostash
	cd rlbox_sandboxing_api && git pull --rebase --autostash
	cd zerocost-libjpeg-turbo && git pull --rebase --autostash
	cd zerocost_testing_firefox && git pull --rebase --autostash
	cd web_resource_crawler && git pull --rebase --autostash
	cd rlbox_lucet_directcall_benchmarks && git pull --rebase --autostash
	cd zerocost_llvm && git pull --rebase --autostash
	# cd node-sandboxed && git pull --rebase --autostash
	cd zerocost-nodejs-benchmarks && git pull --rebase --autostash

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
	cd rlbox_lucet_sandbox               && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd zerocost_testing_sandbox          && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_lucetstock_sandbox          && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_mpk_sandbox                 && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_mpkzerocost_sandbox         && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_sandboxing_api              && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_segmentsfizerocost_sandbox  && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd rlbox_lucet_directcall_benchmarks && cmake -S . -B ./build_release -DCMAKE_BUILD_TYPE=Release && cd ./build_release && make -j8
	cd zerocost-libjpeg-turbo/build && make -j8 build
	# cd nginx && CFLAGS="-O3 -fpermissive -std=c++17" ./auto/configure --with-openssl=../openssl --with-http_ssl_module --with-stream_ssl_module --with-stream_ssl_preread_module --builddir=$(OUTPUT_PATH)/nginx_release && sed -i 's/LINK =\t$(CC)/LINK =\tg++/' $(OUTPUT_PATH)/nginx_debug/Makefile && make -j8
	# cd node-sandboxed/build && make build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave32_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock32_release ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_segmentsfizerocost_release ./mach build

build_debug: build_check zerocost_clang
	cd lucet_sandbox_compiler && cargo build --release
	cd rlbox_lucet_sandbox               && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd zerocost_testing_sandbox          && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_lucetstock_sandbox          && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_mpk_sandbox                 && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_mpkzerocost_sandbox         && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_sandboxing_api              && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_segmentsfizerocost_sandbox  && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd rlbox_lucet_directcall_benchmarks && cmake -S . -B ./build_debug -DCMAKE_BUILD_TYPE=Debug && cd ./build_debug && make -j8
	cd zerocost-libjpeg-turbo/build && make -j8 build_debug
	# cd nginx && CFLAGS="-g -O0 -fpermissive -std=c++17" ./auto/configure --with-openssl=../openssl --with-http_ssl_module --with-stream_ssl_module --with-stream_ssl_preread_module --builddir=$(OUTPUT_PATH)/nginx_debug  && sed -i 's/LINK =\t$(CC)/LINK =\tg++/' $(OUTPUT_PATH)/nginx_debug/Makefile && make -j8
	# cd node-sandboxed/build && make build_debug
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_mpkfullsave32_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_zerocost_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_regsave_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_lucet_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_fullsavewindows_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_stock32_debug ./mach build
	cd zerocost_testing_firefox && MOZCONFIG=mozconfig_segmentsfizerocost_debug ./mach build

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
	echo "---------" >> ./benchmarks/micro_transition_benchmark.txt
	cat ./benchmarks/micro_transition_benchmark.txt | \
		grep "\(Transition:\)\|\(Filters: sandbox glue tests\)\|\(time:\)" | \
		grep -v "Unsandboxed" | \
		tee -a ./benchmarks/micro_transition_benchmark.txt
	mv ./benchmarks/micro_transition_benchmark.txt "./benchmarks/micro_transition_benchmark_$(shell date --iso=seconds).txt"

micro_jpeg_benchmark: benchmark_env_setup
	echo > ./benchmarks/micro_jpeg_benchmark.txt
	cd zerocost-libjpeg-turbo/build && $(MAKE) run | tee -a $(CURR_DIR)/benchmarks/micro_jpeg_benchmark.txt
	mv ./benchmarks/micro_jpeg_benchmark.txt "./benchmarks/micro_jpeg_benchmark_$(shell date --iso=seconds).txt"

macro_image_benchmark: benchmark_env_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunMicroImageTest "../benchmarks/jpeg_width_$(shell date --iso=seconds)"

macro_graphite_benchmark: benchmark_env_setup
	export DISPLAY=:99 && \
	cd zerocost_testing_firefox && \
	./newRunGraphiteTest "../benchmarks/graphite_test_$(shell date --iso=seconds)"

./docker/id_rsa:
	@echo -n "This will copy SSH keys for the current user to the created docker image. You can also say no and create a new key pair in the docker folder and re-reun this makefile. Please confirm if you want to proceed with the system key pair? [y/N] " && read ans; \
	if [ ! $${ans:-N} = y ]; then \
		exit 1; \
	fi
	cp ~/.ssh/id_rsa ./docker/id_rsa
	cp ~/.ssh/id_rsa.pub ./docker/id_rsa.pub

docker_setup_host_ubuntu:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"
	sudo apt update
	sudo apt install -qq -y curl git apt-transport-https ca-certificates curl gnupg-agent software-properties-common docker-ce docker-ce-cli containerd.io

docker_setup_host: ./docker/id_rsa
	chmod 604 ./docker/id_rsa
	$(MAKE) -C $(CURR_DIR) docker_setup_host_ubuntu
	touch ./docker_setup_host

build_docker_img: docker_setup_host
	sudo docker build --network host ./docker --tag zerocostff
	sudo docker run --cap-add SYS_ADMIN --network host -it --name zerocostff_inst zerocostff
	touch ./build_docker_img

clean:
	-rm -rf $(OUTPUT_PATH)

