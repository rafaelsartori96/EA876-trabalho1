; função para executar multiplicação de r0 com r1
multiplicar:
    ; caso 1: algum dos números é zero
    ;;; caso 2: não são zero, separamos em casos menores:
    ;;;   caso i:     ambos positivos
    ;;;   caso ii:    um deles é negativo
    ;;;   caso iii:   ambos negativos
    ; para isso, guardamos em r2 -1 se r0 for negativo, 1 se for positivo
    ; somamos a r2 o mesmo valor para r1, de modo a obtermos:
    ; r2 = 2  => caso i
    ; r2 = 0  => caso ii
    ; r2 = -2 => caso iii
    ;
    ; nessa análise ainda guardaremos os valores absolutos de r0 e r1 em r3, r4
    ; verificamos se r0 é zero
    cmp r0, #0
    ; retornamos se r0 for igual a zero
    moveq pc, lr
    ; analisamos caso
    movlt r2, #-1
    movgt r2, #1
    ; guardamos valor absoluto em r3 (r3 = #0 - r0)
    rsblt r3, r0, #0
    movgt r3, r0
    ; verificamos se r1 é zero
    cmp r1, #0
    ; se for igual, colocamos 0 em r0 e retornamos
    moveq r0, #0
    moveq pc, lr
    ; analisamos caso
    addlt r2, r2, #-1
    addgt r2, r2, #1
    ; analogamente, colocamos em r4 o valor abs. de r1
    rsblt r4, r1, #0
    movgt r4, r1
    ; vemos quem é o menor e o maior
    cmp r3, r4
    ; deixamos o menor em r4, maior em r3
    movlt r5, r3
    movlt r3, r4
    movlt r4, r5
    ; colocamos o maior em r5 para ser somado
    mov r5, r3
    ; se r3 > r4, estamos prontos
    ; agora fazemos a multiplicação de fato
    _laco_multiplicacao:
        cmp r4, #1
        ble _fim_multiplicacao
        add r3, r3, r5
        sub r4, r4, #1
        b _laco_multiplicacao
    _fim_multiplicacao:
    ; agora que acabamos de multiplicar, retornamos para r0 com sinal corrigido
    ; vemos o sinal que devemos ter através de r2, apenas se r2 == 0 precisamos
    ; colocar o sinal negativo
    cmp r2, #0
    ; colocamos em r0 -r3
    srbeq r0, r3, #0
    ; se não é igual a zero, só movemos
    movne r0, r3
    ; retornamos
    mov pc, lr

