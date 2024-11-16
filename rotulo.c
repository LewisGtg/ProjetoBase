#include <stdio.h>
#include <stdlib.h>
#include "rotulo.h"

rotulo_t * criaRotulo(char id, int nl, int desloc)
{
    rotulo_t * r = malloc(sizeof(rotulo_t));
    r->id = id;
    r->nl = nl;
    r->desloc = desloc;
    return r;
}
