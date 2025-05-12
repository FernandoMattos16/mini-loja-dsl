%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
extern int yylex(void);

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}
%}

/* Valores que os tokens carregam */
%union {
    char  *str;
    double num;
}

/* Tokens com valor */
%token <str> NOME TEXTO
%token <num> NUMERO

/* Palavras‐chave e símbolos */
%token PRODUTO PEDIDO FIM_PEDIDOS PROCESSAR_PEDIDOS ENQUANTO
%token ATENDER_PEDIDO COMPRAR SE ENTAO FIM AVISO MOSTRAR
%token ESTOQUE LUCRO CUSTO VALOR QUANTIDADE FILA

%start programa

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
    | ATENDER_PEDIDO
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
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Erro ao abrir arquivo");
            return 1;
        }
    } else {
        yyin = stdin;
    }

    int result = yyparse();
    if (result == 0) {
        printf("==> Análise sintática concluída com sucesso!\n");
    } else {
        printf("==> Erros de sintaxe foram encontrados.\n");
    }
    return result;
}
