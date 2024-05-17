.section .data
fd: .long 0                                                             # File descriptor

buffer: .string ""                                                      # Spazio per il buffer di input
newline: .byte 10                                                       # Valore del simbolo di nuova linea
lines: .long 0                                                          # Numero di linee
temp: .long 0                                                           # variabile temporanea multiuso
i: .long 0                                                              # indice struct

array_ptr: .long 0                                                      # puntatore alla struttura di memoria
struct_size: .long 16                                                   # dimensione totale della struttura (4 interi)
struct_item_size: .long 4                                               # dimensione della singola cella di array
array_size: .long 10                                                    # dimensione iniziale dell'array

.section .text
    .global _save_data

.type _save_data, @function
_save_data:

    # conto quante linee ci sono all'interno del file di input
    call _countline

    # alloco la giusta quantità di memoria nell'heap
    # calcolo la memoria necessaria da allocare dinamicamente (EBX RISULTATO)
    movl lines, %eax
    movl %eax, array_size
    imul struct_size, %ebx

        # Ottieni l'attuale break
    mov $45, %eax          # Syscall 45: brk
    xor %ebx, %ebx         # Passa 0 per ottenere l'attuale break
    int $0x80              # Effettua la syscall
    mov %eax, %esi         # Salva l'attuale break in %esi

    # Imposta il nuovo break
    add %ebx, %esi         # Aggiungi la dimensione della memoria da allocare al break attuale
    mov $45, %eax          # Syscall 45: brk
    mov %esi, %ebx         # Passa il nuovo break come argomento
    int $0x80              # Effettua la syscall

    # Controlla se la syscall ha successo
    cmp %esi, %eax
    jne _exit           # Se fallisce, esci con errore

    # Controlla se la syscall ha successo
    cmp %esi, %eax
    jne _exit        # Se fallisce, esci con errore

    movl $0, lines








# ------------------------------------------------------------------------
# apertura del file in modalità di lettura
.type, _openfile, @function
_openfile:
    movl $5, %eax                    # syscall open
    movl $path_input, %ebx           # Nome del file
    movl $0, %ecx                    # Modalità di apertura (O_RDONLY)
    int $0x80                       # Interruzione del kernelp

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _exit
    movl %eax, fd      # Salva il file descriptor in ebx

    ret

# ------------------------------------------------------------------------
# conteggio del numero di linee, utile per capire quanta memoria allocare
.type _countline, @function
_countline:
    call _openfile

loop:
    movl $3, %eax        # syscall read
    movl fd, %ebx        # File descriptor
    movl $buffer, %ecx   # Buffer di input
    movl $1, %edx        # Lunghezza massima
    int $0x80        

    cmpl $0, %eax        # Controllo se ci sono errori o EOF
    jle close_file     # Se ci sono errori o EOF, chiudo il file
    
    # Controllo se ho una nuova linea
    movb buffer, %al    # copio il carattere dal buffer ad AL
    cmpb newline, %al   # confronto AL con il carattere \n
    jne loop     # se sono diversi vado aumento il parametro
    incw lines          # altrimenti, incremento il contatore
    jmp loop

close_file:
    movl $6, %eax        # syscall close
    movl %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel
    ret
