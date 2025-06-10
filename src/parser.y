%{
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
extern int yylex(void);
extern int restock_default;

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
%token PLUS

%start programa   

%%

programa
    : declaracoes pedidos processamento relatorio
    ;

declaracoes
    : /* zero ou mais PRODUTO ... */
    | declaracoes declaracao_produto
    ;

declaracao_produto
    : PRODUTO NOME VALOR NUMERO CUSTO NUMERO ESTOQUE NUMERO
      {
        int idx = nprod++;
        strcpy(prod[idx].nome, $2);
        prod[idx].valor   = $4;
        prod[idx].custo   = $6;
        prod[idx].estoque = (int)$8;
      }
    ;

pedidos
    : lista_pedido FIM_PEDIDOS
    ;

lista_pedido
    : /* vazio */
    | lista_pedido linha_pedido
    ;

linha_pedido
    : PEDIDO NUMERO PRODUTO NOME QUANTIDADE NUMERO
      {
        int idx = idx_prod($4);
        fila[nped++] = (Pedido){ idx, (int)$6 }; 
      }
    ;

processamento
    : PROCESSAR_PEDIDOS loop_fila
    ;

loop_fila
    : ENQUANTO FILA '>' NUMERO comandos_loop FIM
    ;

texto_concat
    : TEXTO
    | NOME
    | texto_concat PLUS TEXTO
    | texto_concat PLUS NOME
    ;

compra_condicional
    : SE NOME ENTAO COMPRAR NOME NUMERO
      AVISO texto_concat FIM
      {
          restock_default = (int)$6;
      }
    ;

comandos_loop
    : /* vazio */
    | comandos_loop ATENDER_PEDIDO { code[pc++] = (Instr){OP_ATENDER,0,0}; }
    | comandos_loop compra_condicional
    ;

relatorio
    : MOSTRAR ESTOQUE { code[pc++] = (Instr){OP_SHOW_EST,0,0}; }
      MOSTRAR LUCRO   { code[pc++] = (Instr){OP_SHOW_LUC,0,0}; }
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