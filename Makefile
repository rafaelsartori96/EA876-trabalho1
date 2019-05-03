MAIN = main
CC = gcc
FLAGS = -lfl -Wall

# Macros para teste
BASH = sh
TEST_SCRIPT = test.sh
VERBOSE ?= 1


all: ./src/lex.yy.c ./src/y.tab.c
	$(CC) -o ./src/$(MAIN) $(FLAGS) ./src/lex.yy.c ./src/y.tab.c

./src/lex.yy.c: ./src/calculadora.l
	flex -o ./src/lex.yy.c ./src/calculadora.l

./src/y.tab.c: ./src/calculadora.y
	bison -dy ./src/calculadora.y -o ./src/y.tab.c

test: all
	$(BASH) $(TEST_SCRIPT) ./src/main $(VERBOSE)

clean:
	rm ./src/$(MAIN) src/lex.yy.c src/y.tab.h src/y.tab.c
