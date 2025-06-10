LEX      = flex
YACC     = bison -d -v
CC       = gcc
CFLAGS   = -Wall -Isrc
LDFLAGS  = -lfl

all: miniloja

scanner.c: src/scanner.l
	$(LEX) -o scanner.c src/scanner.l

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -o parser.tab.c src/parser.y

runtime.o: src/runtime.c src/runtime.h
	$(CC) $(CFLAGS) -c src/runtime.c

miniloja: scanner.c parser.tab.c runtime.o
	$(CC) $(CFLAGS) scanner.c parser.tab.c runtime.o -o miniloja $(LDFLAGS)

clean:
	rm -f scanner.c parser.tab.c parser.tab.h runtime.o miniloja parser.output
