

%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"
#include "pilha.h"
#include "simbolos.h"

int num_vars, nivelLex, desloc;
simbolo_t * tds = NULL;

void print_elem(void *ptr) {
   simbolo_t *elem = (simbolo_t *)ptr;
   printf("id: %s\n", elem->id);
}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token T_LABEL T_TYPE T_ARRAY
%token T_PROCEDURE T_FUNCTION
%token T_IF T_ELSE T_WHILE T_DO T_OR T_DIV T_AND T_NOT

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
                  // printf("TOKEEEEEEEN: %s\n", token);
                  char * comando = geraComandoInt("AMEM ", num_vars);
                  geraCodigo(NULL, comando);
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere �ltima vars na tabela de s�mbolos */
                  printf("TOKEEEEEEEN: %s\n", token);
                  simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, inteiro, desloc);
                  push((pilha_t **)&tds, (pilha_t *)s);
                  imprime_pilha((pilha_t *)s, print_elem);
                  num_vars++;              
               }
            | IDENT { /* insere vars na tabela de s�mbolos */
               printf("TOKEEEEEEEN: %s\n", token);
               simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, inteiro, desloc);
               push((pilha_t **)&tds, (pilha_t *)s);
               imprime_pilha((pilha_t *)s, print_elem);

               num_vars++;
            }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
      printf("usage compilador <arq>a %d\n", argc);
      return(-1);
   }

   simbolo_t *s = NULL;


   // simbolo_t *s1 = criaSimbolo("ab", parametro_formal, 0, inteiro, 10);

   // printf("id: %s\n", s1->id);

   // push((pilha_t **)&s, (pilha_t *)s1);

   // int tam = tamanho_pilha(s);   // imprime_pilha()

   // printf("tamanho: %d\n", tam);

   // imprime_pilha((pilha_t *)s, print_elem);


   // tam = tamanho_pilha(s);   // imprime_pilha()

   // printf("%d\n", tamanho_pilha(s));




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
