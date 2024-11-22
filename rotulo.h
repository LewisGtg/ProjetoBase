#ifndef __ROT__
#define __ROT__

typedef struct rotulo
{
    struct rotulo *prev;
    char * id;
} rotulo_t;

rotulo_t * criaRotulo(int id);

void print_rotulo(void * t);

#endif