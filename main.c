#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Variables compartidas con el lexer y parser
extern int yyparse();
extern FILE* yyin;
extern FILE* output_file;
extern int line_number;
extern int column_number;

int main(int argc, char** argv) {
    if (argc != 3) {
        fprintf(stderr, "Uso: %s <archivo_entrada.f90> <archivo_salida.py>\n", argv[0]);
        return 1;
    }

    // Inicializar variables globales
    line_number = 1;
    column_number = 1;

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error al abrir archivo de entrada");
        return 1;
    }

    output_file = fopen(argv[2], "w");
    if (!output_file) {
        perror("Error al crear archivo de salida");
        fclose(yyin);
        return 1;
    }

    // Ejecutar parser y verificar errores
    int parse_result = yyparse();
    if (parse_result != 0) {
        fprintf(stderr, "Error durante el parsing (código %d)\n", parse_result);
    }

    fclose(yyin);
    fclose(output_file);
    
    return parse_result;
}
