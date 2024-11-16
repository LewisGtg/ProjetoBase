#include <stdio.h>
#include <stdlib.h>
#include "pilhaTipos.h"
#include "pilha.h"

tipos_t * criaTipos(short tipo)
{
    tipos_t * t = malloc(sizeof(tipos_t));
    t->prev = NULL;
    t->tipo = tipo;
    return t;
}

int tiposCorrespondem(tipos_t * t)
{   
    tipos_t * t1 = (tipos_t *) pop((pilha_t**)&t);
    tipos_t * t2 = (tipos_t *) pop((pilha_t**)&t);

    if (t1->tipo != t2->tipo)
        return 0;

    push((pilha_t**)&t, (pilha_t*)t1);

    return 1;
}

void print_tipo(void * t)
{   
    tipos_t *elem = (tipos_t *)t;
    char tipos[3][30] = {"não definido", "inteiro", "booleano"};

    printf("tipo: %s \n", tipos[elem->tipo]);
    return;
}
