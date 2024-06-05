#!/bin/bash

set -e

LAUNCH_DIR=`pwd`
echo "Job Launched in directory $LAUNCH_DIR"

pegasus_dir=/p/lustre1/kogiou1/1000-genome-workflow/scratch/run_dir
pushd $pegasus_dir
cp /p/lustre1/kogiou1/GEN_JOB/run_dir/00/00/*.in .

LAUNCH_DIR=`pwd`
echo "Job job runs now at directory $LAUNCH_DIR"

export DLIO_PROFILER_INSTALLED=/usr/workspace/iopp/kogiou1/venvs/pegasus-env/lib/python3.9/site-packages/dlio_profiler/
export LD_LIBRARY_PATH=$DLIO_PROFILER_INSTALLED/lib:$DLIO_PROFILER_INSTALLED/lib64:$LD_LIBRARY_PATH
export DLIO_PROFILER_LOG_FILE=/usr/workspace/iopp/kogiou1/1000genome-workflow/traces/32_nodes_48_ppn/genome
#export DLIO_PROFILER_DATA_DIR=$pegasus_dir
export DLIO_PROFILER_DATA_DIR=all
export DLIO_PROFILER_ENABLE=1
export DLIO_PROFILER_INC_METADATA=1
export DLIO_PROFILER_INIT=PRELOAD
export DLIO_PROFILER_BIND_SIGNALS=0
export DLIO_PROFILER_LOG_LEVEL=ERROR
export DLIO_PROFILER_TRACE_COMPRESSION=1


dlio_profiler=$DLIO_PROFILER_INSTALLED/lib64/libdlio_profiler_preload.so

export LD_PRELOAD=$dlio_profiler

flux run -N32 -n1536 /usr/workspace/iopp/kogiou1/workflows/pegasus/install/bin/pegasus-mpi-cluster -v "$@"

