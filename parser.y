%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

FILE* output_file = NULL;
extern int line_number;
extern int column_number;

void yyerror(const char *s);
int yylex();
char* str_concat(const char* a, const char* b);
char* indent_block(const char* block);
char* create_temp_var();
int temp_var_counter = 0;

typedef struct var_node {
    char* name;
    char* type;
    struct var_node* next;
} var_node_t;

var_node_t* declared_vars = NULL;

typedef struct func_node {
    char* name;
    char* return_type;
    char* params;
    char* body;
    struct func_node* next;
} func_node_t;

func_node_t* declared_funcs = NULL;

void add_variable(const char* name, const char* type);
char* get_variable_type(const char* name);
void free_variables();
void add_function(const char* name, const char* return_type, const char* params, const char* body);
void free_functions();
char* generate_python_functions();
%}

%union {
    int num;
    char* str;
    double fnum;
}

%type <str> program implicit_section variable_declarations variable_declaration 
%type <str> variable_list program_body functions function_declaration parameter_list
%type <str> parameter lines line statement_list expression term factor primary
%type <str> expression_list do_while;

%token READ_STAR_STAR TRUE FALSE EXIT
%token <str> STRING IDENTIFIER COMMENT
%token <num> NUMBER
%token <fnum> FLOAT
%token IF THEN ELSE END ENDIF FOR TO STEP PRINT WHILE EXP
%token READ WRITE REAL INTEGER SELECT CASE
%token SIN COS LOG SQRT ABS
%token EQUALS PLUS MINUS TIMES DIVIDE NEWLINE
%token EQ NEQ LT LE GT GE AND OR NOT
%token POWER MOD
%token PROGRAM ENDPROGRAM IMPLICIT NONE FUNCTION ENDFUNCTION RESULT INTENT IN OUT INOUT
%token DO ENDDO DOUBLECOLON

%right EQUALS
%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right POWER
%right UMINUS UPLUS NOT
%left '(' ')'

%%

program:
    PROGRAM IDENTIFIER NEWLINE implicit_section variable_declarations program_body functions ENDPROGRAM IDENTIFIER {
        char header[512];
        snprintf(header, sizeof(header), "# Translated from Fortran program %s\n\nimport math\n\n", $2);
        
        char* func_code = generate_python_functions();
        char* main_code = str_concat("def main():\n", indent_block($6));
        main_code = str_concat(main_code, "\n\nif __name__ == \"__main__\":\n    main()");
        
        fprintf(output_file, "%s%s", header, str_concat(func_code, main_code));
        
        free($2); free($4); free($5); free($6);
        free(func_code); free(main_code);
        free_variables();
        free_functions();
    }
    | lines {
        char header[] = "import math\n\ndef main():\n";
        char* body = indent_block($1);
        char* footer = "\n\nif __name__ == \"__main__\":\n    main()";
        fprintf(output_file, "%s%s%s", header, body, footer);
        free($1); free(body);
        free_variables();
    }
;

implicit_section:
    IMPLICIT NONE NEWLINE { $$ = strdup(""); }
    | /* empty */ { $$ = strdup(""); }
;

variable_declarations:
    variable_declarations variable_declaration { 
        $$ = str_concat($1, $2); 
        free($1); free($2);
    }
    | variable_declaration { $$ = $1; }
    | /* empty */ { $$ = strdup(""); }
;

variable_declaration:
    INTEGER DOUBLECOLON variable_list NEWLINE {
        $$ = $3;
        free($3);
    }
    | REAL DOUBLECOLON variable_list NEWLINE {
        $$ = $3;
        free($3);
    }
    | INTEGER IDENTIFIER NEWLINE {
        add_variable($2, "int");
        $$ = str_concat($2, " = 0\n");
        free($2);
    }
    | REAL IDENTIFIER NEWLINE {
        add_variable($2, "float");
        $$ = str_concat($2, " = 0.0\n");
        free($2);
    }
;

variable_list:
    variable_list ',' IDENTIFIER {
        add_variable($3, "int");
        $$ = str_concat(str_concat($1, str_concat($3, " = 0\n")), "");
        free($1); free($3);
    }
    | IDENTIFIER {
        add_variable($1, "int");
        $$ = str_concat($1, " = 0\n");
        free($1);
    }
;

functions:
    functions function_declaration { 
        $$ = str_concat($1, $2); 
        free($1); free($2); 
    }
    | function_declaration { $$ = $1; }
    | /* empty */ { $$ = strdup(""); }
;

