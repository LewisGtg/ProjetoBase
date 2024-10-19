
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"
#include "pilha.h"

int num_vars;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token T_LABEL T_TYPE T_ARRAY
%token T_PROCEDURE T_FUNCTION
%token T_IF T_ELSE T_WHILE T_DO T_OR T_DIV T_AND T_NOT

%%

programa    :{
             geraCodigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             geraCodigo (NULL, "PARA");
             }
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
              { /* AMEM */
                  char * comando = geraComandoInt("AMEM ", num_vars);
                  geraCodigo(NULL, comando);
                  num_vars = 0;
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere �ltima vars na tabela de s�mbolos */
                  num_vars++;              
               }
            | IDENT { /* insere vars na tabela de s�mbolos */
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

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   pilha_t * tds = criaPilha();
   
   yyin=fp;
   yyparse();

   return 0;
}
