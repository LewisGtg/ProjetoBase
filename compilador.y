

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
#include "pilhaTipos.h"
#include "rotulo.h"

int nivelLex, desloc;
int num_vars = 0;
int num_vars_tot = 0;
int desloc_rotulo = 0;

simbolo_t * tds = NULL;
simbolo_t * l_elem = NULL;
inteiro_t * aritmetica = NULL;
tipos_t * pts = NULL;
rotulo_t * prt = NULL;
char op[5];

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES NUMERO
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token T_LABEL T_TYPE T_ARRAY
%token T_PROCEDURE T_FUNCTION
%token T_IF T_ELSE T_THEN T_WHILE T_DO T_OR T_DIV T_AND T_NOT 
%token T_MULT T_MAIS T_MENOS T_DIFERENTE T_MENOR T_MENOR_IGUAL T_MAIOR T_MAIOR_IGUAL T_IGUAL

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
               {
                  char comando[COMMAND_SIZE];
                  sprintf(comando, "DMEM %d", num_vars_tot);
                  geraCodigo(NULL, comando);
                  num_vars_tot = 0;
               }
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
              {
                  char comando[COMMAND_SIZE];
                  sprintf(comando, "AMEM %d", num_vars);
                  geraCodigo(NULL, comando);
              }
              tipo
              PONTO_E_VIRGULA
;

tipo: 
   IDENT
   {
      if (strcmp(token, "integer") == 0)
         defineTipos(tds, inteiro, num_vars);
      else if (strcmp(token, "boolean") == 0)
         defineTipos(tds, booleano, num_vars);

      imprime_pilha((pilha_t *)tds, print_elem);

      num_vars_tot += num_vars;
      num_vars = 0;
   }
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere ultima vars na tabela de simbolos */
                  simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, nao_definido, desloc);
                  push((pilha_t **)&tds, (pilha_t *)s);
                  imprime_pilha((pilha_t *)s, print_elem);
                  num_vars++;
                  desloc++;
               }
            | IDENT { /* insere vars na tabela de simbolos */
               simbolo_t *s=criaSimbolo(token, variavel_simples, nivelLex, nao_definido, desloc);
               push((pilha_t **)&tds, (pilha_t *)s);
               imprime_pilha((pilha_t *)s, print_elem);

               num_vars++;
               desloc++;
            }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

// Regra n°16
comando_composto: 
   T_BEGIN 
   comandos
   T_END
;

// Regra n°17
comandos:
   comandos PONTO_E_VIRGULA comando_sem_rotulo | comando_sem_rotulo
;

// Regra n°18
comando_sem_rotulo: 
   comando_composto
   | atribuicao
   | comando_repetitivo
   | comando_condicional
   | /* outros comandos, como IF, WHILE, etc., se necessário */
;

// Regra n°19
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
         
         // Desempilha o tipo da última expressão e compara com o lado esquedo da atribuição
         tipos_t * t = (tipos_t*) pop((pilha_t**)&pts);
         if (l_elem->tipo != t->tipo)
            printf("tipos não correspondem\n");

      }
;

// Regra n°22
comando_condicional:
   T_IF
   {
      rotulo_t * r_else = criaRotulo('R', nivelLex, desloc_rotulo);
      desloc_rotulo++;
      rotulo_t * r_final = criaRotulo('R', nivelLex, desloc_rotulo);
      desloc_rotulo++;
      
      push((pilha_t**)&prt, (pilha_t*)r_final);
      push((pilha_t**)&prt, (pilha_t*)r_else);
   }
   expressao
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVF %c%d%d", prt->id, prt->nl, prt->desloc);
      geraCodigo(NULL, comando);
   }
   T_THEN 
   comando_sem_rotulo
   {
      rotulo_t * r_final = prt->prev;
      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVS %c%d%d", r_final->id, r_final->nl, r_final->desloc);
      geraCodigo(NULL, comando);
   }
   suporte_if
;

