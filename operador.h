#ifndef OP
#define OP

typedef struct operador {
    struct operador * prev;
    char * op;
} operador_t;

operador_t * criaOperador(char * op);

#endif