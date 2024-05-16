.data
array:
    .int 9, 5, 7, 2, 6, 1, 8, 3, 4   # Array da ordinare
array_len = (. - array) / 4          # Lunghezza dell'array

.text
.global _start

_start:
    mov $0, %ecx            # Inizializza il contatore esterno (indice i)
    jmp inner_loop

outer_loop:
    cmp $array_len, %ecx   # Controlla se abbiamo raggiunto la fine dell'array
    jge end_sort           # Se sì, termina il loop esterno

    mov %ecx, %esi         # Copia l'indice i (esterno) in ESI

    mov %ecx, %ebx         # Inizializza l'indice minimo con l'indice corrente
    movl array(%ecx), %eax # Carica il valore corrente come minimo

    jmp inner_loop

inner_loop:
    inc %esi              # Incrementa l'indice interno (indice j)
    
    cmp $array_len, %esi        # Controlla se abbiamo raggiunto la fine dell'array
    je end_sort                 # Se sì, termina il loop interno

    movl array(%esi), %edx      # Carica il valore corrente nell'array

    cmpl %edx, %eax             # Confronta il valore corrente con il minimo
    jge inner_loop              # Se il valore corrente non è minore, salta lo scambio

    mov %edx, %eax              # Aggiorna il valore minimo
    mov %esi, %ebx              # Aggiorna l'indice del valore minimo

    jmp swap

no_swap:
    jmp inner_loop              # Ripete il loop interno

swap:
    movl array(%ecx), %edx      # Carica il valore corrente nell'array
    movl array(%ebx), %eax      # Carica il valore minimo
    mov %eax, array(%ecx)       # Effettua lo scambio
    mov %edx, array(%ebx)

    inc %ecx                    # Passa all'elemento successivo nell'array
    jmp outer_loop              # Ripete il loop esterno

end_sort:
    # Fine dell'ordinamento
    # Qui puoi inserire il codice per stampare l'array ordinato o fare altre operazioni

    # Termina il programma
    mov $1, %eax        # syscall number for exit
    xor %ebx, %ebx      # exit code 0
    int $0x80           # Chiamata al kernel