function_declaration:
    FUNCTION IDENTIFIER '(' parameter_list ')' RESULT '(' IDENTIFIER ')' NEWLINE
    variable_declarations statement_list ENDFUNCTION IDENTIFIER {
        char func_def[512], return_stmt[256];
        snprintf(func_def, sizeof(func_def), "def %s(%s):\n", $2, $4);
        snprintf(return_stmt, sizeof(return_stmt), "    return %s\n", $8);
        
        char* func_body = indent_block(str_concat($11, str_concat($12, return_stmt)));
        $$ = str_concat(func_def, func_body);
        
        free($2); free($4); free($8); free($11); free($12); free($14);
        free(func_body);
    }
    | FUNCTION IDENTIFIER '(' parameter_list ')' NEWLINE
    variable_declarations statement_list ENDFUNCTION IDENTIFIER {
        char func_def[512];
        snprintf(func_def, sizeof(func_def), "def %s(%s):\n", $2, $4);
        
        char* func_body = indent_block(str_concat($7, $8));
        $$ = str_concat(func_def, func_body);
        
        free($2); free($4); free($7); free($8); free($10);
        free(func_body);
    }
;

parameter_list:
    parameter_list ',' parameter { 
        $$ = str_concat(str_concat($1, ", "), $3);
        free($1); free($3);
    }
    | parameter { $$ = $1; }
    | /* empty */ { $$ = strdup(""); }
;

parameter:
    INTEGER ',' INTENT '(' IN ')' DOUBLECOLON IDENTIFIER { $$ = strdup($8); free($8); }
    | INTEGER DOUBLECOLON IDENTIFIER { $$ = strdup($3); free($3); }
    | IDENTIFIER { $$ = strdup($1); free($1); }
;

program_body:
    statement_list { $$ = $1; }
;

lines:
    lines line {
        if ($2 && strlen($2) > 0) {
            $$ = str_concat($1, $2);
            free($1);
        } else {
            $$ = $1;
        }
        free($2);
    }
    | /* empty */ { $$ = strdup(""); }
;

line:
    NEWLINE { $$ = strdup(""); }
    | COMMENT NEWLINE {
        $$ = str_concat("# ", str_concat($1, "\n"));
        free($1);
    }
    | IDENTIFIER EQUALS expression NEWLINE {
        $$ = str_concat(str_concat($1, " = "), str_concat($3, "\n"));
        free($1); free($3);
    }
    | PRINT TIMES ',' STRING NEWLINE {
        $$ = str_concat("print(", str_concat($4, ")\n"));
        free($4);
    }
    | PRINT TIMES ',' expression NEWLINE {
        $$ = str_concat("print(", str_concat($4, ")\n"));
        free($4);
    }
    | PRINT expression NEWLINE {
        $$ = str_concat("print(", str_concat($2, ")\n"));
        free($2);
    }
    | READ '(' '*' ',' '*' ')' IDENTIFIER NEWLINE {
        $$ = str_concat($7, " = int(input())\n");
        free($7);
    }
    | READ_STAR_STAR IDENTIFIER NEWLINE {
        $$ = str_concat($2, " = int(input())\n");
        free($2);
    }
    | READ '(' '*' ',' '*' ')' variable_list NEWLINE {
        $$ = str_concat($7, " = list(map(int, input().split()))\n");
        free($7);
    }
    | READ '(' '*' ',' IDENTIFIER ')' NEWLINE {
        $$ = str_concat($5, " = float(input())\n");
        free($5);
    }
    | WRITE '(' '*' ',' expression ')' NEWLINE {
        $$ = str_concat("print(", str_concat($5, ")\n"));
        free($5);
    }
    | do_while { $$ = $1; }
    | DO NEWLINE statement_list ENDDO NEWLINE {
        $$ = str_concat("while True:\n", indent_block($3));
        free($3);
    }
    | DO IDENTIFIER EQUALS expression ',' expression NEWLINE statement_list ENDDO NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "for %s in range(%s, %s + 1):\n", $2, $4, $6);
        $$ = str_concat(header, indent_block($8));
        free($2); free($4); free($6); free($8);
    }
    | DO IDENTIFIER EQUALS expression ',' expression ',' expression NEWLINE statement_list ENDDO NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "for %s in range(%s, %s + 1, %s):\n", $2, $4, $6, $8);
        $$ = str_concat(header, indent_block($10));
        free($2); free($4); free($6); free($8); free($10);
    }
    | FOR IDENTIFIER EQUALS expression TO expression NEWLINE statement_list END NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "for %s in range(%s, %s + 1):\n", $2, $4, $6);
        $$ = str_concat(header, indent_block($8));
        free($2); free($4); free($6); free($8);
    }
    | FOR IDENTIFIER EQUALS expression TO expression STEP expression NEWLINE statement_list END NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "for %s in range(%s, %s + 1, %s):\n", $2, $4, $6, $8);
        $$ = str_concat(header, indent_block($10));
        free($2); free($4); free($6); free($8); free($10);
    }
    | WHILE expression NEWLINE statement_list END NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "while %s:\n", $2);
        $$ = str_concat(header, indent_block($4));
        free($2); free($4);
    }
    | IF expression THEN NEWLINE statement_list ENDIF NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "if %s:\n", $2);
        $$ = str_concat(header, indent_block($5));
        free($2); free($5);
    }
    | IF expression THEN NEWLINE statement_list END NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "if %s:\n", $2);
        $$ = str_concat(header, indent_block($5));
        free($2); free($5);
    }
    | IF expression GT expression THEN EXIT NEWLINE {
        char cond[256];
        snprintf(cond, sizeof(cond), "if %s > %s:\n    break\n", $2, $4);
        $$ = strdup(cond);
        free($2); free($4);
    }
    | IF expression THEN NEWLINE statement_list ELSE NEWLINE statement_list END NEWLINE {
        char header[512];
        snprintf(header, sizeof(header), "if %s:\n", $2);
        char* if_body = indent_block($5);
        char* else_body = indent_block($8);
        $$ = str_concat(str_concat(str_concat(header, if_body), "else:\n"), else_body);
        free($2); free($5); free($8); free(if_body); free(else_body);
    }
    | EXIT NEWLINE {
        $$ = strdup("break\n");
    }
    | error NEWLINE {
        yyerror("Syntax error");
        $$ = strdup("");
        yyerrok;
    }
