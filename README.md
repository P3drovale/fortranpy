# Traductor de Fortran a Python

Este proyecto es un traductor automático de programas en Fortran 90 a Python 3, desarrollado utilizando **Flex**, **Bison/Yacc** y **C**. Su objetivo principal es facilitar la migración de código legado Fortran a un lenguaje más moderno y accesible como Python.

## 📁 Estructura del Repositorio

- `lexer.l` – Analizador léxico (Flex)
- `parser.y` – Analizador sintáctico (Bison/Yacc)
- `main.c` – Punto de entrada del compilador
- `build.sh` – Script para compilar el traductor
- `convertir_todos.sh` – Script para convertir varios archivos `.f90`
- `fermat.f90` – Programa de prueba en Fortran
- `fermat.py` – Resultado traducido del programa de Fermat
- `functions.c` – Funciones de apoyo (opcional)

## ⚙️ Requisitos

- **Flex**
- **Bison**
- **gcc**
- Sistema Linux, WSL o Cygwin (en Windows)

## 🧱 Compilación

Puedes compilar el traductor manualmente o usar el script:

### Usando `build.sh` (recomendado)

```bash
chmod +x build.sh
./build.sh
