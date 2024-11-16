#include "simbolos.h"

#ifndef __TIP__
#define __TIP__

typedef struct tipos
{
    struct tipos_t *prev;
    short tipo;
} tipos_t;

tipos_t * criaTipos(short tipo);

int tiposCorrespondem(tipos_t * t);

void print_tipo(void * t);

#endif