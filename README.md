# lbnl-ensemble-sim

## STEP 1: Generate input files for amanzi simulation.

It is recommended but not necessary to set up a virtual environment to run the code.
Use the following command to set up the environment.
> `conda env create -f requirement.yml`

## How to use the code?
There are two ways to run the code.
1. **Option 1:** Specify the code parameters in a configuration file.
   > `python generate_input_files.py @generate_input_files.cfg`
2. **Option 2:** Specify the code parameters in the command line.
   > `python generate_input_files.py --input_template /path/to/template.tpl --variable_mapping /path/to/variable_maps.yml --num_simulations 16 --output_dir /path/to/output_dir`

A combination of the two can be used as well where some parameters are specified in the configuration file and others are specified in the command line.

## What are the different files?
1. `generate_input_files.cfg`
   > Configuration parameters for running the code.
2. `farea_3d_tritium.tpl`
   > Template file
3. `sim_param_mapping.yml`
   > Mapping of the variables with their corresponding value ranges
   
   > #### File formats of variable map YAML files.

   > Variable map YAML files are accepted in either of the following formats:
    
   > <table border="0">
   >     <tr>
   >         <td><b style="font-size:30px">Format 1</b></td>
   >         <td><b style="font-size:30px">Format 2</b></td>
   >         <td><b style="font-size:30px">Format 3</b></td>
   >     </tr>
   >     <tr>
   >         <td>
   >             Range values for the variable
   >         </td>
   >         <td>
   >             Single values for the variable
   >         </td>
   >         <td>
   >             Multiple values for the variable
   >         </td>
   >     </tr>
   >     <tr>
   >         <td>
   >             Example file:
   >             <pre><code>
   > "@Perm@": 
   >   low:  5e-12*0.8
   >   high: 5e-12*1.2
   > "@Por@": 
   >   low: 0.39*0.8
   >   high: 0.39*1.2
   >             </code></pre>
   >         </td>
   >         <td>
   >             Example file:
   >             <pre><code>
   > "@Perm@": 
   > - 5e-12*0.8
   > "@Por@": 
   > - 0.39*0.8
   >             </code></pre>
   >         </td>
   >         <td>
   >             Example file:
   >             <pre><code>
   > "@Perm@": 
   > - 5e-12*0.8
   > - 5e-12*1.2
   > "@Por@": 
   > - 0.39*0.8
   > - 0.39*1.2
   >             </code></pre>
   >         </td>
   >     </tr>
   > </table>
    
   > A combination of the three can also be used to define values for the variables.
   > When multiple values are provided for one or more variables, all permutations are considered for the simulations.
   
4. `requirements.yml`
   > File used to create the virtual environment.



---
## STEP 2: Ensemble Simulation

[`run_ensembles.sh`](run_ensembles.sh) script is used to initiate the ensemble simulation.
This script requires two commandline inputs:
1. Output Directory (`-o`)
   > This directory contains all the individual simulation directories. The output of each simulation is stored in the respective directories.
3. Number of simulations (`-n`)
   > This is the number of simulation runs. This number should match the count of simulation directories.

### REQUIREMENT:

This script requires a `shared_files` directory within the Output Directory.

This `shared_files` directory must contain the following files:
1. `run_amanzi.sh`
   > This file is replicated for each simulation and the replicated version is stored in the simulation directory.
   > The `sbatch` configurations are specified in this file.
   > Number of processors is also specified in this file.
2. `farea_3D_barriers.exo`
3. `farea_tritium.bdg`



---
## STEP 3: Update success status of the each simulation run

[`update_simulation_success.py`](update_simulation_success.py) script is used to update the success status of each simulation in the `sampled_params.csv`. 
`sampled_params.csv` is generated in the output directory after running the 'generate_input_files.py'.

`update_simulation_success.py` script adds an additional column specifying the status for each row (simulation configuration).

Sample code run:
> `python3 update_simulation_success.py -i path/to/sampled_params.csv`

This will generate a new file `sampled_params_succ_status.csv` containing the success status for each simulation run.

