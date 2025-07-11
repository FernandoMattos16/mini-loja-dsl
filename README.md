# Mini-Loja DSL

**Mini-Loja** é uma linguagem de domínio específico (DSL) em **português** criada para a APS de **Lógica da Computação 2025/1**.  
Com ela você descreve, num arquivo de texto, toda a rotina de uma loja:

* cadastro de produtos (`PRODUTO …`),  
* formação de fila de pedidos (`PEDIDO …` → `FIM_PEDIDOS`),  
* processamento automático (`PROCESSAR_PEDIDOS … ENQUANTO FILA > 0 … FIM`),  
* compras emergenciais (`COMPRAR ULTIMO_PRODUTO N`) e avisos,  
* relatórios finais de **estoque** e **lucro**.

A sintaxe usa apenas palavras-chave em português e demonstra **variáveis**, **condicionais** (`SE … ENTAO … FIM`) e **loop real** (`ENQUANTO … FIM`).  
O front-end foi gerado com **Flex/Bison**; o back-end é uma **VM em C** que interpreta um byte-code gerado pelo parser.

---

## ⚙️ Compilação

Requisitos: `flex`, `bison`, `gcc` (instale com `sudo apt install build-essential flex bison`).

```bash
git clone https://github.com/seu-usuario/mini-loja-dsl.git
cd mini-loja-dsl
make clean
make          # cria o executável ./miniloja
```

## Artefatos gerados após `make`

Depois de executar **`make`** na raiz do projeto, os seguintes arquivos aparecem na pasta principal:

| Arquivo | Como é criado | Para que serve |
|---------|---------------|----------------|
| **`miniloja`** | `gcc scanner.c parser.tab.c runtime.o -o miniloja` | Executável final que interpreta programas Mini-Loja. |
| **`scanner.c`** | gerado pelo **Flex** a partir de `src/scanner.l` | Implementa `yylex()` – responsável por transformar o texto de entrada em tokens. |
| **`parser.tab.c`** | gerado pelo **Bison** a partir de `src/parser.y` | Contém a máquina de estados LR(1) do parser (`yyparse()`) e chamadas às ações semânticas que produzem o byte-code. |
| **`parser.tab.h`** | gerado junto com `parser.tab.c` | Define os números de token (`#define PRODUTO 261`, etc.) usados tanto pelo scanner quanto pelo parser. |
| **`parser.output`** | gerado pelo Bison com a flag `-v` | Relatório de depuração: lista estados da gramática, conflitos, símbolos não usados. Útil apenas para análise interna. |
| **`runtime.o`** | `gcc -c src/runtime.c` | Objeto com a VM (`vm_execute`) e as estruturas de dados (produtos, fila). Ligado no passo final. |

> **Limpeza**  
> Execute `make clean` para remover todos esses artefatos e deixar o diretório só com os fontes.


## Como Utilizar

Depois de compilar com `make`, você terá o executável `miniloja`. Assim, basta rodar:

```bash
./miniloja <arquivo-de-entrada.txt>
```

### ✅ Exemplo válido

```bash
$ ./miniloja exemplos/input_basico.txt

Estoque Atual:
- Caneta : 28 unidades
- Caderno: 15 unidades

Lucro líquido: R$ 38,00
```

### ❌ Exemplo inválido

Caso rode algum arquivo de input incorreto para a linguagem em questão:

```bash
$ ./miniloja examples/input_errado.txt
Erro de sintaxe: syntax error
==> Erros de sintaxe foram encontrados.
```
Exit code 0 indica sucesso; qualquer outro valor sinaliza erro de sintaxe.

## Arquitetura Básica

```scss
┌───────────────┐   lexer.l   ┌───────────────┐
│   Fonte DSL   │ ─────────► │    Tokens      │
└───────────────┘             └───────────────┘
        │                         │
        ▼    parser.y (Bison)     ▼
┌─────────────────────────────────────┐
│      Byte-code (array Instr)        │
└─────────────────────────────────────┘
        │    vm_execute() (C)         │
        ▼                             ▼
┌───────────────┐               ┌───────────────┐
│      VM       │  interpreta   │   Relatório   │
└───────────────┘               └───────────────┘

```

* OpCodes: OP_ATENDER, OP_PROCESSAR, OP_SHOW_EST, OP_SHOW_LUC…

* Reposição automática: a quantidade é definida em tempo de execução pelo comando COMPRAR.

## EBNF 

```ebnf
PROGRAMA       = declaracoes , pedidos , processamento , relatorio ;

declaracoes    = { PRODUTO_DEF } ;
PRODUTO_DEF    = "PRODUTO" , Nome , "VALOR" , Numero ,
                 "CUSTO" , Numero , "ESTOQUE" , Numero ;

pedidos        = { PEDIDO_DEF } , "FIM_PEDIDOS" ;
PEDIDO_DEF     = "PEDIDO" , Numero , "PRODUTO" , Nome ,
                 "QUANTIDADE" , Numero ;

processamento  = "PROCESSAR_PEDIDOS" , LOOP_FILA ;
LOOP_FILA      = "ENQUANTO" , "FILA" , ">" , Numero ,
                   { COMANDO_LOOP } ,
                 "FIM" ;

COMANDO_LOOP   = "ATENDER_PEDIDO"
               | COMPRA_CONDICIONAL ;

COMPRA_CONDICIONAL
               = "SE" , "ULTIMO_PEDIDO_EXIGE_COMPRA" , "ENTAO"
                 , "COMPRAR" , "ULTIMO_PRODUTO" , Numero
                 , "AVISO" , TextoConcat
                 , "FIM" ;

relatorio      = "MOSTRAR" , "ESTOQUE"
                 , "MOSTRAR" , "LUCRO" ;

Nome           = identificador ;
Numero         = inteiro | decimal ;
TextoConcat    = TEXTO | Nome | TextoConcat "+" (TEXTO | Nome) ;
```
## Casos de teste disponíveis

A pasta **`exemplos/`** contém dois programas-exemplo prontos para rodar:

| Arquivo | O que demonstra |
|---------|-----------------|
| `loja_basico.txt` | 2 produtos, 2 pedidos, loop simples sem compra extra | 
| `input_intermediario.txt` | 10 produtos, 10 pedidos, reabastecimento automático com avisos |

Para testar:

```bash
./miniloja exemplos/input_basico.txt          # caso mínimo
./miniloja exemplos/input_intermediario.txt  # caso completo
```