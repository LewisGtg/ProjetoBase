 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1
OBJETOS = compilador.o utils.o pilha.o simbolos.o pilhaTipos.o rotulo.o operador.o
FONTES = lex.yy.c compilador.tab.c

all: compilador

pilha: testaPilha.c pilha.o simbolos.o
	gcc testaPilha.c pilha.o simbolos.o -o testaPilha

compilador: $(FONTES) $(OBJETOS) compilador.h inteiro.h
	gcc $(FONTES) $(OBJETOS) -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

utils.o : utils.h utils.c
	gcc -c utils.c -o utils.o

pilha.o : pilha.h pilha.c
	gcc -c pilha.c -o pilha.o

simbolos.o : simbolos.h simbolos.c
	gcc -c simbolos.c -o simbolos.o

pilhaTipos.o: pilhaTipos.h pilhaTipos.c
	gcc -c pilhaTipos.c -o pilhaTipos.o

rotulo.o: rotulo.h rotulo.c
	gcc -c rotulo.c -o rotulo.o

operador.o: operador.h operador.c
	gcc -c operador.c -o operador.o

clean :
	rm -f compilador.tab.* lex.yy.c compilador.o compilador
