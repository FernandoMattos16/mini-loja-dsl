#include "runtime.h"
Produto prod[MAXP]; int nprod = 0;
Pedido  fila[MAXF]; int nped  = 0, next_ped = 0;
Instr   code[MAXC]; int pc    = 0;

int NUMERO_PEDIDO = 0;
char ULTIMO_PRODUTO[64] = "";
int FALTAVAM = 0;
int ULTIMO_PEDIDO_EXIGE_COMPRA = 0;

double receita = 0, despesa = 0;

/* busca produto por nome, cria se não existir */
int idx_prod(const char *nome){
    for(int i=0;i<nprod;i++) if(strcmp(prod[i].nome,nome)==0) return i;
    return -1;
}

static void processar_pedido(Pedido *p){
    Produto *pr = &prod[p->idx_produto];
    NUMERO_PEDIDO++;
    strcpy(ULTIMO_PRODUTO, pr->nome);
    FALTAVAM = 0;
    ULTIMO_PEDIDO_EXIGE_COMPRA = 0;

    if(pr->estoque < p->qtd){
        FALTAVAM = p->qtd - pr->estoque;
        pr->estoque += 50;         /* compra fixa de 50 */
        despesa += 50 * pr->custo;
        ULTIMO_PEDIDO_EXIGE_COMPRA = 1;
        printf("[AVISO] Pedido %d: compradas 50 unidades de %s (faltavam %d)\n",
               NUMERO_PEDIDO, pr->nome, FALTAVAM);
    }
    pr->estoque -= p->qtd;
    receita += p->qtd * pr->valor;
}

void vm_execute(void){
    for(int ip=0; ; ip++){
        Instr ins = code[ip];
        switch(ins.op){
            case OP_PROD:
                strncpy(prod[ins.a].nome, ULTIMO_PRODUTO, 63); /* nome já copiado no parser */
                prod[ins.a].estoque = (int)ins.b;
                break;
            case OP_PEDIDO:
                fila[nped++] = (Pedido){ ins.a, (int)ins.b };
                break;
            case OP_PROCESSAR:
                next_ped = 0;
                break;
            case OP_ATENDER:
                if(next_ped < nped) processar_pedido(&fila[next_ped++]);
                break;
            case OP_SHOW_EST:
                printf("Estoque Atual:\n");
                for(int i=0;i<nprod;i++)
                    printf("- %s : %d unidades\n", prod[i].nome, prod[i].estoque);
                break;
            case OP_SHOW_LUC:
                printf("\nLucro líquido: R$ %.2f\n", receita - despesa);
                break;
            case OP_END:
                return;
            default: fprintf(stderr,"opcode desconhecido %d\n", ins.op); return;
        }
    }
}
