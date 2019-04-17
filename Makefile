MAIN = main
CC = gcc
FLAGS = -lfl -Wall

all: lex.yy.c y.tab.c
	$(CC) -o $(MAIN) $(FLAGS) lex.yy.c y.tab.c

lex.yy.c: calculadora.l
	flex calculadora.l

y.tab.c: calculadora.y
	bison -dy calculadora.y

clean:
	rm $(MAIN) lex.yy.c y.tab.h y.tab.c
