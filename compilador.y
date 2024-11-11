

%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"
#include "pilha.h"
#include "simbolos.h"
#include "inteiro.h"

int num_vars, nivelLex, desloc;
simbolo_t * tds = NULL;
simbolo_t * l_elem = NULL;
inteiro_t * aritmetica = NULL;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES NUMERO
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token T_LABEL T_TYPE T_ARRAY
%token T_PROCEDURE T_FUNCTION
%token T_IF T_ELSE T_WHILE T_DO T_OR T_DIV T_AND T_NOT 
%token T_MULT T_MAIS T_MENOS T_DIFERENTE T_MENOR T_MENOR_IGUAL T_MAIOR T_MAIOR_IGUAL

%%

programa    :{ geraCodigo (NULL, "INPP"); num_vars = 0; nivelLex=0; desloc=0; }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO
             { geraCodigo (NULL, "PARA"); }
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;




parte_declara_vars:  var
;


var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              {
                  printf("TOKEEEEEEEN: %s\n", token);
                  char comando[COMMAND_SIZE];
                  sprintf(comando, "AMEM %d", num_vars);
                  geraCodigo(NULL, comando);
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere ultima vars na tabela de simbolos */
                  printf("TOKEEEEEEEN: %s\n", token);
                  simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, inteiro, desloc);
                  push((pilha_t **)&tds, (pilha_t *)s);
                  imprime_pilha((pilha_t *)s, print_elem);
                  num_vars++;
               }
            | IDENT { /* insere vars na tabela de simbolos */
               printf("TOKEEEEEEEN: %s\n", token);
               simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, inteiro, desloc);
               push((pilha_t **)&tds, (pilha_t *)s);
               imprime_pilha((pilha_t *)s, print_elem);

               num_vars=0;
               desloc++;         

            }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
   comandos PONTO_E_VIRGULA comando_sem_rotulo | comando_sem_rotulo
;

comando_sem_rotulo: 
    comando_composto
    | atribuicao
    | /* outros comandos, como IF, WHILE, etc., se necessário */
;

atribuicao:
      variavel
      {
         simbolo_t* s = buscaPorId(tds, token);
         if (s != NULL){
            l_elem = s;
         }
      }
      ATRIBUICAO 
      expressao
      {
         char comando[COMMAND_SIZE];
         
         sprintf(comando, "ARMZ %d, %d", l_elem->nivel, l_elem->deslocamento);
         geraCodigo(NULL, comando);
      }
;

variavel:
   IDENT
;

expressao:
   expressao_simples
   | expressao_simples relacao expressao_simples
   | expressao T_AND expressao
   | expressao T_OR expressao
   | expressao T_DIV expressao
   | T_NOT expressao
   | ABRE_PARENTESES expressao FECHA_PARENTESES
   | /* outras regras para expressões */
;

relacao:
   T_DIFERENTE
   | T_MENOR
   | T_MENOR_IGUAL
   | T_MAIOR_IGUAL
   | T_MAIOR

expressao_simples:
   operadores termo termo_operadores
   | termo termo_operadores
   | termo
;

operadores:
   T_MAIS
   | T_MENOS
;

termo_operadores:
   termo_operadores operadores_com_or termo
   | operadores_com_or termo
;

operadores_com_or:
   T_MAIS
   | T_MENOS
   | T_OR
;

termo:
   fator termo_composto
   | fator
;

termo_composto:
   termo_composto operadores_logicos fator
   | operadores_logicos fator
;

operadores_logicos:
   T_DIV
   | T_AND
   | T_MULT
;

fator:
   variavel
   | NUMERO
   {
      // printf("TOKEEEEEEEN: %s\n", token);
      char comando[COMMAND_SIZE];
      sprintf(comando, "CRCT %d", atoi(token));
      geraCodigo(NULL, comando);
   }
   | expressao
   | T_NOT fator 
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
      printf("usage compilador <arq>a %d\n", argc);
      return(-1);
   }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   
   yyin=fp;
   yyparse();

   return 0;
}
