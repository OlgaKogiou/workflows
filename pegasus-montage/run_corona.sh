#!/bin/bash


###FLUX: -t 30m                                      #walltime in minutes
###FLUX: --setattr=system.bank=asccasc            #account
###FLUX: -q pbatch

echo "Sourcing the environment"
source /usr/workspace/iopp/kogiou1/venvs/pegasus-env/bin/activate

echo "Fixing the PATH"
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/bin:$PATH
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/sbin:$PATH
export LD_LIBRARY_PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/lib:$LD_LIBRARY_PATH
export PATH=/usr/workspace/iopp/kogiou1/Montage/bin:$PATH

echo $PATH

echo "Running condor.."
. /usr/workspace/iopp/kogiou1/workflows/pegasus/install/condor.sh
condor_master
condor_status

echo "Directory fixing.."
rm -rf /p/lustre1/kogiou1/MO_JOB
mkdir -p /p/lustre1/kogiou1/MO_JOB
cp $PWD/sites.yml /p/lustre1/kogiou1/MO_JOB
cp $PWD/transformations.yml /p/lustre1/kogiou1/MO_JOB
cp $PWD/pegasus.properties /p/lustre1/kogiou1/MO_JOB

rm -rf ./traces/16_nodes_48_ppn
mkdir -p traces/16_nodes_48_ppn
pushd /p/lustre1/kogiou1/MO_JOB

rm -rf /p/lustre1/kogiou1/MO_JOB/data

rm -rf /p/lustre1/kogiou1/montage-workflow/scratch

echo "Creating data dir.."
/usr/workspace/iopp/kogiou1/montage-workflow-v3/montage-workflow.py --center "56.7 24.00" --degrees 1.0 --band dss:DSS2B:blue  --band dss:DSS2R:green --band dss:DSS2IR:red

echo "Plan workflow..."
pegasus-plan --dir work --dax data/montage-workflow.yml --output-site local --sites condorpool  --cluster whole --relative-dir run_dir

echo "Running workflow.."
pushd work/run_dir
/usr/workspace/iopp/kogiou1/workflows/pegasus/install/bin/pegasus-run $PWD

sleep 1200

pegasus-status -l $PWD
echo "Run worklow - End"

popd
popd
