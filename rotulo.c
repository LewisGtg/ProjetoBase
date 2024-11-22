#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "rotulo.h"

rotulo_t * criaRotulo(int id)
{
    rotulo_t * r = malloc(sizeof(rotulo_t));
    r->id = malloc(sizeof(char) * 3);

    if (id <= 9)
        sprintf(r->id, "R0%d", id);
    else
        sprintf(r->id, "R%d", id);
        
    r->prev = NULL;
    return r;
}
