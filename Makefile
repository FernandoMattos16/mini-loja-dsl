LEX       = flex
YACC      = bison -d -v
CC        = gcc
CFLAGS    = -Wall
LDFLAGS   = -lfl

all: miniloja

scanner.c: src/scanner.l
	$(LEX) -o scanner.c src/scanner.l

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -o parser.tab.c src/parser.y

miniloja: scanner.c parser.tab.c
	$(CC) $(CFLAGS) scanner.c parser.tab.c -o miniloja $(LDFLAGS)

clean:
	rm -f scanner.c parser.tab.c parser.tab.h miniloja parser.output
