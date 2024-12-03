#!/bin/bash

EXEMPLOS="Exemplo5 Exemplo7.01 Exemplo7.02 Exemplo7.03 Exemplo7.04 Exemplo7.05 Exemplo8.05 Exemplo8.06 Exemplo8.07 Exemplo8.08 Exemplo8.09 Exemplo8.10 ExemploErro1 ExemploErro2"

echo "Usage: avaliaTrab.sh <arquivo executavel compilador>"

# Função para verificar se a linha contém identificador RXY
contains_RXY() {
    local line="$1"
    [[ $line =~ R[0-9]{2} ]]
}

# Função para normalizar uma linha (remover espaços extras, tabs e quebras de linha)
normalize_line() {
    echo "$1" | tr -d '\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//' | sed 's/, */,/g'
}

for exemplo in $EXEMPLOS; do
    echo -n "$exemplo ... "
    cp $exemplo/pgma.pas .
    cp $exemplo/MEPA MEPA-Res

    $1 pgma.pas > res

    DIFFERENCE_FOUND=false
    RXY_DIFFERENCE_REPORTED=false
    exec 3<MEPA-Res
    while IFS= read -r line1 && IFS= read -r line2 <&3; do
        # Normalizar linhas
        line1=$(normalize_line "$line1")
        line2=$(normalize_line "$line2")

        if [ "$line1" != "$line2" ]; then
            if contains_RXY "$line1" || contains_RXY "$line2"; then
                if [ "$RXY_DIFFERENCE_REPORTED" = false ]; then
                    echo "Aviso: Diferença(s) ignorada(s) devido a identificadores RXY."
                    RXY_DIFFERENCE_REPORTED=true
                fi
            else
                DIFFERENCE_FOUND=true
                echo "ERRO: Diferença encontrada."
                echo "Linha gerada:    $line1"
                echo "Linha esperada:  $line2"
            fi
        fi
    done < MEPA

    if [ "$DIFFERENCE_FOUND" = false ]; then
        if [ "$RXY_DIFFERENCE_REPORTED" = true ]; then
            echo "SUCESSO: Testes passaram com diferença(s) ignorada(s) nos identificadores RXY."
        else
            echo "SUCESSO: Arquivo MEPA gerado está correto para $exemplo."
        fi
    else
        echo "ERRO: Arquivo MEPA gerado está incorreto para $exemplo."
    fi

    exec 3<&-
    rm pgma.pas
    echo "-------------------------------------------"
done
