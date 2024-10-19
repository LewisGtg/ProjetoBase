#define INITIAL_STACK_SIZE 10

typedef struct pilha {
    int *topo;
    int tamanho;
    int num_elementos;
    int *elementos;
} pilha_t;

pilha_t * criaPilha();

int destroi_pilha(pilha_t * pilha);

int push(pilha_t * pilha, int valor);

int pop(pilha_t * pilha);

void imprime_pilha(pilha_t * pilha);