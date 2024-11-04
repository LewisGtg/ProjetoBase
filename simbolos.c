#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simbolos.h"

simbolo_t *criaSimbolo(char *id, short categoria, int nivel, short tipo, int deslocamento)
{
    simbolo_t *s = malloc(sizeof(simbolo_t));
    s->prev = NULL;
    s->id = malloc((strlen(id) + 1) * sizeof(char));
    strcpy(s->id, id);
    s->categoria = categoria;
    s->nivel = nivel;
    s->tipo = tipo;
    s->deslocamento = deslocamento;
    return s;
}

void print_elem(void *ptr)
{
    simbolo_t *elem = (simbolo_t *)ptr;
    char categorias[3][50] = {"variavel_simples", "parametro_formal", "rotulo"};
    char tipos[2][30] = {"inteiro", "booleano"};

    printf("id: %s, categoria: %s, nivel léxico: %d, deslocamento: %d, tipo: %s \n", elem->id, categorias[elem->categoria], elem->nivel, elem->deslocamento, tipos[elem->tipo]);
    return;
}