MAIN = main
CC = gcc
FLAGS = -lfl -Wall

# Pastas
SOURCES = ./src
OUTPUT = ./out

# Macros para teste
BASH = sh
TEST_SCRIPT = test.sh
VERBOSE ?= 1


all: $(OUTPUT)/lex.yy.c $(OUTPUT)/y.tab.c
	$(CC) -o $(OUTPUT)/$(MAIN) $(FLAGS) $(OUTPUT)/lex.yy.c $(OUTPUT)/y.tab.c

$(OUTPUT)/lex.yy.c: $(SOURCES)/calculadora.l
	flex -o $(OUTPUT)/lex.yy.c $(SOURCES)/calculadora.l

$(OUTPUT)/y.tab.c: $(SOURCES)/calculadora.y
	bison -dy $(SOURCES)/calculadora.y -o $(OUTPUT)/y.tab.c

test: all
	$(BASH) $(TEST_SCRIPT) $(OUTPUT)/main $(VERBOSE)

clean:
	rm $(OUTPUT)/*
