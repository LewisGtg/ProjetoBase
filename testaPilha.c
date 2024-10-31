#include <stdio.h>
#include <stdlib.h>
#include "pilha.h"
#include "simbolos.h"

void print_elem(void *ptr) {
   simbolo_t *elem = (simbolo_t *)ptr;
   printf("id: %s\n", elem->id);
}

int main()
{
    simbolo_t * tds = NULL;
    simbolo_t *s1 = criaSimbolo("aaa", parametro_formal, 0, inteiro, 10);
    simbolo_t *s2 = criaSimbolo("bbb", parametro_formal, 0, inteiro, 120);

    push((pilha_t **)&tds, (pilha_t *)s1);
    push((pilha_t **)&tds, (pilha_t *)s2);

    imprime_pilha((pilha_t *)tds, print_elem);

    pop((pilha_t **)&tds);
    pop((pilha_t **)&tds);

    imprime_pilha((pilha_t *)tds, print_elem);
    push((pilha_t **)&tds, (pilha_t *)s2);
    imprime_pilha((pilha_t *)tds, print_elem);

    return 0;
}