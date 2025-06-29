%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

int line_number = 1;
int column_number = 1;

void update_position() {
    column_number += yyleng;
}

char* process_escapes(const char* input) {
    // Implementación básica
    return strdup(input);
}

void lexical_error(const char* msg) {
    fprintf(stderr, "Lexical error at line %d, column %d: %s\n", 
            line_number, column_number, msg);
}
%}

%option noyywrap
%option yylineno

%%

[ \t]+                  { update_position(); }
\n                      { line_number++; column_number = 1; return NEWLINE; }

"program"               { update_position(); return PROGRAM; }
"end program"           { update_position(); return ENDPROGRAM; }
"implicit"              { update_position(); return IMPLICIT; }
"none"                  { update_position(); return NONE; }
"function"              { update_position(); return FUNCTION; }
"end function"          { update_position(); return ENDFUNCTION; }
"result"                { update_position(); return RESULT; }
"intent"                { update_position(); return INTENT; }
"in"                    { update_position(); return IN; }
"out"                   { update_position(); return OUT; }
"inout"                 { update_position(); return INOUT; }

"if"                    { update_position(); return IF; }
"then"                  { update_position(); return THEN; }
"else"                  { update_position(); return ELSE; }
"end if"                { update_position(); return ENDIF; }
"end"                   { update_position(); return END; }

"do"                    { update_position(); return DO; }
"end do"                { update_position(); return ENDDO; }
"for"                   { update_position(); return FOR; }
"to"                    { update_position(); return TO; }
"step"                  { update_position(); return STEP; }
"while"                 { update_position(); return WHILE; }
"exit"                  { update_position(); return EXIT; }

"print"                 { update_position(); return PRINT; }
"and"                   { update_position(); return AND; }
"or"                    { update_position(); return OR; }
"not"                   { update_position(); return NOT; }
"exp"                   { update_position(); return EXP; }

"read"                  { update_position(); return READ; }
"write"                 { update_position(); return WRITE; }
"real"                  { update_position(); return REAL; }
"integer"               { update_position(); return INTEGER; }
"select"                { update_position(); return SELECT; }
"case"                  { update_position(); return CASE; }

"sin"                   { update_position(); return SIN; }
"cos"                   { update_position(); return COS; }
"log"                   { update_position(); return LOG; }
"sqrt"                  { update_position(); return SQRT; }
"abs"                   { update_position(); return ABS; }

"::"                    { update_position(); return DOUBLECOLON; }
"=="                    { update_position(); return EQ; }
"!="                    { update_position(); return NEQ; }
"<="                    { update_position(); return LE; }
">="                    { update_position(); return GE; }
"<"                     { update_position(); return LT; }
">"                     { update_position(); return GT; }

\.true\.                { update_position(); yylval.str = strdup("True"); return TRUE; }
\.false\.               { update_position(); yylval.str = strdup("False"); return FALSE; }

"read"[ \t]*\([ \t]*\*[ \t]*,[ \t]*\*[ \t]*\)[ \t]*(!.*)? {
    update_position(); 
    return READ_STAR_STAR;
}

\"([^\"\n\\]|\\.)*\"    { 
    update_position(); 
    yylval.str = process_escapes(yytext);
    return STRING; 
}

[0-9]+\.?[0-9]*([eE][+-]?[0-9]+)? {
    update_position();
    if (strchr(yytext, '.') || strchr(yytext, 'e') || strchr(yytext, 'E')) {
        yylval.fnum = atof(yytext);
        return FLOAT;
    } else {
        yylval.num = atoi(yytext);
        return NUMBER;
    }
}

[a-zA-Z_][a-zA-Z0-9_]*  { 
    update_position(); 
    yylval.str = strdup(yytext); 
    return IDENTIFIER; 
}

"="                     { update_position(); return EQUALS; }
"+"                     { update_position(); return PLUS; }
"-"                     { update_position(); return MINUS; }
"*"                     { update_position(); return TIMES; }
"/"                     { update_position(); return DIVIDE; }
"%"                     { update_position(); return MOD; }
"**"                    { update_position(); return POWER; }

"("                     { update_position(); return '('; }
")"                     { update_position(); return ')'; }
","                     { update_position(); return ','; }

"!"[^\n]*               { update_position(); yylval.str = strdup(yytext+1); return COMMENT; }

.                       { 
    update_position(); 
    lexical_error("Unknown character");
    fprintf(stderr, "Character: '%s' (ASCII: %d)\n", yytext, yytext[0]); 
}

%%
