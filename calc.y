%{
#include <stdio.h>

void yyerror(char *c);
int yylex(void);

%}

%token INT SOMA EOL ABRE_PAR FECHA_PAR
%left SOMA

%%

PROGRAMA:
        PROGRAMA EXPRESSAO EOL { printf("Resultado: %d\n", $2); }
        |
        ;


EXPRESSAO:
    INT {
            $$ = $1;
            //printf("encontrei inteiro: %d\n", $$);
            printf("\t\tldr r0, =%d\n", $$);
            printf("\t\tstr r0, [sp, #4]!\n", $$);
        }

    | ABRE_PAR EXPRESSAO FECHA_PAR {
        $$ = $2;
        //printf("encontrei expressão entre parentesis: %d\n", $$);
    }

    | EXPRESSAO SOMA EXPRESSAO  {
        //printf("Encontrei soma: %d + %d = %d\n", $1, $3, $1+$3);
        $$ = $1 + $3;
        printf("\t\tldr r0, [sp], #-4\n");
        printf("\t\tldr r1, [sp], #-4\n");
        printf("\t\tadd r0, r0, r1\n");
        printf("\t\tstr r0, [sp, #4]!\n");
        }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
  yyparse();
  return 0;

}
