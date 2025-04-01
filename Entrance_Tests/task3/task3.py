import sys
import json
from pathlib import Path


def flatten_values(values):
    """Преобразует список значений в одномерный словарь."""
    flat_dict = {}
    for item in values:
        flat_dict[item['id']] = item['value']
    return flat_dict


def fill_values(tests_data, values_dict):
    """Заполняет значения в тестах на основе словаря значений."""

    tests = tests_data["tests"] if isinstance(tests_data, dict) else tests_data

    for test in tests:
        if test['id'] in values_dict:
            test['value'] = values_dict[test['id']]

        if 'values' in test:
            fill_values(test['values'], values_dict)


if __name__ == "__main__":

    if len(sys.argv) != 4:
        script_path = Path(__file__).relative_to(Path.cwd())
        print(f"Usage: python {script_path} "
              "<path_to_file_1.json> <path_to_file_2.json> <path_to_file_3.json>"
              )
        sys.exit(1)

    paths = {
        'values': next((arg for arg in sys.argv[1:] if 'values' in arg), None),
        'tests': next((arg for arg in sys.argv[1:] if 'tests' in arg), None),
        'report': next((arg for arg in sys.argv[1:] if 'report' in arg), None),
    }

    with open(paths['values']) as f:
        values = json.load(f)

    with open(paths['tests']) as f:
        tests = json.load(f)

    values_dict = flatten_values(values['values'])

    fill_values(tests, values_dict)

    with open(paths['report'], 'w') as f:
        json.dump(tests, f, indent=2)
