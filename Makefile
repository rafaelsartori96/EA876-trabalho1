MAIN = main
CC = gcc
FLAGS = -lfl -Wall

# Macros para teste
BASH = sh
TEST_SCRIPT = test.sh
VERBOSE ?= 1


all: lex.yy.c y.tab.c
	$(CC) -o $(MAIN) $(FLAGS) lex.yy.c y.tab.c

lex.yy.c: calculadora.l
	flex calculadora.l

y.tab.c: calculadora.y
	bison -dy calculadora.y

test: all
	$(BASH) $(TEST_SCRIPT) ./main $(VERBOSE)

clean:
	rm $(MAIN) lex.yy.c y.tab.h y.tab.c
