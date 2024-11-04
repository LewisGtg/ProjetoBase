typedef enum categoria
{
    variavel_simples,
    parametro_formal,
    rotulo
} categoria_e;

typedef enum tipo
{
    inteiro,
    booleano
} tipo_e;

typedef struct simbolo
{
    struct simbolo_t *prev;
    char *id;
    short categoria;
    short tipo;
    int nivel;
    int deslocamento;
} simbolo_t;

simbolo_t *criaSimbolo(char *id, short categoria, int nivel, short tipo, int deslocamento);

void print_elem(void *ptr);