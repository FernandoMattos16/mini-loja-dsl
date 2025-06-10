%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap noinput nounput

DIGIT           [0-9]
LETTER          [A-Za-z]
IDENTIFIER      {LETTER}({LETTER}|{DIGIT}|_)*  
NUMBER          {DIGIT}+([.,]{DIGIT}+)?
STRING          \"([^\"\\]|\\.)*\"

%%

[ \t\r\n]+                ;   /* ignora espaços em branco e quebras de linha */
"#".*                      ;   /* ignora comentários iniciados por # */

"PRODUTO"                 return PRODUTO;
"PEDIDO"                  return PEDIDO;
"FIM_PEDIDOS"             return FIM_PEDIDOS;
"PROCESSAR_PEDIDOS"       return PROCESSAR_PEDIDOS;
"ENQUANTO"                return ENQUANTO;
"ATENDER_PEDIDO"          return ATENDER_PEDIDO;
"COMPRAR"                 return COMPRAR;
"SE"                      return SE;
"ENTAO"                   return ENTAO;
"FIM"                     return FIM;
"AVISO"                   return AVISO;
"MOSTRAR"                 return MOSTRAR;
"ESTOQUE"                 return ESTOQUE;
"LUCRO"                   return LUCRO;
"CUSTO"                   return CUSTO;
"VALOR"                   return VALOR;
"QUANTIDADE"              return QUANTIDADE;
"FILA"                    return FILA;

{NUMBER} { 
    /* padroniza vírgula para ponto */
    char *s = strdup(yytext);
    for(char *p=s; *p; ++p) if(*p==',') *p='.';
    yylval.num = atof(s);
    free(s);
    return NUMERO;
}

{STRING} {
    /* remove as aspas */
    yylval.str = strdup(yytext+1);
    yylval.str[strlen(yylval.str)-1] = '\0';
    return TEXTO;
}

{IDENTIFIER} {
    yylval.str = strdup(yytext);
    return NOME;
}

.   { return yytext[0]; }

%%
