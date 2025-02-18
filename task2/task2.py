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
            distance = math.sqrt(
                (p[0] - self.center[0]) ** 2
                + (p[1] - self.center[1]) ** 2
                )

            if distance == self.radius:
                result.append('0')

            elif distance < self.radius:
                result.append('1')

            else:
                result.append('2')

        return result



if __name__ == "__main__":

    if len(sys.argv) != 3:
        script_path = Path(__file__).relative_to(Path.cwd())
        print(
            f"Usage: python {script_path} "
            "<path_to_file_1.txt> <path_to_file_2.txt>"
            )
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
