#include <stdio.h>
#include <stdlib.h>
#include "pilha.h"

pilha_t *criaPilha()
{
    pilha_t *p = malloc(sizeof(pilha_t));
    p->elementos = malloc(sizeof(int) * INITIAL_STACK_SIZE);
    p->topo = NULL;
    p->tamanho = INITIAL_STACK_SIZE;
    p->num_elementos = 0;
    return p;
}

int destroi_pilha(pilha_t *pilha)
{
    return 0;
}

int push(pilha_t *pilha, int valor)
{
    if (pilha->num_elementos == pilha->tamanho)
    {
        int *new_ptr = (int *)realloc(pilha->elementos, sizeof(int) * (pilha->num_elementos + 10));
        pilha->elementos = new_ptr;
        pilha->tamanho += 10;

        pilha->topo = pilha->elementos + pilha->num_elementos-1;
    }

    if (pilha->num_elementos == 0)
    {
        pilha->topo = pilha->elementos;
        *(pilha->topo) = valor;
        pilha->num_elementos++;

        return 0;
    }

    pilha->topo++;
    *(pilha->topo) = valor;
    pilha->num_elementos++;

    return 0;
}

int pop(pilha_t *pilha)
{
    if (pilha->topo == NULL)
        return -1;

    if (pilha->num_elementos == 1)
    {
        pilha->topo = NULL;
        pilha->num_elementos--;
        return 0;
    }

    pilha->topo--;
    pilha->num_elementos--;

    return 0;
}

void imprime_pilha(pilha_t *pilha)
{
    for (int i = 0; i < pilha->num_elementos; ++i)
        printf("%d\n", *(pilha->topo - i));
    printf("\n");
}