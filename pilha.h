#ifndef __PILHA__
#define __PILHA__

#define INITIAL_STACK_SIZE 10

typedef struct pilha_t
{
    struct pilha_t *prev;
} pilha_t;

//------------------------------------------------------------------------------
// Conta o numero de elementos na fila
// Retorno: numero de elementos na fila

int tamanho_pilha(pilha_t *pilha);

//------------------------------------------------------------------------------
// Percorre a fila e imprime na tela seu conteúdo. A impressão de cada
// elemento é feita por uma função externa, definida pelo programa que
// usa a biblioteca. Essa função deve ter o seguinte protótipo:
//
// void print_elem (void *ptr) ; // ptr aponta para o elemento a imprimir

void imprime_pilha(pilha_t *pilha, void print_elem(void *));

//------------------------------------------------------------------------------
// Insere um elemento no final da fila.
// Condicoes a verificar, gerando msgs de erro:
// - a fila deve existir
// - o elemento deve existir
// - o elemento nao deve estar em outra fila
// Retorno: 0 se sucesso, <0 se ocorreu algum erro

int push(pilha_t **pilha, pilha_t *elem);

//------------------------------------------------------------------------------
// Remove o elemento indicado da fila, sem o destruir.
// Condicoes a verificar, gerando msgs de erro:
// - a fila deve existir
// - a fila nao deve estar vazia
// - o elemento deve existir
// - o elemento deve pertencer a fila indicada
// Retorno: 0 se sucesso, <0 se ocorreu algum erro

void * pop(pilha_t **pilha);

int limpa(pilha_t *pilha);

#endif