#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *geraComandoInt(char *comandoBase, int valor)
{
    char * comando = calloc(6, sizeof(char));
    char *parametros = calloc(10, sizeof(char));
    sprintf(parametros, "%d", valor);
    strncat(comando, comandoBase, 5);
    strncat(comando, parametros, 6);
    return comando;
}

char *geraComandoNivelLex(char *comandoBase, int lex, int offset)
{
}

char *geraComandoRotulo(char *comandoBase, char *rot, int value)
{
}

char *geraComandoRotuloInt(char *comandoBase, int lex, int offset)
{
}