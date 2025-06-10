%{
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
extern int yylex(void);

int idx_prod(const char *nome);  /* protótipo */

void yyerror(const char *s){ fprintf(stderr,"Erro de sintaxe: %s\n", s); }
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
      {
        int idx = nprod++;
        strcpy(prod[idx].nome, $2);
        prod[idx].valor  = $4;
        prod[idx].custo  = $6;
        code[pc++] = (Instr){ OP_PROD, idx, $8 };
      }
    | PEDIDO NUMERO PRODUTO NOME QUANTIDADE NUMERO
      {
        int idx = idx_prod($4);
        code[pc++] = (Instr){ OP_PEDIDO, idx, $6 };
      }
    | PROCESSAR_PEDIDOS   { code[pc++] = (Instr){ OP_PROCESSAR,0,0}; }
    | ATENDER_PEDIDO      { code[pc++] = (Instr){ OP_ATENDER,0,0}; }
    | relatorio           /* ← nome do não-terminal em minúsculo */
    | loop_fila
    ;

loop_fila
    : ENQUANTO FILA '>' NUMERO comandos FIM
    ;

relatorio
    : MOSTRAR ESTOQUE { code[pc++] = (Instr){ OP_SHOW_EST,0,0}; }
    | MOSTRAR LUCRO   { code[pc++] = (Instr){ OP_SHOW_LUC,0,0}; }
    ;

%%

int main(int argc, char **argv){
    if(argc > 1) yyin = fopen(argv[1], "r");
    else          yyin = stdin;
    if(!yyin){ perror("fopen"); return 1; }

    pc = 0;                      /* zera bytecode */
    if(yyparse() == 0){
        code[pc++] = (Instr){ OP_END, 0, 0 };
        vm_execute();            /* interpreta na mini-VM */
    }
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
