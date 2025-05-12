%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
void yyerror(const char *s);
%}

/* tipos de valor que os tokens carregam */
%union {
    char  *str;
    double num;
}

/* tokens com valor */
%token <str> NOME TEXTO
%token <num> NUMERO

/* tokens literais (palavras-chave) */
%token PRODUTO PEDIDO FIM_PEDIDOS PROCESSAR_PEDIDOS ENQUANTO
%token ATENDER_PEDIDO COMPRAR SE ENTAO FIM AVISO MOSTRAR
%token ESTOQUE LUCRO CUSTO VALOR QUANTIDADE FILA

%%

programa
    : comandos
    ;

comandos
    : /* vazio */
    | comandos comando
    ;

comando
    : PRODUTO NOME VALOR NUMERO CUSTO NUMERO ESTOQUE NUMERO
    | PEDIDO NUMERO PRODUTO NOME QUANTIDADE NUMERO
    | FIM_PEDIDOS
    | PROCESSAR_PEDIDOS
    | loop_fila
    | relatorio
    ;

loop_fila
    : ENQUANTO FILA '>' NUMERO comandos FIM
    ;

relatorio
    : MOSTRAR ESTOQUE
    | MOSTRAR LUCRO
    ;

%%

int main(int argc, char **argv) {
    if (argc > 1) yyin = fopen(argv[1], "r");
    else           yyin = stdin;
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
