#include <stdio.h>
#include <stdlib.h>
#include "simbolos.h"

simbolo_t *criaSimbolo(char *id, short categoria, int nivel, short tipo, int deslocamento)
{
    simbolo_t * s = malloc(sizeof(simbolo_t));
    s->id = id;
    s->categoria = categoria;
    s->nivel = nivel;
    s->tipo = tipo;
    s->deslocamento = deslocamento;

    return s;
}