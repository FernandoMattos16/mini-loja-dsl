CC      = gcc
LEX     = flex
YACC    = bison -d -v

all: miniloja

lexer.c: src/lexer.l
	$(LEX) -o lexer.c src/lexer.l

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -d -v -o parser.tab.c src/parser.y

miniloja: lexer.c parser.tab.c
	$(CC) lexer.c parser.tab.c -lfl -o miniloja

clean:
	rm -f lexer.c parser.tab.c parser.tab.h miniloja
