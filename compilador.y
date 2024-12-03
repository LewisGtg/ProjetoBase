

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
#include "operador.h"

int nivelLex = 0;
int num_vars = 0;
int num_vars_tot[] = {0,0,0,0,0,0};
int desloc[] = {0,0,0,0,0,0};
int qt_rotulo = 0;
int aloca_parametro = 0;
int num_parametros = 0;
int eh_parametro_referencia = 0;
int eh_write = 0;
int eh_read = 0;
int eh_chamada = 0;
int qt_params_chamada = 0;

simbolo_t * tds = NULL;
simbolo_t * l_elem = NULL;
simbolo_t * the_real_l_elem = NULL;
simbolo_t * proc_atual = NULL;
inteiro_t * aritmetica = NULL;
tipos_t * pts = NULL;
rotulo_t * prt = NULL;
operador_t * po = NULL;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES NUMERO
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token T_LABEL T_TYPE T_ARRAY
%token T_PROCEDURE T_FUNCTION
%token T_IF T_ELSE T_THEN T_WHILE T_DO T_OR T_DIV T_AND T_NOT 
%token T_MULT T_MAIS T_MENOS T_DIFERENTE T_MENOR T_MENOR_IGUAL T_MAIOR T_MAIOR_IGUAL T_IGUAL
%token T_IMPR T_READ

%%

programa    :{ geraCodigo (NULL, "INPP"); }
             PROGRAM IDENT
             parametros_opc PONTO_E_VIRGULA
             bloco PONTO
             { geraCodigo (NULL, "PARA"); }
;

parametros_opc:
   ABRE_PARENTESES lista_idents FECHA_PARENTESES
   | 
;

bloco       :
              parte_declara_vars
              {
                  char comando[COMMAND_SIZE];
                  rotulo_t * rotulo = criaRotulo(qt_rotulo++);
                  push((pilha_t**)&prt, (pilha_t*)rotulo);
                  sprintf(comando, "DSVS %s", rotulo->id);
                  geraCodigo(NULL, comando);
              }
              parte_declaracao_sub_rotinas
              {
                  rotulo_t * r = (rotulo_t*  )pop((pilha_t**)&prt);
                  geraCodigo(r->id, "NADA");
              }
              comando_composto
               {
                  char comando[COMMAND_SIZE];
                  sprintf(comando, "DMEM %d", num_vars_tot[nivelLex]);
                  geraCodigo(NULL, comando);
                  // remove elementos do nivel lexico corrente
                  simbolo_t* s = tds;
                  while (s != NULL &&
                        (s->nivel == nivelLex && !(s->categoria==procedimento || s->categoria==funcao) ||
                        (s->nivel-1 == nivelLex && (s->categoria==procedimento || s->categoria==funcao)))){
                     printf("remove %s\n", s->id);
                     pop((pilha_t**)&tds);
                     s = tds;
                  }
                  num_vars_tot[nivelLex] = 0;
               }
               pv_opcional

;

pv_opcional:
   PONTO_E_VIRGULA
   |
;


parte_declara_vars: var
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
      int aux = num_vars;

      if (aloca_parametro)
      {
         num_vars = num_parametros;
         printf("NUM_PARAMS = %d\n", num_parametros);

         if (strcmp(token, "integer") == 0)
            defineTiposParametros(l_elem, inteiro, num_parametros);
         else if (strcmp(token, "boolean") == 0)
            defineTiposParametros(l_elem, booleano, num_parametros);
      }
      
      if (strcmp(token, "integer") == 0)
         defineTipos(tds, inteiro, num_vars);
      else if (strcmp(token, "boolean") == 0)
         defineTipos(tds, booleano, num_vars);
      
      num_vars = aux;
      num_vars_tot[nivelLex] += num_vars;
      num_vars = 0;
   }
;

lista_id_var: 
            IDENT 
            { /* insere ultima vars na tabela de simbolos */
               simbolo_t *s=criaSimbolo(token, variavel_simples, nao_definido, NULL, nivelLex, desloc[nivelLex], invalido);
               push((pilha_t **)&tds, (pilha_t *)s);
               num_vars++;
               desloc[nivelLex]++;
            }   
            suporte_lista_id_var
;

suporte_lista_id_var:
   VIRGULA lista_id_var
   | 
;

