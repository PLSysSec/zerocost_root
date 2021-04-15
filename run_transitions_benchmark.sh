#!/bin/bash

sleep 1
echo "Transition: Func"
cd rlbox_sandboxing_api/build_release
echo -n "Direct call: "
./test_rlbox_glue "sandbox glue tests rlbox_noop_sandbox" | grep "Unsandboxed"
echo -n "Indirect call: "
./test_rlbox_glue_indirect | grep "Sandboxed function invocation time"
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: WasmLucet"
cd rlbox_lucetstock_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_lucet_sandbox" | grep "Sandboxed"
echo "Direct call: N/A"
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: WasmFullSave"
cd zerocost_testing_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_lucet_sandbox" | grep "Sandboxed"
cd ../../rlbox_lucet_directcall_benchmarks/build_release
echo -n "Direct call: "
./main_fullsave
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: WasmRegSave"
cd zerocost_testing_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue_noswitchstack "sandbox glue tests rlbox_lucet_sandbox" | grep "Sandboxed"
cd ../../rlbox_lucet_directcall_benchmarks/build_release
echo -n "Direct call: "
./main_regsave
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: WasmZero"
cd rlbox_lucet_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_lucet_sandbox" | grep "Sandboxed"
cd ../../rlbox_lucet_directcall_benchmarks/build_release
echo -n "Direct call: "
./main_zerocost
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: Func (32-bit)"
cd rlbox_sandboxing_api/build_release_32bit
echo -n "Direct call: "
./test_rlbox_glue "sandbox glue tests rlbox_noop_sandbox" | grep "Unsandboxed"
echo -n "Indirect call: "
./test_rlbox_glue_indirect | grep "Sandboxed function invocation time"
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: IdealFullSave"
cd rlbox_mpk_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_mpk_sandbox" | grep "Sandboxed"
cd ../../rlbox_lucet_directcall_benchmarks/build_release
echo -n "Direct call: "
./main_mpkfullsave
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: NaClFullSave"
cd rlbox_nacl_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_nacl_sandbox" | grep "Sandboxed"
echo "Direct call: N/A"
cd ../..
echo "----------------------------"

sleep 1
echo "Transition: SegmentZero"
cd rlbox_segmentsfizerocost_sandbox/build_release
echo -n "Indirect call: "
./test_rlbox_glue "sandbox glue tests rlbox_segmentsfi_sandbox" | grep "Sandboxed"
cd ../../rlbox_lucet_directcall_benchmarks/build_release
echo -n "Direct call: "
./main_segmentsfi
cd ../..
echo "----------------------------"
