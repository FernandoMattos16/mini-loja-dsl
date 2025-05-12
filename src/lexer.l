%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

/* ignora espaços, tabs, quebras de linha e comentários */
[ \t\r\n]+        ;
"#".*             ;

/* palavras‐chave */
"PRODUTO"         return PRODUTO;
"PEDIDO"          return PEDIDO;
"FIM_PEDIDOS"     return FIM_PEDIDOS;
"PROCESSAR_PEDIDOS" return PROCESSAR_PEDIDOS;
"ENQUANTO"        return ENQUANTO;
"ATENDER_PEDIDO"  return ATENDER_PEDIDO;
"COMPRAR"         return COMPRAR;
"SE"              return SE;
"ENTAO"           return ENTAO;
"FIM"             return FIM;
"AVISO"           return AVISO;
"MOSTRAR"         return MOSTRAR;
"ESTOQUE"         return ESTOQUE;
"LUCRO"           return LUCRO;
"CUSTO"           return CUSTO;
"VALOR"           return VALOR;
"QUANTIDADE"      return QUANTIDADE;
"FILA"            return FILA;

/* números inteiros ou decimais (vírgula ou ponto) */
[0-9]+([.,][0-9]+)? {
    yylval.num = atof(yytext);
    return NUMERO;
}

/* string literal entre aspas */
\"[^\"]*\" {
    yylval.str = strdup(yytext);
    return TEXTO;
}

/* identificador (nome de produto, variável, etc) */
[A-Za-z][A-Za-z0-9_]* {
    yylval.str = strdup(yytext);
    return NOME;
}

/* qualquer outro caractere retorna seu próprio código */
.   { return yytext[0]; }

%%

int yywrap(void) { return 1; }