lista_idents: 
   IDENT
   {
      if (aloca_parametro)
      {
         short tipo_parametro = eh_parametro_referencia ? referencia : valor;
         simbolo_t * p = criaSimbolo(token, parametro_formal, nao_definido, NULL, nivelLex, 0, tipo_parametro);
         
         l_elem->parametros[num_parametros][0] = nao_definido;
         l_elem->parametros[num_parametros][1] = tipo_parametro;
         l_elem->num_params++;

         push((pilha_t**)&tds, (pilha_t*)p);
         num_parametros++;
      }
   }
   suporte_lista_idents
;

suporte_lista_idents:
   VIRGULA lista_idents
   |
;

// Regra n°11
parte_declaracao_sub_rotinas:
   parte_declaracao_sub_rotinas
   {
      desloc[++nivelLex] = 0;
   }
   suporte_declaracao_subrotinas
   {
      nivelLex--;
   }
   | 
;

suporte_declaracao_subrotinas:
   declaracao_prodecimento 
   | declaracao_funcao
;

// Regra n°12
declaracao_prodecimento:
   T_PROCEDURE
   IDENT
   {
      char comando[COMMAND_SIZE];
      rotulo_t * rotulo_proc = criaRotulo(qt_rotulo++);
      push((pilha_t**)&prt, (pilha_t*)rotulo_proc);
      sprintf(comando, "ENPR %d", nivelLex);
      geraCodigo(rotulo_proc->id, comando);

      simbolo_t * p = criaSimbolo(token, procedimento, nao_definido, rotulo_proc, nivelLex, 0, invalido);
      l_elem = p;
      proc_atual = p;
      push((pilha_t**)&tds, (pilha_t*)p);
   }
   parametros_formais
   PONTO_E_VIRGULA
   bloco
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "RTPR %d, %d", nivelLex, proc_atual->num_params);
      pop((pilha_t**)&prt);
      geraCodigo(NULL, comando);
   }
;

// Regra n° 13
declaracao_funcao:
   T_FUNCTION
   IDENT
   {
      char comando[COMMAND_SIZE];
      rotulo_t * rotulo_proc = criaRotulo(qt_rotulo++);
      push((pilha_t**)&prt, (pilha_t*)rotulo_proc);
      sprintf(comando, "ENPR %d", nivelLex);
      geraCodigo(rotulo_proc->id, comando);

      simbolo_t * p = criaSimbolo(token, funcao, nao_definido, rotulo_proc, nivelLex, 0, invalido);
      l_elem = p;
      proc_atual = p;
      push((pilha_t**)&tds, (pilha_t*)p);
   }
   parametros_formais
   DOIS_PONTOS
   IDENT
   {
      if (strcmp(token, "integer") == 0)
         proc_atual->tipo = inteiro;
      else if (strcmp(token, "boolean") == 0)
         proc_atual->tipo = booleano;
   }
   PONTO_E_VIRGULA
   bloco
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "RTPR %d, %d", nivelLex, proc_atual->num_params);
      pop((pilha_t**)&prt);
      geraCodigo(NULL, comando);
   }
;

// Regra n°14
parametros_formais:
   ABRE_PARENTESES
   {
      aloca_parametro = 1;
   }
   secao_parametros_formais
   FECHA_PARENTESES
   {
      l_elem->num_params++;
      aloca_parametro = 0;
      defineDeslocamentoParams(l_elem, tds);
      l_elem->num_params--;
   }
   |
;

// Regra n°15
secao_parametros_formais:
   | lista_idents DOIS_PONTOS tipo suporte_parametros_formais
   | VAR { eh_parametro_referencia = 1; } lista_idents DOIS_PONTOS tipo { eh_parametro_referencia = 0; } suporte_parametros_formais
   | T_FUNCTION lista_idents DOIS_PONTOS tipo
   | T_PROCEDURE lista_idents
;

suporte_parametros_formais:
   PONTO_E_VIRGULA secao_parametros_formais
   |
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
   | variavel 
   {
      simbolo_t* s = buscaPorId(tds, token);
      if (s != NULL){
         l_elem = s;
      }
   }
   a_continua 
   | comando_repetitivo
   | comando_condicional   
   | write
   | read
   | /* outros comandos, como IF, WHILE, etc., se necessário */
;

