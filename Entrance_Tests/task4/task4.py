import sys
from pathlib import Path
import numpy as np


def calculate_minimum_moves_numpy(nums):
    nums_array = np.array(nums)
    median = np.median(nums_array)
    moves = np.sum(np.abs(nums_array - median))

    return int(moves)

if __name__ == "__main__":

    if len(sys.argv) != 2:
        script_path = Path(__file__).relative_to(Path.cwd())
        print(f"Usage: python {script_path} <path_to_file_1.txt>")
        sys.exit(1)

    with open(sys.argv[1], 'r') as f:
        nums = [int(l.strip()) for l in f.readlines() if l != '']

    result = calculate_minimum_moves_numpy(nums)

    print(result)
