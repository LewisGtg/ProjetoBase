#include <stdio.h>
#include <stdlib.h>
#include "pilha.h"

int push(pilha_t **pilha, pilha_t *elem)
{
    if (pilha == NULL || elem == NULL)
    {
        fprintf(stderr, "Erro: pilha ou elemento é NULL\n");
        return -1;
    }

    elem->prev = *pilha; // O novo elemento aponta para o antigo topo
    *pilha = elem;       // Atualiza o topo da pilha

    return 0;
}

void * pop(pilha_t **pilha)
{
    if (pilha == NULL || *pilha == NULL)
    {
        fprintf(stderr, "Erro: pilha não existe ou está vazia\n");
        return NULL;
    }

    pilha_t *removido = *pilha; // Armazena o elemento a ser removido
    *pilha = removido->prev;    // Atualiza o topo da pilha

    removido->prev = NULL; // Remove a referência à pilha original

    return removido;
}

int limpa(pilha_t *pilha)
{
    printf("limpando a pilha\n");
    printf("primeiro elemento: %p\n", pilha);

    while (pilha != NULL)
    {
        pop(&pilha);
        printf("removeu elemento\n");
    }
}

void imprime_pilha(pilha_t *pilha, void print_elem(void *))
{
    printf("Pilha:\n");
    while (pilha != NULL)
    {
        print_elem(pilha); // Chama a função de impressão para cada elemento
        pilha = pilha->prev;
    }
}

// Conta o número de elementos na pilha
int tamanho_pilha(pilha_t *pilha)
{
    int count = 0;
    pilha_t *travel = pilha;

    while (travel != NULL)
    {
        count++;
        travel = travel->prev; // Percorre os elementos da pilha
    }
    return count;
}