#ifndef __SIMB__
#define __SIMB__

#include "rotulo.h"

typedef enum categoria
{
    variavel_simples,
    parametro_formal,
    rotulo,
    procedimento,
} categoria_e;

typedef enum passagem
{
    invalido,
    valor,
    referencia
} passagem_e;

typedef enum tipo
{
    nao_definido,
    inteiro,
    booleano
} tipo_e;

typedef struct simbolo
{
    struct simbolo_t *prev;
    char *id;
    short categoria;
    short tipo;
    rotulo_t * rotulo;
    int nivel;
    int deslocamento;
    short tipo_passagem;
} simbolo_t;

simbolo_t *criaSimbolo(char *id, short categoria, short tipo, rotulo_t * rotulo, int nivel, int deslocamento, short tipo_passagem );

simbolo_t *buscaPorId(simbolo_t *head, char *id);

void defineTipos(simbolo_t *head, short tipo, int n);

void print_elem(void *ptr);

#endif