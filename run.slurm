#!/bin/bash
#SBATCH --job-name="Mars_gravity_1"
#SBATCH -p parallel

### NOTE: -N means number of Nodes requested.. but u need to 
###       specify the number of tasks with -n ... in fact
###       is more important -n that -N because if u say only -N
###	  slurm will asume -n equal to -N and will try to allocate
###       in this particular cae, 2 tasks, one in each node..
###	  So, I commented out this line and use -n in instead assuming
###       u need 56 cores
###SBATCH -N 2
#SBATCH -n 56

#SBATCH -t 12:00:00

### 	  For this amount of mem there is no need to request
###	  Each node has 128GB just play with it and request as many cores
###	  as needed to assure the mem u need ... if U need more than that 
###	  we still have some big mem modes of 1TB and 2TB each	
###SBATCH --mem=256MB

#SBATCH --mail-type=ALL
#SBATCH --mail-user=mnt242@nyu.edu
#SBATCH -o Job_%N_%u_%A_%a.out
#SBATCH -e Job_%N_%u_%A_%a.err

module load lammps

for i in {0..16}
do
InitialFileStep=519000
echo "First: $i+${InitialFileStep}"
CurrentStage=$((($i*(9*4000)) + $InitialFileStep))
echo "CurrentStage=$CurrentStage"
PreviousStage=$((($(($(($i-1))*(9*4000)))) + (InitialFileStep)))
echo "PreviousStage=$PreviousStage"
if [[ $i -ne 0 ]]
then
perl -pi -e 's/'"$PreviousStage"'/'"$CurrentStage"'/g' in.2d
cp dump/dump.pourCohe.$CurrentStage .
cp dump/restart.$CurrentStage.bed .
fi


### 	   Here you can use either mpiexec or srun ...
###	   srun is the recommended mecanism because it is 
###	   MPI implementation agnostic ... if u prefer mpiexec or mpirun
###	   You will need to load the correct MPI module
###time mpiexec lmp_mpi < in.2d> out.txt
time srun lmp_mpi < in.2d> out.txt
echo "Hey!"

done
