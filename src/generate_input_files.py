import sys
sys.dont_write_bytecode = True

from pyprojroot import here
root = here(project_files=[".here"])
sys.path.append(str(root))

import os
import yaml
import shutil
import argparse
import numpy as np
import pandas as pd
from pprint import pprint
from joblib import Parallel, delayed

from src import variable_maps_parser as vmp

parallel_function = Parallel(n_jobs=-1, verbose=5)

PARAMS_CSV_FNAME = "sampled_params.csv"


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Main function to generate simulation input files.",
        fromfile_prefix_chars="@",  # helps read the arguments from a file.
    )
    
    requiredNamed = parser.add_argument_group('required named arguments')
    
    requiredNamed.add_argument(
        "-t",
        "--input_template",
        type=str,
        default=None,
        help="Path to the input template that contains all the simulation parameters.",
    )

    requiredNamed.add_argument(
        "-v",
        "--variable_mapping_file",
        type=str,
        default=None,
        help="Mapping of different varible keys to its value ranges.",
    )

    requiredNamed.add_argument(
        "-n",
        "--num_simulations",
        type=int,
        default=16,
        help="The number of desired simulation runs. This is same as the number if input files generated.",
    )
    requiredNamed.add_argument(
        "-o",
        "--output_dir",
        type=str,
        default=None,
        help="The output directory where the generated files are stored.",
    )

    parser.add_argument(
        "-f",
        "--input_format",
        type=str,
        default="xml",
        help="Format of the input simulation file that will be generated.",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Marking this flag will overwrite the existing simulations in the output directory.",
    )

    args, unknown = parser.parse_known_args()

    # print("--- args ---")
    # print(args)

    return args


def generate_input_configs(template_str: str, var_maps: dict, output_dir: str, template_filename: str, gensim_file_format: str) -> None:
    """Generates input configurations for the given variable map. The variable maps are replaced in the template file and stored as a new simulation configuration file in its respective simulation folder in the output directory.
    
    Args:
        template_str (str): the simulation input file read as a string where the configuration params are stored as variables instead of numerical values.
        var_maps (dict): dictionary containing the mapping of each template variable and its numerical value.
        output_dir (str): path of directory containing all the simulation directories.
        template_filename (str): path of the template file.
        gensim_file_format (str): format of the input simulation file that will be generated.
        
    """
    
    tpl_str = template_str

    # for a single input file:
    for k in var_maps:
        # rand_val = np.random.uniform(var_maps[k]["low"], var_maps[k]["high"])
        tpl_str = tpl_str.replace(k, str(var_maps[k]))
#         print(f"updating {k} to {var_maps[k]}...")

    output_filepath = os.path.join(
        output_dir,
        f"sim{var_maps['@serial_number@']}",
        os.path.basename(template_filename).replace(".tpl", f".{gensim_file_format}"),
    )
    try:
        os.makedirs(os.path.dirname(output_filepath))
    except Exception as e:
        print("Simulation directory already exists.")

    with open(output_filepath, "w") as f_out:
        f_out.writelines(tpl_str)


def main():
    # --- Parsing commandline arguments and printing them to the console
    args = parse_arguments()
    print("--- Arguments ---")
    for k in args.__dict__:
        print(f"{k} => {args.__dict__[k]}")
        
    params_csv_path = os.path.join(args.output_dir, PARAMS_CSV_FNAME)

    # --- Checking if some simulations have already been generated
    if args.overwrite:  # CASE A: force overwriting over previous simulations   
        print("CASE A: Overwriting existing simulation configurations!")
        shutil.rmtree(args.output_dir)    # delete the output dir
        os.mkdir(args.output_dir)
        existing_sims_last_sno = 0
        params_df_old = pd.DataFrame(None)

    elif not os.path.exists(params_csv_path):  # CASE B: no previous simulations
        print("CASE B: Generating new simulation configurations!")
        existing_sims_last_sno = 0
        params_df_old = pd.DataFrame(None)

    else:  # CASE C: extend after previous simulations
        print("CASE C: Appending new simulation configurations to the existing ones!")
        params_df_old = pd.read_csv(params_csv_path)
        existing_sims_last_sno = int(params_df_old["@serial_number@"].iloc[-1])

    # --- Parsing Template data
    with open(args.input_template, "r") as tpl_f:
        tpl_str = "".join(tpl_f.readlines())

    # --- Parsing YAML file for variable maps
    var_map_list = vmp.get_config_list(
        mapping_file=args.variable_mapping_file,
        sims_offset=existing_sims_last_sno,
        num_sims=args.num_simulations,
        output_dir=args.output_dir,
    )

    # --- Saving the randomly sampled parameters to a CSV
    params_df_new = pd.DataFrame(var_map_list)
    params_df_combined = pd.concat([params_df_old, params_df_new], axis=0)
    params_df_combined.to_csv(params_csv_path, index=False)

    # --- Replacing values in the template file with the mappings - PARALLEL for all files
    parallel_function(
        delayed(generate_input_configs)(
            template_str=tpl_str,
            var_maps=var_map_i,
            output_dir=args.output_dir,
            template_filename=args.input_template,
            gensim_file_format=args.input_format,
        )
        for var_map_i in var_map_list
    )


if __name__ == "__main__":
    main()
