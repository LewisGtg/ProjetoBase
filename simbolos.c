#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simbolos.h"
#include "rotulo.h"

simbolo_t *criaSimbolo(char *id, short categoria, short tipo, rotulo_t * rotulo ,int nivel, int deslocamento)
{
    simbolo_t *s = malloc(sizeof(simbolo_t));
    s->prev = NULL;
    s->id = malloc((strlen(id) + 1) * sizeof(char));
    strcpy(s->id, id);
    s->categoria = categoria;
    s->tipo = tipo;
    s->rotulo = rotulo;
    s->nivel = nivel;
    s->deslocamento = deslocamento;
    return s;
}

simbolo_t *buscaPorId(simbolo_t *head, char *id)
{
    simbolo_t *curr = head;
    printf("%s\n", curr->id);
    while (curr != NULL)
    {
        if (strcmp(curr->id, id) == 0)
            return curr;
        curr = curr->prev;
    }
    return NULL;
}

void defineTipos(simbolo_t *head, short tipo, int n)
{
    simbolo_t * curr = head;
    while (curr != NULL && n != 0)
    {
        curr->tipo = tipo;
        curr = curr->prev;
        n--;
    }
}


void print_elem(void *ptr)
{
    simbolo_t *elem = (simbolo_t *)ptr;
    char categorias[4][50] = {"variavel_simples", "parametro_formal", "rotulo", "proc"};
    char tipos[3][30] = {"não definido", "inteiro", "booleano"};

    printf("id: %s, categoria: %s, nivel léxico: %d, deslocamento: %d, tipo: %s \n", elem->id, categorias[elem->categoria], elem->nivel, elem->deslocamento, tipos[elem->tipo]);
    return;
}