import sys
import math
from pathlib import Path

class Circle:

    def __init__(self, center, radius):
        self.center = center
        self.radius = radius

    def position_points(self, points):
        result = []
        for p in points:
            # Вычисляем расстояние от центра окружности до точки
            distance = math.sqrt(
                (p[0] - self.center[0]) ** 2
                + (p[1] - self.center[1]) ** 2
                )

            # Сравниваем расстояние с радиусом
            if distance == self.radius:
                result.append('0')  # Точка на окружности
            elif distance < self.radius:
                result.append('1')  # Точка внутри окружности
            else:
                result.append('2')  # Точка снаружи окружности

        return result



if __name__ == "__main__":

    if len(sys.argv) != 3:
        script_path = Path(__file__).resolve().relative_to(Path.cwd())
        print(f"Usage: python {script_path} <file_1> <file_2>")
        sys.exit(1)

    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()
        center = tuple(map(float, lines[0].strip().split()))
        radius = float(lines[1].strip())

    with open(sys.argv[2], 'r') as f:
        lines = f.readlines()
        points = tuple(
            tuple(map(float, l.strip().split())) for l in lines if l.strip()
            )

    circle = Circle(center, radius)
    result = circle.position_points(points)
    print(*result, sep='\n')
