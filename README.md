- [Description](#description)
- [Software being built by this repo](#software-being-built-by-this-repo)
- [Build Instructions](#build-instructions)
- [Test Instructions](#test-instructions)

# Description

This is the top level repo for the paper "Isolation without Taxation: Near-Zero-Cost Transitions for WebAssembly and SFI" submitted to [POPL 2022](https://popl22.sigplan.org/) in which we introduce the zerocost transitions. This repo will download and build all tools used in the paper, such as the multiple builds of firefox with sandboxed libraries, modified compilers, and the RLBox API.

# Software being built by this repo

**[lucet_sandbox_compiler](https://github.com/PLSysSec/lucet_sandbox_compiler.git)** - Lucet Wasm compiler (using the fork adapted for library sandboxign)

**[Sandboxing_NaCl](https:////github/com/shravanrn/Sandboxing_NaCl.git)** - Nacl Sandboxing compiler  that defaults to heavy transitions written in asm

**[rlbox_lucet_sandbox](https://github.com/PLSysSec/rlbox_lucet_sandbox.git)** - RLBox sandboxing API plugin with lucet that uses zerocost transitions

**[zerocost_heavy_trampoline](https://github.com/PLSysSec/zerocost_heavy_trampoline.git)** - Standalone heavyweight transitions written in asm used by other repos

**[zerocost_testing_sandbox](https://github.com/PLSysSec/zerocost_testing_sandbox.git)** - RLBox sandboxing API plugin with lucet that uses heavy transitions written in asm

**[rlbox_lucetstock_sandbox](https://github.com/PLSysSec/rlbox_lucet_sandbox/tree/lucet-transitions)** - RLBox sandboxing API plugin with lucet's default heavyweight transitions written in rust

**[rlbox_mpk_sandbox](https://github.com/PLSysSec/rlbox_mpk_sandbox.git)** - RLBox sandboxing API plugin when sandboxing with an "ideal" sandbox and using heavyweight transitions written in asm

**[rlbox_segmentsfizerocost_sandbox](https://github.com/PLSysSec/rlbox_segmentsfizerocost_sandbox.git)** - RLBox sandboxing API plugin when sandboxing with segmentzero sandboxing that uses zerocost transitions

**[rlbox_nacl_sandbox](https://github.com/PLSysSec/rlbox_nacl_sandbox.git)** - RLBox sandboxing API plugin with Native Client and using heavyweight transitions written in asm

**[rlbox_sandboxing_api](https://github.com/PLSysSec/rlbox_sandboxing_api.git)** - RLBox sandboxing API

**[zerocost](https://github.com/PLSysSec/zerocost-libjpeg-turbo.git)** - libjpeg with different builds for lucet, nacl, segmentzero etc.

**[zerocost_testing_firefox](https://github.com/PLSysSec/zerocost_testing_firefox.git)** - firefox with different builds for lucet, nacl, segmentzero etc.

**[web_resource_crawler](https://github.com/shravanrn/web_resource_crawler.git)** - A firefox extension (needs Firefox 65+) that crawls the Alexa top 500, and collects information about the resources used on the web page.

**[rlbox_lucet_directcall_benchmarks](https://github.com/PLSysSec/rlbox_lucet_directcall_benchmarks.git)** - Microbenchmarks to compute the costs of direct calls vs indirect

**[zerocost_llvm](https://github.com/PLSysSec/zerocost_llvm.git)** - LLVM/Clang modified to support segmentzero

# Build Instructions

**Requirements** - This repo has been tested on Ubuntu 20 LTS. Additionally, the process sandbox build of Firefox assumes you are on a machine with at least 4 cores.

**Note** - Do not use an existing machine; our setup installs/modifies packages on the machine and has been well tested on a fresh Ubuntu Install. Use a fresh VM or machine.

**Estimated build time**: Less than 24 hours

To build the repo, run

```bash
# Need make to run the scripts
sudo apt-get install make
# This installs required packages on the system.
# Only need to run once per system.
make bootstrap
# load the changes
source ~/.profile
# Download all sub-repos and build the world
make
```

For incremental builds after the first one, you can just use

```bash
make
```

# Test Instructions

After building the repo, you can reproduce the tests we perform in the RLBox paper as follows.

All benchmarks should be run in benchmark mode. Setup the benchmark mode (pin
cpu frequencies, disable hyper-threading, pin benchmarks to CPU) as follows.

```bash
make shielding_on
# The above will spawn a subshell in your current terminal
# Run the following command in this subshell
make benchmark_env_setup
```

See the makefile on how to invoke specific benchmarks.

After the benchmark is complete, disable benchmark mode by

1. Close the terminal where you ran `make shielding on`. You can do with Ctrl + D
2. Run the following in a **new** terminal

    ```bash
    make benchmark_env_closed
    ```
<!---
## Macro benchmarks

1. We have several builds of Firefox included --- Stock Firefox, Firefox with heavy lucet (rust) transitions, Firefox with heavy asm transitions, Firefox with zerocost transitions. We have a macro benchmark that measure page load times and memory overheads on these three builds on 11 representative sites on different builds. Expected duration: 0.5 days. To run

    ```bash
    cd ./mozilla-release
    ./newRunMacroPerfTest ~/Desktop/rlbox_macro_logs
    ```

    You will see the results in page_latency_metrics.txt, page_memory_overhead_metrics.txt in the folder ~/Desktop/rlbox_macro_logs

    **Note** - Firefox's test harness is primarily meant for local tests and isn't really setup to make network calls prior to our modifications of the harness. Our modified test harness sometimes freezes during page load; if this happens, let the test script continue, it automatically restarts as needed in this situation.

## Micro benchmarks

### Caveats

- Note that many of these benchmarks are run with a very large number of iterations, on a variety of different media so that we can report realistic numbers. Thus each one of these tasks below can take the better part of a day and upto a day and a half. I have indicated the expected time below. If you modify settings to reduce the number of iterations, that this may affect the numbers as benchmarks will be more prone to noise.
- Specific choices during machine setup were made to reduce noise during benchmarks, namely disabling hyper-threading, disabling dynamic frequency scaling and pinning the CPU to a low frequency which will not introduce thermal throttling, isolating the CPUs on which we run tests using the isolcpus boot kernel parameter and running Ubuntu without a GUI and running the benchmarks on headless Firefox. Part of this setup is automated in the script "microBenchmarkTestSetup" in this repo. If you decide not to do this setup, this will likely result in the reported numbers being more noisy than reported.
- If running on a VM, it is unlikely some of the benchmarking setup listed in the prior bullet will work particularly well. In particular, the video benchamark and measurements are quite unreliable in this setting.

### Instructions

1. We also have micro benchmarks on the same three builds performed on four classes of libraries ---- image libraries, audio libraries, video libraries, webpage decompression. Each of these have separate micro benchmarks that are included in the artifact. We start with images, for which we measure the decoding times for the three Firefox builds on a variety of jpegs and pngs in different formats.  Expected duration: 1.5 days.

    ```bash
    cd ./mozilla-release
    ./newRunMicroImageTest ~/Desktop/rlbox_micro_image_logs
    ```

    You will see the results in jpeg_perf.dat, png_perf.dat in the folder ~/Desktop/rlbox_micro_image_logs

2. We continue the microbenchmark with evaluating webpage decompression with zlib. Expected duration: 0.5 days.

    In a separate terminal first run

    ```bash
    cd ./rlbox-st-test/ && node server.js
    # Leave this running
    ```

    then run,

    ```bash
    cd ./mozilla-release
    ./newRunMicroZlibTest ~/Desktop/rlbox_micro_compression_logs
    ```

    You will see the results in new_nacl_cpp_rlbox_test_page_render.json, new_ps_cpp_rlbox_test_page_render.json, static_stock_rlbox_test_page_render.json in the folder ~/Desktop/rlbox_micro_compression_logs

3. We continue the microbenchmark with evaluating audio and video performance by measuring Vorbis audio bit rate and  throughput on a high quality audio file measuring VPX and Theora bit rate throughput on a high quality video file on the three Firefox builds. Expected duration: 1.5 hours.

    ```bash
    cd ./mozilla-release
    ./newRunMicroAVTest ~/Desktop/rlbox_micro_audiovideo_logs
    ```

4. We also have scaling tests which test the total number of sandboxes that can reasonably be created and measure image decoding times for the same. Expected duration: 1.5 days.

    In a separate terminal first run

    ```bash
    cd ./rlbox-st-test/ && node server.js
    # Leave this running
    ```

    then run,

    ```bash
    cd ./mozilla-release
    ./newRunMicroImageScaleTest ~/Desktop/rlbox_micro_scaling_logs
    ```

    You will see the results in sandbox_scaling.dat in the folder ~/Desktop/rlbox_micro_scaling_logs

5. We also evaluate use of our sandboxing techniques outside of firefox by measuring throughput of two other applications. We first evaluate the throughput of a crypto module in node.js. Expected duration: 0.5 days.

    ```bash
    cd ./node.bcrypt.js
    make bench
    ```

    You will see the results in the terminal.

6. Continuing the prior evaluation, we also evaluate the throughput of apache web server's markdown to html conversion. Expected duration: 0.25 days

    In a separate terminal first run

    ```bash
    sudo apache2ctl stop
    sudo /usr/sbin/apache2ctl -DFOREGROUND
    # Leave this running
    ```

    then run,

    ```bash
    cd ./mod_markdown
    make bench
    ```

    You will see the results in the terminal.

7. We also provide a benchmark of a sandboxing the Graphite font library (using a WASM based SFI) which has been upstreamed and is currently in Firefox nightly. This is easiest to test directly with the nightly builds made available by Mozilla. Download the nightly build with the sandboxed font library [here](https://ftp.mozilla.org/pub/firefox/nightly/2020/01/2020-01-03-20-22-40-mozilla-central/firefox-73.0a1.en-US.linux-x86_64.tar.bz2) and a build from a nightly that does not have this, available [here](https://ftp.mozilla.org/pub/firefox/nightly/2020/01/2020-01-01-09-29-38-mozilla-central/firefox-73.0a1.en-US.linux-x86_64.tar.bz2). Visit the following [webpage](https://jfkthame.github.io/test/udhr_urd.html) which runs a micro benchmark on Graphite fonts on both builds. Expected duration: 15 mins.

8. We have a web crawler written as firefox extension that scrapes the Alexa top 500 websites and analyses the image widths. This is written as a Firefox extension. Expected duration: 2 hours. To run, we will follow the steps as outlined [here](https://extensionworkshop.com/documentation/develop/temporary-installation-in-firefox/) reproduced below
    - Kill all open Firefox instances
    - Open Firefox browser (we need Firefox version > 65. Use the one that ships with the OS, not the one we built).
    - Enter “about:debugging” in the URL bar
    - Click “This Firefox”
    - Click “Load Temporary Add-on”
    - Open file "zerocost-root/web_resource_crawler/manifest.json"
    - You will see a new icon in the toolbar next to the address bar (sort of looks like a page icon) with the tooltip WebResourceCrawler. Click this.
    - The extension will now go through the Alexa top 500 slowly (spending 10 seconds on each page to account for dynamic resource loading). Do not click on any tabs while Firefox cycles through the webpages. It dumps the raw logs in "zerocost-root/web_resource_crawler/out.json"
    - When finished it browses to a blank page. When this happens, run the following commands to process the data

        ```bash
        mkdir -p ~/Desktop/web_resource_crawler_data
        cd ~/Desktop/web_resource_crawler_data
        # Adjust the path as appropriate
        zerocost-root/web_resource_crawler/process_logs.py
        ```

    You will see the results in crossOriginAnalysis.json and memory_analysis.txt in the folder ~/Desktop/web_resource_crawler_data

-->