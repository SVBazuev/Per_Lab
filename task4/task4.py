import sys
from pathlib import Path


def calculate_minimum_moves(nums):
    # Сортируем массив для нахождения медианы
    nums.sort()
    n = len(nums)

    # Находим медиану
    if n % 2 == 1:
        median = nums[n // 2]
    else:
        # Для четного количества берем среднее
        median = (nums[n // 2 - 1] + nums[n // 2]) // 2

    # Считаем количество ходов
    moves = sum(abs(num - median) for num in nums)
    return moves


if __name__ == "__main__":

    if len(sys.argv) != 2:
        script_path = Path(__file__).resolve().relative_to(Path.cwd())
        print(f"Usage: python {script_path} <file_1.txt>")
        sys.exit(1)

    with open(sys.argv[1], 'r') as f:
        nums = [int(l.strip()) for l in f.readlines() if l != '']

    # Вычисляем минимальное количество ходов
    result = calculate_minimum_moves(nums)

    # Выводим результат
    print(result)
