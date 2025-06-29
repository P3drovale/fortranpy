#!/bin/bash

echo "🛠️ Generando parser con Bison..."
bison -d parser.y || { echo " Error en bison"; exit 1; }

echo "🛠️ Generando scanner con Flex (lexer.l)..."
flex lexer.l || { echo " Error en flex"; exit 1; }

echo "🛠️ Compilando todo con gcc..."
gcc -o fypp parser.tab.c lex.yy.c main.c -lfl || { echo " Error al compilar"; exit 1; }

echo "✅ Compilación completa. Ejecuta con:"
echo "./fypp archivo_entrada.f90 archivo_salida.py"
