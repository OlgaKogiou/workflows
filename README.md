# Instructions for running Workflows with Pegasus in LC Corona with Flux:

Step 1: Install Condor

1.1 Get the zip:
wget https://research.cs.wisc.edu/htcondor/tarball/10.x/current/condor-x86_64_CentOS8-stripped.tar.gz

1.2 Untar to your condor folder:
tar -x -f condor*.tar.gz
mkdir condor
cd condor-*stripped
mv * ../condor
cd ..
(rm -rf condor-*stripped 
rm condor-*stripped.tar.gz —> delete the condor*.tar.gz and the condor-*stripped)

1.3 Configure:
cd condor
./bin/make-personal-from-tarball

Step 2: Install Pegasus

2.1 Get the zip from Tarballs:
wget https://download.pegasus.isi.edu/pegasus/5.0.7/pegasus-binary-5.0.7-x86_64_rhel_7.tar.gz 

wget https://download.pegasus.isi.edu/pegasus/5.0.7/pegasus-worker-5.0.7-x86_64_rhel_7.tar.gz

2.2. Untar to your pegasus folder (both for pegasus and pegasus-worker):
tar zxf pegasus-*.tar.gz
rm pegasus-*.tar.gz

Step 3:  Install and compile Montage

3.1 Get the code:
git clone https://github.com/Caltech-IPAC/Montage.git

3.2 Compile:
make

NOTE: make sure there are no errors. By cloning the GitHub repo we get the most recent version, likely with no compiler errors. 
cd Montage/bin and make sure it is not empty.

3.3 Save in Paths:
export PATH=/usr/workspace/iopp/kogiou1/Montage/bin:$PATH

Step 4: Get the montage-pegasus-v3

4.1 Create and activate Virtual Environment:
python3 -m venv /path/to/pegasus-env
source /usr/workspace/iopp/kogiou1/venvs/pegasus-env/bin/activate

4.2 Install dependencies:
pip install astropy
pip install pegasus-wms

4.3 Get the code:
git clone https://github.com/pegasus-isi/montage-workflow-v3.git

Set 5: Compile the pegasus-mpi-cluster from source:

5.1 Get the code:
git clone https://github.com/pegasus-isi/pegasus/tree/master

5.2 make sure you’re in the virtual environment for pegasus:
source /usr/workspace/iopp/kogiou1/venvs/pegasus-env/bin/activate

5.3 make sure you have the prerequisites:
* Git
* Java 8 or higher
* Python 3.5 or higher
* R
* Ant
* gcc
* g++
* make
* tox 3.14.5 or higher
* mysql (optional, required to access MySQL databases)
* postgresql (optional, required to access PostgreSQL databases)
* Python pyyaml
* Python GitPython

5.4 compile:
cd pegasus
ant compile-pegasus-mpi-cluster

5.5 copy it to your pegasus folder:
cd packages/pegasus-mpi-cluster/
cp pegasus-mpi-cluster/ /usr/workspace/iopp/kogiou1/workflows/pegasus-5.0.7/bin

NOTE: if errors while compiling make sure that MVAPICH is loaded:
module load mvapich2-tce/2.3.7
echo $LD_LIBRARY_PATH
/usr/tce/packages/mvapich2-tce/mvapich2-2.3.7-intel-classic-2021.6.0/lib:/usr/tce/packages/texlive/texlive-20220321/lib

Step 6: Create a single “install” directory for all pegasus software:
(This will help in resolving errors like “cannot find .. in your path”)

6.1 Move into pegasus directory (the one you compiled from source) and make a directory called install:
cd pegasus
mkdir install

6.2 Copy all components from pegasus-5.0.7 and condor in the pegasus/install folder:
cd ../condor 
cp * ../pegasus/install
cp -r *  ../pegasus/install
cd ../pegasus-5.0.7
cp * ../pegasus/install
cp -r *  ../pegasus/install

NOTE: if error for overwriting /bin or /lib folders you have to do it manually by cd inside those folders and cp everything to /pegasus/install/bin or 
/pegasus/install/lib. Make sure all the components are there otherwise pegasus and condor cannot run

Step 7: Run workflows with pegasus:
7.1 Allocate a node with flux:
flux alloc -N3 -n48

NOTE: make sure you are in the virtual environment still. If not source it again by repeating 5.2

7.2 Save to PATH:
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/bin:$PATH
export PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install/sbin:$PATH
export LD_LIBRARY_PATH=/usr/workspace/iopp/kogiou1/workflows/pegasus/install//lib:$LD_LIBRARY_PATH
(source ~/.bashrc)

7.3 Run Condor:
chmod 777 /usr/workspace/iopp/kogiou1/workflows/pegasus/install/condor.sh
. /usr/workspace/iopp/kogiou1/workflows/pegasus/install/condor.sh
condor_master
condor_status (it should show the activity)
condor_q (it should show the jobs running)

NOTE: if errors echo the LD_LIBRARY_PATH and the PATH and make sure /pegasus/install is there

NOTE: To check if condor_shedd and all other condor processes are running
ps aux | grep condor

NOTE: if condor throws error while trying to connect to another node then:
Exit the flux allocation: exit
Check your processes: ps -u USER
Kill all your processes (or those related to condor if any): killall -u USER
Repeat 6.3, 6.4, 5.2, 6.5
If again problem: condor_restart, 6.5

7.4 Test Pegasus:
pegasus-version (should show 5.0.7)

NOTE: If Error: Cannot find file with permissions: touch that file and make sure it has those permissions

7.5 Configure the Condor/SLURM interface
pegasus-configure-glite

NOTE: If Error: Cannot find file with permissions: touch that file and make sure it has those permissions

### To run Montage workflow on LC Corona with 16 nodes and 48 ppn:

flux batch -N16 -n768 -c1 --queue=pbatch -t 30m --setattr=system.bank=asccasc ./run_corona.sh

### To run Genome workflow on LC Corona with 32 nodes and 48 ppn:

flux batch -N32 -n1536 -c1 --queue=pbatch -t 360m --setattr=system.bank=asccasc ./run_corona.sh

To find if thw job is running: flux jobs
To find if there has been an error for the workflow: pegasus-analyzer $PWD
