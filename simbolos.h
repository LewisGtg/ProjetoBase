#ifndef __SIMB__
#define __SIMB__

typedef enum categoria
{
    variavel_simples,
    parametro_formal,
    rotulo
} categoria_e;

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
    int nivel;
    int deslocamento;
} simbolo_t;

simbolo_t *criaSimbolo(char *id, short categoria, int nivel, short tipo, int deslocamento);

simbolo_t *buscaPorId(simbolo_t *head, char *id);

void defineTipos(simbolo_t *head, short tipo, int n);

void print_elem(void *ptr);

#endif