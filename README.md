
# 🌀 Traductor de Fortran a Python (FYPP)

Este proyecto es un traductor automático de programas en Fortran 90 a Python 3, desarrollado utilizando **Flex**, **Bison/Yacc** y **C**. Su objetivo principal es facilitar la migración de código legado Fortran a un lenguaje más moderno y accesible como Python.

---

## 📁 Estructura del Repositorio

- `lexer.l` – Analizador léxico (Flex)
- `parser.y` – Analizador sintáctico (Bison/Yacc)
- `main.c` – Punto de entrada del compilador
- `build.sh` – Script para compilar el traductor
- `convertir_todos.sh` – Script para convertir varios archivos `.f90`
- `fermat.f90` – Programa de prueba en Fortran
- `fermat.py` – Resultado traducido del programa de Fermat
- `functions.c` – Funciones de apoyo (opcional)

---

## ⚙️ Requisitos

- Flex
- Bison
- GCC
- Linux, WSL o Cygwin (en Windows)

---

## 🧱 Compilación

### ✅ Usando `build.sh` (recomendado)

```bash
chmod +x build.sh
./build.sh
```

### 🧰 Compilación Manual

```bash
bison -d parser.y
flex lexer.l
gcc -o fypp parser.tab.c lex.yy.c main.c -lm
```

---

## ▶️ Uso

```bash
./fypp <archivo_entrada.f90> <archivo_salida.py>
```

Ejemplo:

```bash
./fypp fermat.f90 fermat.py
```

---

## 🔁 Conversión Múltiple con `convertir_todos.sh`

Este script convierte automáticamente todos los archivos `.f90` del directorio actual:

```bash
chmod +x convertir_todos.sh
./convertir_todos.sh
```

---

## 📄 Ejemplo de Traducción: Programa de Fermat

### Entrada Fortran:

```fortran
program potencia
    implicit none
    integer :: n, total, x, y, z
    read(*,*) n
    total = 3
    do while (.true.)
        do x = 1, total - 2
            do y = 1, total - x - 1
                z = total - x - y
                if (exp(x, n) + exp(y, n) == exp(z, n)) then
                    print *, "hola, mundo"
                end if
            end do
        end do
        total = total + 1
        if (total > 100) exit 
    end do
end program potencia
```

### Salida en Python:

```python
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
```

> El traductor actualmente convierte aproximadamente el **60%** del programa de Fermat.

---

## 🧪 Verificación de Errores

- Si el archivo `.py` no se genera, revisa:
  - Errores léxicos o de sintaxis reportados por la consola
  - Línea y columna del error serán mostrados

---

## 🧾 Licencia

Este proyecto puede ser usado con fines **educativos** y de investigación.