;

do_while:
    DO WHILE '(' TRUE ')' NEWLINE statement_list ENDDO NEWLINE {
        $$ = str_concat("while True:\n", indent_block($7));
        free($7);
    }
;

statement_list:
    statement_list line {
        if ($2 && strlen($2) > 0) {
            $$ = str_concat($1, $2);
            free($1);
        } else {
            $$ = $1;
        }
        free($2);
    }
    | /* empty */ { $$ = strdup(""); }
;

expression:
    expression OR expression { 
        $$ = str_concat(str_concat($1, " or "), $3);
        free($1); free($3);
    }
    | expression AND expression { 
        $$ = str_concat(str_concat($1, " and "), $3);
        free($1); free($3);
    }
    | expression EQ expression { 
        $$ = str_concat(str_concat($1, " == "), $3);
        free($1); free($3);
    }
    | expression NEQ expression { 
        $$ = str_concat(str_concat($1, " != "), $3);
        free($1); free($3);
    }
    | expression LT expression { 
        $$ = str_concat(str_concat($1, " < "), $3);
        free($1); free($3);
    }
    | expression LE expression { 
        $$ = str_concat(str_concat($1, " <= "), $3);
        free($1); free($3);
    }
    | expression GT expression { 
        $$ = str_concat(str_concat($1, " > "), $3);
        free($1); free($3);
    }
    | expression GE expression { 
        $$ = str_concat(str_concat($1, " >= "), $3);
        free($1); free($3);
    }
    | expression PLUS expression { 
        $$ = str_concat(str_concat($1, " + "), $3);
        free($1); free($3);
    }
    | expression MINUS expression { 
        $$ = str_concat(str_concat($1, " - "), $3);
        free($1); free($3);
    }
    | term { $$ = $1; }
;

term:
    term TIMES factor { 
        $$ = str_concat(str_concat($1, " * "), $3);
        free($1); free($3);
    }
    | term DIVIDE factor { 
        $$ = str_concat(str_concat($1, " / "), $3);
        free($1); free($3);
    }
    | term MOD factor { 
        $$ = str_concat(str_concat($1, " % "), $3);
        free($1); free($3);
    }
    | factor { $$ = $1; }
;

factor:
    factor POWER primary { 
        $$ = str_concat(str_concat($1, " ** "), $3);
        free($1); free($3);
    }
    | MINUS factor %prec UMINUS {
        $$ = str_concat("-", $2);
        free($2);
    }
    | PLUS factor %prec UPLUS {
        $$ = $2;
    }
    | NOT factor {
        $$ = str_concat("not ", $2);
        free($2);
    }
    | primary { $$ = $1; }
;

