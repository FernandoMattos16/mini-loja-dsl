# Mini-Loja DSL

Mini-Loja é uma linguagem específica de domínio (DSL) em **português** criada para a APS de Lógica da Computação 2025/1. Seu objetivo é modelar rotinas de varejo — cadastro de produtos, fila de pedidos, vendas, reposições automáticas e relatórios de estoque/lucro — usando uma sintaxe curta e intuitiva. A linguagem demonstra variáveis, condição (`SE … ENTAO …`), e loop real (`ENQUANTO FILA > 0 … FIM`) compilados com Flex/Bison.

## Como compilar

Você precisa de **flex**, **bison** e **gcc** instalados. No Ubuntu/WSL:

```bash
sudo apt update
sudo apt install build-essential flex bison
```

Em seguida, na raiz do projeto:

```bash
make clean
make
```

## Como Utilizar

Depois de compilar com `make`, você terá o executável `miniloja`. Abaixo dois exemplos de uso:

### Exemplo válido

```bash
$ ./miniloja examples/loja_basico.txt
==> Análise sintática concluída com sucesso!
```

### Exemplo inválido

Caso rode algum arquivo de input incorreto para a linguagem em questão:

```bash
$ ./miniloja examples/input_errado.txt
Erro de sintaxe: syntax error
==> Erros de sintaxe foram encontrados.
```

## EBNF (v 0.1)

```ebnf
PROGRAMA       = { COMANDO } ;

COMANDO        = PRODUTO_DEF
               | PEDIDO_DEF
               | "FIM_PEDIDOS"
               | "PROCESSAR_PEDIDOS"
               | LOOP_FILA
               | RELATORIO ;

PRODUTO_DEF    = "PRODUTO", Nome,
                 "VALOR", Numero,
                 "CUSTO", Numero,
                 "ESTOQUE", Numero ;

PEDIDO_DEF     = "PEDIDO", Numero,
                 "PRODUTO", Nome,
                 "QUANTIDADE", Numero ;

LOOP_FILA      = "ENQUANTO", "FILA", ">", Numero ,
                   { COMANDO_LOOP } ,
                 "FIM" ;

COMANDO_LOOP   = "ATENDER_PEDIDO"
               | COMPRA_CONDICIONAL
               | AVISO ;

COMPRA_CONDICIONAL
               = "SE", "ULTIMO_PEDIDO_EXIGE_COMPRA", "ENTAO",
                     "COMPRAR", "ULTIMO_PRODUTO", Numero ,
                     [ AVISO ] ,
                 "FIM" ;

AVISO          = "AVISO", Texto ;

RELATORIO      = "MOSTRAR", ( "ESTOQUE" | "LUCRO" ) ;

Nome           = ? identificador ? ;
Numero         = ? inteiro ou decimal ? ;
Texto          = ? string entre aspas ? ;
