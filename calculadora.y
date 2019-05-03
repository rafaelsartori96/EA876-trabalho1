%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *c);
int yylex(void);
void realocar();

char *saida = NULL;
int tamanho = 0;
int usado = 0;

int error = 0;

#define my_printf(...) \
    if (usado >= ((tamanho * 3) / 4)) { \
        realocar(); \
    } \
    usado += snprintf(saida + usado, tamanho - usado, __VA_ARGS__);

%}

%token INT SOMA SUBTRACAO MULTIPLICACAO ABRE_PAR FECHA_PAR EOL
%left SOMA SUBTRACAO
%left MULTIPLICACAO

%%

PROGRAMA:
    EXPRESSAO EOL {
        my_printf("end\n");
        my_printf("; Resultado: %d\n", $1);
	    return 0;
    }
    ;


EXPRESSAO:
    INT {
        $$ = $1;
        //printf("encontrei inteiro: %d\n", $$);
        my_printf("ldr r0, =%d\n", $$);
        my_printf("str r0, [sp, #4]!\n");
    }

    | SUBTRACAO INT {
        $$ = -$2;
        //printf("encontrei inteiro: %d\n", $$);
        my_printf("ldr r0, =%d\n", $$);
        my_printf("str r0, [sp, #4]!\n");
    }

    | ABRE_PAR EXPRESSAO FECHA_PAR {
        $$ = $2;
        //printf("encontrei expressão entre parentesis: %d\n", $$);
    }

    | EXPRESSAO MULTIPLICACAO EXPRESSAO  {
        $$ = $1 * $3;
        //printf("Encontrei multiplicação: %d * %d = %d\n", $1, $3, $$);
        my_printf("ldr r0, [sp], #-4\n");
        my_printf("ldr r1, [sp], #-4\n");
        my_printf("bl multiplicar\n");
        my_printf("str r0, [sp, #4]!\n");
    }

    | EXPRESSAO SUBTRACAO EXPRESSAO  {
        $$ = $1 - $3;
        //printf("Encontrei subtração: %d - %d = %d\n", $1, $3, $$);
        my_printf("ldr r0, [sp], #-4\n");
        my_printf("ldr r1, [sp], #-4\n");
        my_printf("sub r0, r1, r0\n");
        my_printf("str r0, [sp, #4]!\n");
    }

    | EXPRESSAO SOMA EXPRESSAO  {
        $$ = $1 + $3;
        //printf("Encontrei soma: %d + %d = %d\n", $1, $3, $$);
        my_printf("ldr r0, [sp], #-4\n");
        my_printf("ldr r1, [sp], #-4\n");
        my_printf("add r0, r0, r1\n");
        my_printf("str r0, [sp, #4]!\n");
    }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    error = 1;
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

    if (yyparse() != 0 || error != 0) {
        fprintf(stderr, "erro de sintaxe!\n");
        return -1;
    }

    my_printf("; função para executar multiplicação de r0 com r1\n");
    my_printf("multiplicar\n");
    my_printf("\t;;; caso 1: algum dos números é zero\n");
    my_printf("\t;;; caso 2: não são zero, separamos em casos menores:\n");
    my_printf("\t;;;   caso i:     ambos positivos\n");
    my_printf("\t;;;   caso ii:    um deles é negativo\n");
    my_printf("\t;;;   caso iii:   ambos negativos\n");
    my_printf("\t; para isso, guardamos em r2 -1 se r0 for negativo, 1 se for positivo\n");
    my_printf("\t; somamos a r2 o mesmo valor para r1, de modo a obtermos:\n");
    my_printf("\t; r2 = 2  => caso i\n");
    my_printf("\t; r2 = 0  => caso ii\n");
    my_printf("\t; r2 = -2 => caso iii\n");
    my_printf("\t;\n");
    my_printf("\t; nessa análise ainda guardaremos os valores absolutos de r0 e r1 em r3, r4\n");
    my_printf("\t; verificamos se r0 é zero\n");
    my_printf("\tcmp r0, #0\n");
    my_printf("\t; retornamos se r0 for igual a zero\n");
    my_printf("\tmoveq pc, lr\n");
    my_printf("\t; analisamos caso\n");
    my_printf("\tmovlt r2, #-1\n");
    my_printf("\tmovgt r2, #1\n");
    my_printf("\t; guardamos valor absoluto em r3 (r3 = #0 - r0)\n");
    my_printf("\trsblt r3, r0, #0\n");
    my_printf("\tmovgt r3, r0\n");
    my_printf("\t; verificamos se r1 é zero\n");
    my_printf("\tcmp r1, #0\n");
    my_printf("\t; se for igual, colocamos 0 em r0 e retornamos\n");
    my_printf("\tmoveq r0, #0\n");
    my_printf("\tmoveq pc, lr\n");
    my_printf("\t; analisamos caso\n");
    my_printf("\taddlt r2, r2, #-1\n");
    my_printf("\taddgt r2, r2, #1\n");
    my_printf("\t; analogamente, colocamos em r4 o valor abs. de r1\n");
    my_printf("\trsblt r4, r1, #0\n");
    my_printf("\tmovgt r4, r1\n");
    my_printf("\t; vemos quem é o menor e o maior\n");
    my_printf("\tcmp r3, r4\n");
    my_printf("\t; deixamos o menor em r4, maior em r3\n");
    my_printf("\tmovlt r5, r3\n");
    my_printf("\tmovlt r3, r4\n");
    my_printf("\tmovlt r4, r5\n");
    my_printf("\t; colocamos o maior em r5 para ser somado\n");
    my_printf("\tmov r5, r3\n");
    my_printf("\t; se r3 > r4, estamos prontos\n");
    my_printf("\t; agora fazemos a multiplicação de fato\n");
    my_printf("\t_laco_multiplicacao\n");
    my_printf("\t\tcmp r4, #1\n");
    my_printf("\t\tble _fim_multiplicacao\n");
    my_printf("\t\tadd r3, r3, r5\n");
    my_printf("\t\tsub r4, r4, #1\n");
    my_printf("\t\tb _laco_multiplicacao\n");
    my_printf("\t_fim_multiplicacao\n");
    my_printf("\t; agora que acabamos de multiplicar, retornamos para r0 com sinal corrigido\n");
    my_printf("\t; vemos o sinal que devemos ter através de r2, apenas se r2 == 0 precisamos\n");
    my_printf("\t; colocar o sinal negativo\n");
    my_printf("\tcmp r2, #0\n");
    my_printf("\t; colocamos em r0 -r3\n");
    my_printf("\trsbeq r0, r3, #0\n");
    my_printf("\t; se não é igual a zero, só movemos\n");
    my_printf("\tmovne r0, r3\n");
    my_printf("\t; retornamos\n");
    my_printf("\tmov pc, lr\n");


    printf("%s\n", saida);
    free(saida);

    return 0;
}
