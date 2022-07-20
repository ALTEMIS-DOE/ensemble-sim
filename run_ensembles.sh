# Example command:
# ./test.sh -o path/to/output/dir -n 16

# -o: output path. this path contains all the simulation directories and their respective input xml files.
# -n: number of simulations

##########################
# GET INPUTS
##########################
while getopts o:n:s: flag
do
    case "${flag}" in
        o) output_path=$(readlink -f ${OPTARG});;
        n) num_sims=${OPTARG};;
    esac
done

# checks if variable is empty
if [ -z "$output_path" ]; then
    printf "ERROR: Argument for output path (-o) not found!\n"
    exit 1
fi

if [ -z "$num_sims" ]; then
    printf "ERROR: Argument for number of simulations (-n) not found!\n"
    exit 1
fi

echo "Output path => $output_path"
echo "Number of simulations => $num_sims"

##########################
# RUN ALL SIMULATIONS
##########################
for (( n=1; n<($num_sims+1); n++ ));
do
    cd ${output_path}/sim${n}
    rm -f run_amanzi.sh
    cp ${output_path}/shared_files/run_amanzi.sh run_sim${n}.sh
    sbatch run_sim${n}.sh

done
