#!/bin/bash
sleep 1
echo "Transition: Zero"
cd rlbox_lucet_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: Heavy"
cd zerocost_testing_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: Lucet"
cd rlbox_lucetstock_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: Mpkheavy"
cd rlbox_mpk_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: Segmentzero"
cd rlbox_segmentsfizerocost_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: NaCl"
cd rlbox_nacl_sandbox/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: NoOp"
cd rlbox_sandboxing_api/build_release
ctest -V
cd ../..

sleep 1
echo "Transition: Direct Zero"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_zerocost
cd ../..

sleep 1
echo "Transition: Direct Fullsave"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_fullsave
cd ../..

sleep 1
echo "Transition: Direct Regsave"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_regsave
cd ../..

sleep 1
echo "Transition: Direct Win"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_win
cd ../..

sleep 1
echo "Transition: Direct MPK"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_mpkfullsave
cd ../..

sleep 1
echo "Transition: Direct Segment"
cd rlbox_lucet_directcall_benchmarks/build_release
./main_segmentsfi
cd ../..
