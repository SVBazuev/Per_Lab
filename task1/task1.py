import sys
from pathlib import Path


class CircularArray:
    def __init__(self, n):
        self.n = n

    def get_path(self, m):
        path = []
        current_index = 0  # Начинаем с первого элемента

        while True:
            # Находим индекс конца текущего интервала
            end_index = (current_index + m - 1) % self.n

            # Добавляем элемент в путь
            path.append(str(current_index + 1))

            # Если мы достигли первого элемента, выходим из цикла
            if end_index == 0:
                break

            # Обновляем текущий индекс для следующего интервала
            current_index = end_index

        return ''.join(path)


if __name__ == "__main__":

    if len(sys.argv) != 3:
        script_path = Path(__file__).resolve().relative_to(Path.cwd())
        print(f"Usage: python {script_path} <n> <m>")
        sys.exit(1)

    n, m = map(int, sys.argv[1:])
    circular_array = CircularArray(n)
    result_path = circular_array.get_path(m)
    print(result_path)
