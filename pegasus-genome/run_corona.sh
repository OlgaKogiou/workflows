#!/bin/bash

### #FLUX: -N 32           				#number of nodes
### #FLUX: -n 1536					#number of processes
### #FLUX: -t 400m         				#walltime in minutes
### #FLUX: --setattr=system.bank=asccasc            	#account
### #FLUX: -q pbatch            			#queue to use

CPWD=$PWD

echo "virtual environment"
source /usr/workspace/iopp/kogiou1/venvs/pegasus-env/bin/activate

echo "fixing the PATH"
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/bin:$PATH
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/sbin:$PATH
export LD_LIBRARY_PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/lib:$LD_LIBRARY_PATH
export PATH=/usr/workspace/iopp/kogiou1/Montage/bin:$PATH

echo "Running condor"
. /usr/workspace/iopp/kogiou1/workflows/pegasus/install/condor.sh
condor_master
condor_status

echo "Cleaning folders"
rm -rf /p/lustre1/kogiou1/GEN_JOB
mkdir -p /p/lustre1/kogiou1/GEN_JOB
cp -r /usr/workspace/iopp/kogiou1/1000genome-workflow/* /p/lustre1/kogiou1/GEN_JOB

pushd /p/lustre1/kogiou1/GEN_JOB

cp $CPWD/sites.yml sites.corona.yml
cp $CPWD/daxgen_corona.py daxgen_corona.py

echo "Building workflow folder - Done"
./daxgen_corona.py -S sites.corona.yml -e condorpool -n run_dir --pmc

pushd /p/lustre1/kogiou1/GEN_JOB/run_dir

echo "Running Genome"
pegasus-run $PWD
sleep 21600
pegasus-status -l $PWD
# pegasus-remove $PWD

popd
popd
