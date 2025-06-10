#include "runtime.h"
#include <stdio.h>
#include <string.h>

/* ───── Tabelas globais ─────────────────────────────────────────────── */
Produto prod[MAXP];          /* lista de produtos                 */
int     nprod      = 0;

Pedido  fila[MAXF];          /* fila de pedidos                   */
int     nped       = 0;      /* total de pedidos enfileirados     */
int     next_ped   = 0;      /* ponteiro do próximo a atender     */

Instr   code[MAXC];          /* byte-code gerado pelo parser      */
int     pc         = 0;      /* tamanho do byte-code              */

/* variáveis automáticas usadas em avisos (intermediário) */
int     NUMERO_PEDIDO                 = 0;
char    ULTIMO_PRODUTO[64]            = "";
int     FALTAVAM                      = 0;
int     ULTIMO_PEDIDO_EXIGE_COMPRA    = 0;

/* métricas financeiras */
double  receita = 0.0;
double  despesa = 0.0;

/* ───── Helpers  ────────────────────────────────────────────────────── */
int idx_prod(const char *nome) {
    for (int i = 0; i < nprod; i++)
        if (strcmp(prod[i].nome, nome) == 0) return i;
    return -1;          /* não deveria ocorrer em inputs válidos */
}

static void processar_pedido(Pedido *p) {
    Produto *pr = &prod[p->idx_produto];

    NUMERO_PEDIDO++;
    strcpy(ULTIMO_PRODUTO, pr->nome);
    FALTAVAM = 0;
    ULTIMO_PEDIDO_EXIGE_COMPRA = 0;

    if (pr->estoque < p->qtd) {
        FALTAVAM = p->qtd - pr->estoque;
        pr->estoque += 50;                       /* compra fixa de 50          */
        despesa += 50 * pr->custo;
        ULTIMO_PEDIDO_EXIGE_COMPRA = 1;
        printf("[AVISO] Pedido %d: compradas 50 unidades de %s (faltavam %d)\n",
               NUMERO_PEDIDO, pr->nome, FALTAVAM);
    }

    pr->estoque -= p->qtd;
    receita += p->qtd * pr->valor;
    despesa += p->qtd * pr->custo;
}

/* ───── Laço principal da mini-VM ───────────────────────────────────── */
void vm_execute(void) {
    for (int ip = 0; ; ip++) {
        Instr ins = code[ip];

        switch (ins.op) {

            case OP_PEDIDO:          /* enfileira pedido */
                /* não usado, pedidos já estão na fila durante o parsing */
                break;

            case OP_PROCESSAR:       /* zera ponteiro para a fila */
                next_ped = 0;
                break;

            case OP_ATENDER:         /* atende 1 pedido e repete se ainda há fila */
                if (next_ped < nped) {
                    processar_pedido(&fila[next_ped++]);
                    if (next_ped < nped) ip--;   /* repete este opcode      */
                }
                break;

            case OP_SHOW_EST:
                printf("Estoque Atual:\n");
                for (int i = 0; i < nprod; i++)
                    printf("- %s : %d unidades\n",
                           prod[i].nome, prod[i].estoque);
                break;

            case OP_SHOW_LUC:
                printf("\nLucro líquido: R$ %.2f\n", receita - despesa);
                break;

            case OP_END:             /* finaliza execução */
                return;

            default:
                fprintf(stderr, "Opcode desconhecido %d\n", ins.op);
                return;
        }
    }
}
