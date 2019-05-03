#!/bin/bash

# Tirado de Daniel Benvenutti

# $1 é o arquivo .s a ser simulado. A saida é o valor final de R0

# Função para ler XML
read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

# Executa os códigos no VisUAL gerando um log dessa execução
java -jar visual_headless.jar --headless $1 simula.log  --td:abort --regs --changed --cycles --mode:completion > /dev/null

# lê o dado na tag certa do XML de log do simulador
while read_dom; do
    if [[ $ENTITY = "register name=\"R0\"" ]]; then
        if (( $CONTENT < 0x80000000 )); then
            printf "%d\n" $CONTENT
        #se for negativo seta o resto dos bits a esquerda para imprimir negativo
        else
            NEGATIVE=$((~0xFFFFFFFF|($CONTENT)));
            printf "%d\n" $NEGATIVE
        fi

        exit
    fi
done < simula.log

# removemos arquivo sem aviso quando não existir
rm -f simula.log