a_continua:
   ATRIBUICAO { the_real_l_elem = l_elem; } expressao
   {
      char comando[COMMAND_SIZE];

      char instrucao[5];
      if (the_real_l_elem->tipo_passagem == referencia)
         strcpy(instrucao, "ARMI");
      else
         strcpy(instrucao, "ARMZ");

      sprintf(comando, "%s %d, %d", instrucao, the_real_l_elem->nivel, the_real_l_elem->deslocamento);
      geraCodigo(NULL, comando);
      
      // Desempilha o tipo da última expressão e compara com o lado esquedo da atribuição
      tipos_t * t = (tipos_t*) pop((pilha_t**)&pts);
      if (the_real_l_elem->tipo != t->tipo)
         printf("tipos não correspondem\n");

   }
   | lista_expressoes 
;

lista_expressoes:
   ABRE_PARENTESES { eh_chamada = 1; } expressao_opcional FECHA_PARENTESES { eh_chamada = 0; qt_params_chamada = 0; }
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "CHPR %s, %d", l_elem->rotulo->id, nivelLex);
      geraCodigo(NULL, comando);
   }
   |
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "CHPR %s, %d", l_elem->rotulo->id, nivelLex);
      geraCodigo(NULL, comando);
   }
;

expressao_opcional:
   expressao_opcional { qt_params_chamada++; } VIRGULA expressao
   | expressao
;

write:
   T_IMPR { eh_write = 1; }
   ABRE_PARENTESES
   expressao_opcional_write
   FECHA_PARENTESES { eh_write = 0; }
;

read:
   T_READ { eh_read = 1; }
   ABRE_PARENTESES
   expressao_opcional_write
   FECHA_PARENTESES { eh_read = 0; }
;

expressao_opcional_write:
   expressao_opcional_write VIRGULA expressao
   | expressao
;

// Regra n°22
comando_condicional:
   T_IF
   {
      rotulo_t * r_final = criaRotulo(qt_rotulo++);      
      push((pilha_t**)&prt, (pilha_t*)r_final);
   }
   expressao
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVF %s", prt->id);
      geraCodigo(NULL, comando);
   }
   T_THEN 
   comando_sem_rotulo
   else
;

else:
   T_ELSE
   {
      rotulo_t * r_final = criaRotulo(qt_rotulo++);

      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVS %s", r_final->id);
      geraCodigo(NULL, comando);

      rotulo_t * r_else = pop((pilha_t**)&prt);
      sprintf(comando, "NADA");
      geraCodigo(r_else->id, comando);
      
      push((pilha_t**)&prt, (pilha_t*)r_final);
   }
   comando_sem_rotulo
   {
      rotulo_t * r_final = pop((pilha_t**)&prt);
      char comando[COMMAND_SIZE];
      sprintf(comando, "NADA");
      geraCodigo(r_final->id, comando);
   }
   |
   {
      rotulo_t * r_final = pop((pilha_t**)&prt);
      char comando[COMMAND_SIZE];
      sprintf(comando, "NADA");
      geraCodigo(r_final->id, comando);
   }
;

// Regra n°23
comando_repetitivo:
   T_WHILE
   {
      rotulo_t * r_inicial = criaRotulo(qt_rotulo++);
      push((pilha_t**)&prt, (pilha_t*)r_inicial);

      rotulo_t * r_final = criaRotulo(qt_rotulo++);
      push((pilha_t**)&prt, (pilha_t*)r_final);

      char comando[COMMAND_SIZE];
      sprintf(comando, "NADA");

      geraCodigo(r_inicial->id, comando);
   }
   expressao
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVF %s", prt->id);

      geraCodigo(NULL, comando);
   }
   T_DO
   comando_sem_rotulo
   {
      rotulo_t * r_final = (rotulo_t*) pop((pilha_t**)&prt);
      rotulo_t * r_inicial = (rotulo_t*) pop((pilha_t**)&prt);

      char comando[COMMAND_SIZE];
      sprintf(comando, "DSVS %s", r_inicial->id);
      geraCodigo(NULL, comando);

      sprintf(comando, "NADA");
      geraCodigo(r_final->id, comando);
   }
;

expressao:
   expressao_simples relacao_expressao
;

relacao_expressao:
   relacao
   expressao_simples
   {
      operador_t * operador = pop((pilha_t**)&po);

      tipos_t * t = criaTipos(booleano);
      push((pilha_t**)&pts, (pilha_t*)t);
      geraCodigo(NULL, operador->op);
   }
   | 
;

