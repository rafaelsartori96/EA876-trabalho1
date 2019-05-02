
%{
#include <stdlib.h>
#include "y.tab.h"

void yyerror(char *);

%}


%%

[0-9]+    {
    yylval = atoi(yytext);
    return INT;
}

[+]     {
    return SOMA;
}

[-]     {
    return SUBTRACAO;
}

[*]     {
    return MULTIPLICACAO;
}

[(]     {
    return ABRE_PAR;
}

[)]     {
    return FECHA_PAR;
}

[ \t\n]+ ;

.     {
    yyerror("Token nao reconhecido!\n");
}

%%

int yywrap() {
  return 1;
}
