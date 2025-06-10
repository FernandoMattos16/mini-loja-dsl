#ifndef RUNTIME_H
#define RUNTIME_H
#include <stdio.h>
#include <string.h>

#define MAXP 128   /* produtos  */
#define MAXF 2048  /* fila de pedidos */
#define MAXC 4096  /* bytecode  */

typedef struct {           /* produto                       */
    char nome[64];
    double valor, custo;
    int estoque;
    int restock;
} Produto;

typedef struct {           /* pedido                        */
    int idx_produto;
    int qtd;
} Pedido;

/* bytecode genérico */
typedef struct { int op; int a; double b; } Instr;

/* opcodes */
enum {
    OP_PROD = 1,        /* a=index, b=estoque inicial            */
    OP_PEDIDO,          /* a=index produto, b=qtd                */
    OP_PROCESSAR,       /* seta ponteiro de fila (next = 0)      */
    OP_ATENDER,         /* processa 1 pedido                     */
    OP_AVISO,           /* imprime aviso                         */
    OP_SHOW_EST,        /* mostrar estoque                       */
    OP_SHOW_LUC,        /* mostrar lucro                         */
    OP_END              /* fim do programa                       */
};

/* tabelas globais (simples) */
extern Produto prod[MAXP];
extern int nprod;

extern Pedido fila[MAXF];
extern int nped, next_ped;

extern Instr code[MAXC];
extern int pc;

/* variáveis automáticas para AVISO */
extern int NUMERO_PEDIDO;
extern char ULTIMO_PRODUTO[64];
extern int FALTAVAM;
extern int ULTIMO_PEDIDO_EXIGE_COMPRA;

/* receita e despesa */
extern double receita, despesa;

/* helpers */
int idx_prod(const char *nome);
void vm_execute(void);
#endif