// Regra n°26
relacao:
   T_DIFERENTE
   | T_IGUAL 
   { 
      operador_t * op = criaOperador("CMIG");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_MENOR_IGUAL
   { 
      operador_t * op = criaOperador("CMEG");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_MENOR
   {
      operador_t * op = criaOperador("CMME");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_MAIOR_IGUAL
   {
      operador_t * op = criaOperador("CMAG");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_MAIOR
   {
      operador_t * op = criaOperador("CMMA");
      push((pilha_t**)&po, (pilha_t*)op);
   }
;

// Regra n°27
expressao_simples:
   operadores termo termo_operadores 
   | termo expressao_termo_operadores
;

expressao_termo_operadores:
   termo_operadores
   |
;

termo_operadores:
   termo_operadores operadores termo 
   {
      operador_t * operador = pop((pilha_t**)&po);

      geraCodigo(NULL, operador->op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
   | operadores termo 
   {
      operador_t * operador = pop((pilha_t**)&po);

      geraCodigo(NULL, operador->op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
;

operadores:
   T_MAIS
   {
      operador_t * op = criaOperador("SOMA");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_MENOS
   {
      operador_t * op = criaOperador("SUBT");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_OR
;

// Regra n°28
termo:
   fator suporte_termo_composto
;

suporte_termo_composto:
   termo_composto
   | ABRE_PARENTESES { geraCodigo(NULL, "AMEM 1"); eh_chamada=1; }
   expressao_opcional 
   FECHA_PARENTESES
   { eh_chamada=0; qt_params_chamada = 0; }
   {
      char comando[COMMAND_SIZE];
      sprintf(comando, "CHPR %s, %d", l_elem->rotulo->id, nivelLex);
      geraCodigo(NULL, comando);

      if (eh_write)
      {
         sprintf(comando, "IMPR");
         geraCodigo(NULL, comando);
      }
   }
   |
;

termo_composto:
   termo_composto
   operadores_logicos
   fator
   {
      operador_t * operador = pop((pilha_t**)&po);

      geraCodigo(NULL, operador->op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
   | operadores_logicos
   fator
   {
      operador_t * operador = pop((pilha_t**)&po);

      geraCodigo(NULL, operador->op);
      if (!tiposCorrespondem(pts))
         printf("tipos não correspondem\n");
   }
;

operadores_logicos:
   T_DIV
   {
      operador_t * op = criaOperador("DIVI");
      push((pilha_t**)&po, (pilha_t*)op);
   }
   | T_AND
   | T_MULT
   {
      operador_t * op = criaOperador("MULT");
      push((pilha_t**)&po, (pilha_t*)op);
   }
;

// Regra n°29
fator:
   variavel
   {
      simbolo_t * s = buscaPorId(tds, token);
      tipos_t * t = criaTipos(s->tipo);

      if (s->categoria == funcao) {
         l_elem = s;
      }

      char comando[COMMAND_SIZE];
      
      char instrucao[5];

      if (eh_chamada)
      {
         if (l_elem->parametros[qt_params_chamada][1] == referencia)
         {
            if (s->categoria == parametro_formal && s->tipo_passagem == referencia)
               strcpy(instrucao, "CRVL");
            else
               strcpy(instrucao, "CREN");
         }
         else
            strcpy(instrucao, "CRVL");
      }
      else if (s->tipo_passagem == referencia)
         strcpy(instrucao, "CRVI");
      else
      {
         if (eh_read)
         {
            geraCodigo(NULL, "LEIT");
            strcpy(instrucao, "ARMZ");
         }
         else strcpy(instrucao, "CRVL");
      }

      if (s->categoria != funcao) {
         sprintf(comando, "%s %d, %d", instrucao, s->nivel, s->deslocamento);
         geraCodigo(NULL, comando);
      }

      if (eh_write && s->categoria != funcao && eh_chamada == 0){
         char comando_impr[COMMAND_SIZE];
         sprintf(comando_impr, "IMPR");
         geraCodigo(NULL, comando_impr);
      } 

      imprime_pilha((pilha_t*)tds, print_elem);
      push((pilha_t **)&pts, (pilha_t *)t);
   }
   | NUMERO
   {
      char comando[COMMAND_SIZE];

      sprintf(comando, "CRCT %d", atoi(token));
      
      tipos_t * t = criaTipos(inteiro);
      
      push((pilha_t **)&pts, (pilha_t *)t);

      geraCodigo(NULL, comando);

      if (eh_write && eh_chamada == 0){
         char comando_impr[COMMAND_SIZE];
         sprintf(comando_impr, "IMPR");
         geraCodigo(NULL, comando_impr);
      }
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
