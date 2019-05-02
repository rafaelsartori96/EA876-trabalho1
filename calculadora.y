%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(char *c);
int yylex(void);
void mprintf(char *s);
void realocar();

char *saida = NULL;
int tamanho = 0;

%}

%token INT SOMA SUBTRACAO MULTIPLICACAO ABRE_PAR FECHA_PAR
%left SOMA SUBTRACAO
%left MULTIPLICACAO

%%

PROGRAMA:
    EXPRESSAO {
        printf("end\n");
        printf("; Resultado: %d\n", $1);
	    return 0;
    }
    ;


EXPRESSAO:
    INT {
        $$ = $1;
        //printf("encontrei inteiro: %d\n", $$);
        printf("ldr r0, =%d\n", $$);
        printf("str r0, [sp, #4]!\n");
    }

    | SUBTRACAO INT {
        $$ = -$2;
        //printf("encontrei inteiro: %d\n", $$);
        printf("ldr r0, =%d\n", $$);
        printf("str r0, [sp, #4]!\n");
    }

    | ABRE_PAR EXPRESSAO FECHA_PAR {
        $$ = $2;
        //printf("encontrei expressão entre parentesis: %d\n", $$);
    }

    | EXPRESSAO MULTIPLICACAO EXPRESSAO  {
        $$ = $1 * $3;
        //printf("Encontrei multiplicação: %d * %d = %d\n", $1, $3, $$);
        printf("ldr r0, [sp], #-4\n");
        printf("ldr r1, [sp], #-4\n");
        printf("bl multiplicar\n");
        printf("str r0, [sp, #4]!\n");
    }

    | EXPRESSAO SUBTRACAO EXPRESSAO  {
        $$ = $1 - $3;
        //printf("Encontrei subtração: %d - %d = %d\n", $1, $3, $$);
        printf("ldr r0, [sp], #-4\n");
        printf("ldr r1, [sp], #-4\n");
        printf("sub r0, r0, r1\n");
        printf("str r0, [sp, #4]!\n");
    }

    | EXPRESSAO SOMA EXPRESSAO  {
        $$ = $1 + $3;
        //printf("Encontrei soma: %d + %d = %d\n", $1, $3, $$);
        printf("ldr r0, [sp], #-4\n");
        printf("ldr r1, [sp], #-4\n");
        printf("add r0, r0, r1\n");
        printf("str r0, [sp, #4]!\n");
    }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

void mprintf(char *s) {
    
}

void realocar() {
    char *string_antiga = saida;

    tamanho *= 2;
    saida = calloc(tamanho, sizeof(char));
    if (saida == NULL) {
        fprintf(stderr, "Falha ao alocar memória para saída!\n");
        exit(-1);
    }

    int i = 0;
    while (string_antiga[i] != '\0'){
    	saida[i] = string_antiga[i];
    	i++;
    }

    free(string_antiga);
}

int main() {
    tamanho = 1024;
    saida = calloc(tamanho, sizeof(char));
    if (saida == NULL) {
        fprintf(stderr, "Falha ao alocar memória para saída!\n");
        return -1;
    }

    yyparse();

    printf("; função para executar multiplicação de r0 com r1\n");
    printf("multiplicar\n");
    printf("\t;;; caso 1: algum dos números é zero\n");
    printf("\t;;; caso 2: não são zero, separamos em casos menores:\n");
    printf("\t;;;   caso i:     ambos positivos\n");
    printf("\t;;;   caso ii:    um deles é negativo\n");
    printf("\t;;;   caso iii:   ambos negativos\n");
    printf("\t; para isso, guardamos em r2 -1 se r0 for negativo, 1 se for positivo\n");
    printf("\t; somamos a r2 o mesmo valor para r1, de modo a obtermos:\n");
    printf("\t; r2 = 2  => caso i\n");
    printf("\t; r2 = 0  => caso ii\n");
    printf("\t; r2 = -2 => caso iii\n");
    printf("\t;\n");
    printf("\t; nessa análise ainda guardaremos os valores absolutos de r0 e r1 em r3, r4\n");
    printf("\t; verificamos se r0 é zero\n");
    printf("\tcmp r0, #0\n");
    printf("\t; retornamos se r0 for igual a zero\n");
    printf("\tmoveq pc, lr\n");
    printf("\t; analisamos caso\n");
    printf("\tmovlt r2, #-1\n");
    printf("\tmovgt r2, #1\n");
    printf("\t; guardamos valor absoluto em r3 (r3 = #0 - r0)\n");
    printf("\trsblt r3, r0, #0\n");
    printf("\tmovgt r3, r0\n");
    printf("\t; verificamos se r1 é zero\n");
    printf("\tcmp r1, #0\n");
    printf("\t; se for igual, colocamos 0 em r0 e retornamos\n");
    printf("\tmoveq r0, #0\n");
    printf("\tmoveq pc, lr\n");
    printf("\t; analisamos caso\n");
    printf("\taddlt r2, r2, #-1\n");
    printf("\taddgt r2, r2, #1\n");
    printf("\t; analogamente, colocamos em r4 o valor abs. de r1\n");
    printf("\trsblt r4, r1, #0\n");
    printf("\tmovgt r4, r1\n");
    printf("\t; vemos quem é o menor e o maior\n");
    printf("\tcmp r3, r4\n");
    printf("\t; deixamos o menor em r4, maior em r3\n");
    printf("\tmovlt r5, r3\n");
    printf("\tmovlt r3, r4\n");
    printf("\tmovlt r4, r5\n");
    printf("\t; colocamos o maior em r5 para ser somado\n");
    printf("\tmov r5, r3\n");
    printf("\t; se r3 > r4, estamos prontos\n");
    printf("\t; agora fazemos a multiplicação de fato\n");
    printf("\t_laco_multiplicacao\n");
    printf("\t\tcmp r4, #1\n");
    printf("\t\tble _fim_multiplicacao\n");
    printf("\t\tadd r3, r3, r5\n");
    printf("\t\tsub r4, r4, #1\n");
    printf("\t\tb _laco_multiplicacao\n");
    printf("\t_fim_multiplicacao\n");
    printf("\t; agora que acabamos de multiplicar, retornamos para r0 com sinal corrigido\n");
    printf("\t; vemos o sinal que devemos ter através de r2, apenas se r2 == 0 precisamos\n");
    printf("\t; colocar o sinal negativo\n");
    printf("\tcmp r2, #0\n");
    printf("\t; colocamos em r0 -r3\n");
    printf("\trsbeq r0, r3, #0\n");
    printf("\t; se não é igual a zero, só movemos\n");
    printf("\tmovne r0, r3\n");
    printf("\t; retornamos\n");
    printf("\tmov pc, lr\n");

    return 0;
}
