import sys
sys.dont_write_bytecode = True

import os
import glob
import argparse
import numpy as np
import pandas as pd
from tqdm import tqdm
from pprint import pprint
import matplotlib.pyplot as plt 

SUCCESSFUL_SIM_STR = "Amanzi::SIMULATION_SUCCESSFUL"


def parse_arguments() -> argparse.Namespace:
    """Reads commandline arguments and returns the parsed object.
    
    Returns:
        argparse.Namespace: parsed object containing all the input arguments.
    """
    parser = argparse.ArgumentParser(
        description="Print ensemble simulation summary.",
        fromfile_prefix_chars="@",  # helps read the arguments from a file.
    )
    
    required_named = parser.add_argument_group('required named arguments')
    required_named.add_argument(
        "-i",
        "--input_csv",
        type=str,
        required=True,
        help="Path to the input csv that contains all the simulation configurations.",
    )
    
    parser.add_argument(
        "-o",
        "--output_csv",
        type=str,
        default=None,
        help="Path to the output csv that contains all the simulation configurations and the success status.",
    )
    
    parser.add_argument(
        "-w",
        "--overwrite",
        action="store_true",
        help="Overwrite the updated dataframe to the input file.",
    )
    
    args, unknown = parser.parse_known_args()

    # print("--- args ---")
    # print(args)

    return args


def is_successful(simulation_path: str):
    """To check if the simulation ran successfully without any errors.
    
    Args:
        simulation_path (str): Path to the simulation directory.
    
    Returns:
        bool: Return True or False based on the status of the simulation run.
    """
    
    log_file = f"{simulation_path}/out.log"
    with open(log_file, 'r') as f:
        log = f.read()
        if log.find(SUCCESSFUL_SIM_STR) != -1:    # Simulation successful
            return True
    
    return False
                

def update_dataframe(csv_path):
    sims_csv_df = pd.read_csv(csv_path)
    
    # Information already exists
    if "@successful@" in sims_csv_df:
        print("Success status already exists.")
        return
    
    # Finding the information and writing as a csv
    succ_status = list()
    for sim_path in tqdm(sims_csv_df["@sim_path@"]):
        succ_status_i = is_successful(sim_path)
        succ_status.append(succ_status_i)
        # print(f"{sim_path: >120} => {succ_status_i: <10}")
    
    sims_csv_df["@successful@"] = succ_status

    return sims_csv_df
    

# /global/scratch/satyarth/Projects/ensemble_simulation_runs/ensemble_simulation_run2/sampled_params.csv
def main():
    args = parse_arguments()
    updated_dataframe = update_dataframe(args.input_csv)
    
    if updated_dataframe is None:
        print("No update needed.")
        return
    
    if args.output_csv is not None:
        output_csv_path = args.output_csv
    elif args.overwrite:
        output_csv_path = args.input_csv
    else:
        output_csv_path = args.input_csv.replace(".csv", "_succ_status.csv")
    
    updated_dataframe.to_csv(output_csv_path)
            
    print("Success status appended to the csv file.")


if __name__ == "__main__":
    main()