suporte_if:
   T_ELSE
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "%c%d%d: NADA", prt->id, prt->nl, prt->desloc);
      geraCodigo(NULL, comando);
   }
   comando_sem_rotulo
   {
      pop((pilha_t**)&prt);
      rotulo_t * r_final = pop((pilha_t**)&prt);
      char comando[COMMAND_SIZE];
      sprintf(comando, "%c%d%d: NADA", r_final->id, r_final->nl, r_final->desloc);
      geraCodigo(NULL, comando);
   }
   | 
   { 
      char comando[COMMAND_SIZE];
      sprintf(comando, "%c%d%d: NADA", prt->id, prt->nl, prt->desloc);
      geraCodigo(NULL, comando);
      pop((pilha_t**)&prt);
      sprintf(comando, "%c%d%d: NADA", prt->id, prt->nl, prt->desloc);
      geraCodigo(NULL, comando);

   }
;

// Regra n°23
comando_repetitivo:
   T_WHILE
   {
      rotulo_t * r_inicial = criaRotulo('R', nivelLex, desloc_rotulo);
      desloc_rotulo++;
      push((pilha_t**)&prt, (pilha_t*)r_inicial);

      rotulo_t * r_final = criaRotulo('R', nivelLex, desloc_rotulo);
      desloc_rotulo++;
      push((pilha_t**)&prt, (pilha_t*)r_final);

      char comando[COMMAND_SIZE];
      sprintf(comando, "%c%d%d: NADA", r_inicial->id, r_inicial->nl, r_inicial->desloc);

      geraCodigo(NULL, comando);
   }
   expressao
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVF %c%d%d", prt->id, prt->nl, prt->desloc);

      geraCodigo(NULL, comando);
   }
   T_DO
   comando_sem_rotulo
   {
      rotulo_t * r_final = (rotulo_t*) pop((pilha_t**)&prt);
      rotulo_t * r_inicial = (rotulo_t*) pop((pilha_t**)&prt);

      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVS %c%d%d", r_inicial->id, r_inicial->nl, r_inicial->desloc);
      geraCodigo(NULL, comando);

      sprintf(comando, "%c%d%d: NADA", r_final->id, r_final->nl, r_final->desloc);
      geraCodigo(NULL, comando);
   }
;

// Regra n°25
expressao:
   expressao_simples relacao expressao_simples
   {
      geraCodigo(NULL, op);
      tipos_t * t = criaTipos(booleano);
      push((pilha_t**)&pts, (pilha_t*)t);
   }
   | expressao T_AND expressao
   | expressao T_OR expressao
   | expressao T_DIV expressao
   | T_NOT expressao
   | ABRE_PARENTESES expressao FECHA_PARENTESES
   | expressao_simples
   | /* outras regras para expressões */
;

// Regra n°26
relacao:
   T_DIFERENTE
   | T_IGUAL { strcpy(op, "CMIG"); }
   | T_MENOR { strcpy(op, "CMME"); }
   | T_MENOR_IGUAL { strcpy(op, "CMEG"); }
   | T_MAIOR_IGUAL { strcpy(op, "CMAG"); }
   | T_MAIOR { strcpy(op, "CMMA"); }

// Regra n°27
expressao_simples:
   operadores termo termo_operadores 
   | termo termo_operadores
   | termo
;

termo_operadores:
   termo_operadores operadores termo 
   {
      geraCodigo(NULL, op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
   | operadores termo 
   {
      geraCodigo(NULL, op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
;

operadores:
   T_MAIS { strcpy(op, "SOMA"); }
   | T_MENOS { strcpy(op, "SUBT"); }
   | T_OR
;

// Regra n°28
termo:
   fator termo_composto
   | fator
;

termo_composto:
   termo_composto operadores_logicos fator
   | operadores_logicos fator
;

operadores_logicos:
   T_DIV { strcpy(op, "DIVI"); }
   | T_AND
   | T_MULT
;

// Regra n°29
fator:
   variavel
   {
      simbolo_t * s = buscaPorId(tds, token);
      tipos_t * t = criaTipos(s->tipo);
      
      char comando[COMMAND_SIZE];
      sprintf(comando, "CRVL %d, %d", s->nivel, s->deslocamento);
      geraCodigo(NULL, comando);

      push((pilha_t **)&pts, (pilha_t *)t);
   }
   | NUMERO
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "CRCT %d", atoi(token));
      
      tipos_t * t = criaTipos(inteiro);
      
      push((pilha_t **)&pts, (pilha_t *)t);

      geraCodigo(NULL, comando);
   }
   | ABRE_PARENTESES expressao FECHA_PARENTESES
   | T_NOT fator 
;

// Regra n°30
variavel:
   IDENT
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