primary:
    NUMBER {
        char buffer[32];
        snprintf(buffer, sizeof(buffer), "%d", $1);
        $$ = strdup(buffer);
    }
    | FLOAT {
        char buffer[32];
        snprintf(buffer, sizeof(buffer), "%.6f", $1);
        $$ = strdup(buffer);
    }
    | IDENTIFIER { 
        $$ = strdup($1); 
        free($1);
    }
    | IDENTIFIER '(' expression_list ')' {
        $$ = str_concat(str_concat($1, "("), str_concat($3, ")"));
        free($1); free($3);
    }
    | STRING {
        $$ = strdup($1);
        free($1);
    }
    | '(' expression ')' {
        $$ = str_concat("(", str_concat($2, ")"));
        free($2);
    }
    | TRUE {
        $$ = strdup("True");
    }
    | FALSE {
        $$ = strdup("False");
    }
    | EXP '(' expression ',' expression ')' {
        $$ = str_concat(str_concat($3, " ** "), $5);
        free($3); free($5);
    }
    | SIN '(' expression ')' {
        $$ = str_concat("math.sin(", str_concat($3, ")"));
        free($3);
    }
    | COS '(' expression ')' {
        $$ = str_concat("math.cos(", str_concat($3, ")"));
        free($3);
    }
    | LOG '(' expression ')' {
        $$ = str_concat("math.log(", str_concat($3, ")"));
        free($3);
    }
    | SQRT '(' expression ')' {
        $$ = str_concat("math.sqrt(", str_concat($3, ")"));
        free($3);
    }
    | ABS '(' expression ')' {
        $$ = str_concat("abs(", str_concat($3, ")"));
        free($3);
    }
;

expression_list:
    expression_list ',' expression {
        $$ = str_concat(str_concat($1, ", "), $3);
        free($1); free($3);
    }
    | expression { $$ = $1; }
    | /* empty */ { $$ = strdup(""); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", line_number, s);
}

char* str_concat(const char* a, const char* b) {
    if (!a) a = "";
    if (!b) b = "";
    char* result = malloc(strlen(a) + strlen(b) + 1);
    if (!result) {
        fprintf(stderr, "Memory error in str_concat\n");
        exit(1);
    }
    strcpy(result, a);
    strcat(result, b);
    return result;
}

char* indent_block(const char* block) {
    if (!block || strlen(block) == 0) {
        return strdup("    pass\n");
    }
    
    size_t len = strlen(block);
    char* result = malloc(len * 2 + 10);
    if (!result) {
        fprintf(stderr, "Memory error in indent_block\n");
        exit(1);
    }
    result[0] = '\0';
    
    const char* p = block;
    int at_line_start = 1;
    
    while (*p) {
        if (at_line_start && *p != '\n') {
            strcat(result, "    ");
            at_line_start = 0;
        }
        
        strncat(result, p, 1);
        
        if (*p == '\n') {
            at_line_start = 1;
        }
        p++;
    }
    
    if (len > 0 && block[len-1] != '\n') {
        strcat(result, "\n");
    }
    
    return result;
}

char* create_temp_var() {
    char* temp = malloc(20);
    if (!temp) {
        fprintf(stderr, "Memory error in create_temp_var\n");
        exit(1);
    }
    snprintf(temp, 20, "_temp_%d", temp_var_counter++);
    return temp;
}

void add_variable(const char* name, const char* type) {
    var_node_t* new_var = malloc(sizeof(var_node_t));
    if (!new_var) {
        fprintf(stderr, "Memory error in add_variable\n");
        exit(1);
    }
    new_var->name = strdup(name);
    new_var->type = strdup(type);
    new_var->next = declared_vars;
    declared_vars = new_var;
}

char* get_variable_type(const char* name) {
    var_node_t* current = declared_vars;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current->type;
        }
        current = current->next;
    }
    return "unknown";
}

void free_variables() {
    var_node_t* current = declared_vars;
    while (current) {
        var_node_t* next = current->next;
        free(current->name);
        free(current->type);
        free(current);
        current = next;
    }
    declared_vars = NULL;
}

void add_function(const char* name, const char* return_type, const char* params, const char* body) {
    func_node_t* new_func = malloc(sizeof(func_node_t));
    if (!new_func) {
        fprintf(stderr, "Memory error in add_function\n");
        exit(1);
    }
    new_func->name = strdup(name);
    new_func->return_type = strdup(return_type);
    new_func->params = strdup(params);
    new_func->body = strdup(body);
    new_func->next = declared_funcs;
    declared_funcs = new_func;
}

void free_functions() {
    func_node_t* current = declared_funcs;
    while (current) {
        func_node_t* next = current->next;
        free(current->name);
        free(current->return_type);
        free(current->params);
        free(current->body);
        free(current);
        current = next;
    }
    declared_funcs = NULL;
}

char* generate_python_functions() {
    if (!declared_funcs) {
        return strdup("");
    }
    
    char* result = strdup("");
    func_node_t* current = declared_funcs;
    
    while (current) {
        char func_def[512];
        snprintf(func_def, sizeof(func_def), "def %s(%s):\n", current->name, current->params);
        
        char* func_body = indent_block(current->body);
        char* temp = str_concat(result, str_concat(func_def, func_body));
        
        free(result);
        result = temp;
        free(func_body);
        
        current = current->next;
    }
    
    return str_concat(result, "\n");
}
