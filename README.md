# Trabalho 1 - EA876

Por Letícia Tateishi (201454) e Rafael Sartori (186154), disponível em [repositório no GitHub](https://github.com/rafaelsartori96/EA876-trabalho1).

Fizemos um compilador de linguagem matemática simples (operações soma, subtração e multiplicação com parênteses) para código de montagem ARM utilizando `bison` e `flex`. As instruções ARM utilizadas foram as disponíveis no simulador que utilizamos para o trabalho, o VisUAL.

## Pré-requisitos

É necessário possuir `yacc`/`bison` e `lex`/`flex`, assim como os pacotes para compilar C e utilizar o `Makefile`. Para simular, utilizamos o [VisUAL](https://salmanarif.bitbucket.io/visual/index.html).

## Como utilizar

O programa aguarda a expressão matemática na entrada padrão e, quando a expressão estiver completa, imprimirá na saída padrão o código ARM.

Para isso, compilamos o compilador utilizando:
```
make
```

e executamos:
```
./main
```
ou através do `Makefile` com alguns testes preparados:
```
make test
```

Para limpar o ambiente, utilizamos:
```
make clean
```
### Exemplo

Após compilado e executado o programa, entramos com uma expressão matemática, por exemplo:
```
4+(2*(-1))
```
O programa retornará como saída:
```
ldr r0, =4
str r0, [sp, #4]!
ldr r0, =2
str r0, [sp, #4]!
ldr r0, =-1
str r0, [sp, #4]!
ldr r0, [sp], #-4
ldr r1, [sp], #-4
bl multiplicar
str r0, [sp, #4]!
ldr r0, [sp], #-4
ldr r1, [sp], #-4
add r0, r0, r1
str r0, [sp, #4]!
end
```
que retorna o valor 2, quando compilado no VisUAL.
## 