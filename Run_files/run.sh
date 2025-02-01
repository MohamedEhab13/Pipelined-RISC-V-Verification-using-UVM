#!/bin/bash

# Set variables
compile_cmd="vcs -sverilog -ntb_opts uvm-1.2 -f files.f -cm line+fsm+tgl+branch+cond -timescale=1ns/1ps +vcs+flush+all -full64 +vc -q +v2k -fsdb -debug_access+all -l vcs_out.log"
sim_exe="./simv"
log_file="run_all_tests.log"
test_list="Test_Cases/test_list.f"
coverage_dir="Coverage_Report"
vdb_files=() # Array to store .vdb directories for merging

# Clean previous logs and output files
echo "Cleaning previous logs and coverage data..."
rm -f $log_file *.log *.fsdb simv
rm -rf *.vdb $coverage_dir MERGE_COV

# Compile the design (one binary per test for independent vdb files)
echo "Compiling design..."
$compile_cmd
if [ $? -ne 0 ]; then
    echo "Compilation failed! Check vcs_out.log for details."
    exit 1
fi
echo "Compilation successful!"

# Run each test and generate a separate coverage database
if [ ! -f "$test_list" ]; then
    echo "Test list file '$test_list' not found!"
    exit 1
fi

echo "Running tests..."
while read -r test_name; do
    if [[ -z "$test_name" || "$test_name" == \#* ]]; then
        continue # Skip empty lines or comments
    fi

    echo "Running test: $test_name"
    test_vdb="${test_name}.vdb"
    vdb_files+=("-dir $test_vdb") # Add to list of VDB directories

    # Run the test and generate a unique VDB directory
    $sim_exe simv.log +UVM_TESTNAME="$test_name" +covoverwrite -cm_dir $test_vdb
    if [ $? -ne 0 ]; then
        echo "Test $test_name failed! Check simv.log for details." | tee -a $log_file
    else
        echo "Test $test_name passed!" | tee -a $log_file
    fi
done < "$test_list"

# Merge all coverage databases
echo "Merging coverage data from all tests..."
urg "${vdb_files[@]}" -format both -dbname MERGE_COV -report $coverage_dir
if [ $? -ne 0 ]; then
    echo "Coverage merge failed! Check for issues with the VDB directories."
    exit 1
fi

echo "Coverage merge successful! Report available in $coverage_dir"
echo "All tests completed. Check $log_file for summary."

#clean on finish
rm  -rf  *~  csrc  simv*  vc_hdrs.h  ucli.key *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vcd *.vdb *.daidir *_sim

