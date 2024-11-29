#include <string.h>
#include <stdlib.h>
#include "operador.h"


operador_t * criaOperador(char * op)
{
    int size = strlen(op);
    operador_t * operador = malloc(sizeof(operador_t));
    operador->op = malloc(size);
    strcpy(operador->op, op);
    return operador;
}
