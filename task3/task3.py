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
        # Проверяем, есть ли значение для текущего теста
        if test['id'] in values_dict:
            test['value'] = values_dict[test['id']]

        # Если у теста есть вложенные значения, вызываем функцию рекурсивно
        if 'values' in test:
            fill_values(test['values'], values_dict)


if __name__ == "__main__":

    if len(sys.argv) != 4:
        script_path = Path(__file__).resolve().relative_to(Path.cwd())
        print(f"Usage: python {script_path} "
              "<file_1.json> <file_2.json> <file_3.json>"
              )
        sys.exit(1)

    # Создаем словарь для хранения путей
    paths = {
        'values': next((arg for arg in sys.argv[1:] if 'values' in arg), None),
        'tests': next((arg for arg in sys.argv[1:] if 'tests' in arg), None),
        'report': next((arg for arg in sys.argv[1:] if 'report' in arg), None),
    }

    with open(paths['values']) as f:
        values = json.load(f)

    with open(paths['tests']) as f:
        tests = json.load(f)

    # Преобразуем значения в одномерный словарь
    values_dict = flatten_values(values['values'])

    # Заполняем значения в структуре тестов
    fill_values(tests, values_dict)

    # Запись результата в report.json
    with open(paths['report'], 'w') as f:
        json.dump(tests, f, indent=2)
