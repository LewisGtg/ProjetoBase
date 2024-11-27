#!/bin/bash

# Caminho do diretório onde estão os arquivos de teste
DIRETORIO="teste_aulas"

# Caminho do compilador
COMPILADOR="./compilador"

# Função para verificar se a linha contém identificador RXY
contains_RXY() {
    local line="$1"
    [[ $line =~ R[0-9]{2} ]]
}

# Função para normalizar uma linha (remover espaços extras, tabs, quebras de linha, e espaços após vírgulas)
normalize_line() {
    echo "$1" | tr -d '\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//' | sed 's/, */,/g'
}

# Loop pelos arquivos .pas das aulas, ignorando aula 10
for ARQUIVO_PAS in $DIRETORIO/aula[8-9]*.pas $DIRETORIO/aula1[1-3]*.pas; do
    # Extrair o prefixo do arquivo (ex: aula8.pas -> aula8)
    PREFIXO=$(basename "$ARQUIVO_PAS" .pas)

    # Verificar se o arquivo .mepa correspondente existe
    ARQUIVO_MEPA_ESPERADO="$DIRETORIO/$PREFIXO.mepa"
    if [ -f "$ARQUIVO_MEPA_ESPERADO" ]; then
        echo "Testando $ARQUIVO_PAS..."

        # Executar o compilador com o arquivo .pas
        $COMPILADOR "$ARQUIVO_PAS" > /dev/null

        # Verificar se o arquivo MEPA foi gerado
        if [ ! -f "MEPA" ]; then
            echo "Erro: Arquivo MEPA não foi gerado pelo compilador."
            continue
        fi

        # Comparar os arquivos linha por linha
        DIFFERENCE_FOUND=false
        exec 3<"$ARQUIVO_MEPA_ESPERADO"
        while IFS= read -r line1 && IFS= read -r line2 <&3; do
            # Normalizar linhas
            line1=$(normalize_line "$line1")
            line2=$(normalize_line "$line2")

            if [ "$line1" != "$line2" ]; then
                if contains_RXY "$line1" || contains_RXY "$line2"; then
                    echo "Aviso: Diferença ignorada com identificador RXY."
                    echo "Linha gerada:    $line1"
                    echo "Linha esperada:  $line2"
                else
                    DIFFERENCE_FOUND=true
                    echo "ERRO: Diferença encontrada."
                    echo "Linha gerada:    $line1"
                    echo "Linha esperada:  $line2"
                fi
            fi
        done < MEPA

        # Exibir status final
        if [ "$DIFFERENCE_FOUND" = false ]; then
            echo "SUCESSO: O arquivo MEPA gerado está correto para $ARQUIVO_PAS."
        else
            echo "ERRO: Arquivo MEPA gerado está incorreto para $ARQUIVO_PAS."
        fi

        # Fechar descritor de arquivo 3
        exec 3<&-

        # Remover o arquivo MEPA gerado para evitar conflitos
        rm MEPA
    else
        echo "Aviso: Arquivo $ARQUIVO_MEPA_ESPERADO não encontrado. Pulando o teste."
    fi

    echo "-------------------------------------------"
done
