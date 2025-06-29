# Translated from Fortran program potencia

import math

def main():
    n = int(input())
    total = 3
    while True:
        for x in range(1, total - 2 + 1):
            for y in range(1, total - x - 1 + 1):
                z = total - x - y
                if (x ** n + y ** n == z ** n):
                    print("hola, mundo")
        total = total + 1


if __name__ == "__main__":
    main()