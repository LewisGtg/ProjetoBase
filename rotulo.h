#ifndef __ROT__
#define __ROT__

typedef struct rotulo
{
    struct rotulo *prev;
    char id;
    int nl;
    int desloc;
} rotulo_t;

rotulo_t * criaRotulo(char id, int nl, int desloc);

void print_rotulo(void * t);

#endif