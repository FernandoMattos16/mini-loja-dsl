<<<<<<< HEAD
LEX      = flex
YACC     = bison -d -v
CC       = gcc
CFLAGS   = -Wall
LDFLAGS  = -lfl
=======
LEX       = flex
YACC      = bison -d -v
CC        = gcc
CFLAGS    = -Wall
LDFLAGS   = -lfl
>>>>>>> ef486c124405b68be7e58420f225289f8780b028

all: miniloja

scanner.c: src/scanner.l
	$(LEX) -o scanner.c src/scanner.l

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -o parser.tab.c src/parser.y

<<<<<<< HEAD
runtime.o: src/runtime.c src/runtime.h
	$(CC) $(CFLAGS) -c src/runtime.c

miniloja: scanner.c parser.tab.c runtime.o
	$(CC) $(CFLAGS) scanner.c parser.tab.c runtime.o -o miniloja $(LDFLAGS)

clean:
	rm -f scanner.c parser.tab.c parser.tab.h runtime.o miniloja
=======
miniloja: scanner.c parser.tab.c
	$(CC) $(CFLAGS) scanner.c parser.tab.c -o miniloja $(LDFLAGS)

clean:
	rm -f scanner.c parser.tab.c parser.tab.h miniloja parser.output
>>>>>>> ef486c124405b68be7e58420f225289f8780b028
