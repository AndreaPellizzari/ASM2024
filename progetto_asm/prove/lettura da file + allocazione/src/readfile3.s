.section .data
filename:
    .ascii "input.txt"    # Nome del file di testo da leggere

# path:
    # .ascii "/file/"
fd:
    .int 0               # File descriptor

buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee
temp: .int 0             # variabile temporanea multiuso
i: .int 0                # indice struct

struct_size: .long 16     # dimensione totale della struttura (4 interi)
struct_item_size: .long 4
array_size: .long 10      # dimensione iniziale dell'array

.section .bss
.align 4
array_ptr:
    .space 160          # Riserva 256 byte per il buffer

.section .text
    .globl _start

# Apre il file
_open:
    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit
    mov %eax, fd      # Salva il file descriptor in ebx

# Legge il file riga per riga
_read_loop:
    # lettura
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor
    mov $buffer, %ecx   # Buffer di input
    mov $1, %edx        # Lunghezza massima
    int $0x80        

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _close_file     # Se ci sono errori o EOF, chiudo il file
    
    # Controllo se ho una nuova linea
    movb buffer, %al    # copio il carattere dal buffer ad AL
    cmpb newline, %al   # confronto AL con il carattere \n
    jne _save_line     # se sono diversi stampo la linea
    incw lines          # altrimenti, incremento il contatore

    # salvo in memoria, vale per il parametro 4
    leal array_ptr, %edi                # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl lines, %ecx                    # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull struct_size, %ecx            # Calcola l'offset (dimensione di ogni struttura * indice)
    movl i, %ebx                        # Carica l'elemento dello struct
    imull struct_item_size, %ebx       # Calcola l'elemento dello struct a cui si desidera accedere
    addl %ebx, %ecx                     # Aggiunge all'offset iniziale
    addl %ecx, %edi                     # Aggunge l'offeset all'indirizzo del valore in memoria da accedere
    leal (%edi, %ecx), %edi             # Calcola l'indirizzo corrente dell'array di strutture
    movl temp, %ebx
    movl %ebx, (%edi)                   # Salva il valore temporaneo nella posizione corrente dell'array

    movl $0, temp
    movl $0, i             # resetto la i

    jmp _read_loop


_save_line:
    # conversione
    movb buffer, %bl

    # se trova la virgola
    cmp $44, %bl
    je _virgola_trovata
    movl temp, %eax
    # oppure converto il char
    subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
    movl $10, %edx
    mulb %dl                # EBX = EBX * 10
    addl %ebx, %eax
    movl %eax, temp
    call itoa

    jmp _read_loop      # Torna alla lettura del file

_virgola_trovata:
    # salvo in memoria, vale per i parametri 1,2,3
    leal array_ptr, %edi                # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl lines, %ecx                    # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull struct_size, %ecx            # Calcola l'offset (dimensione di ogni struttura * indice)
    movl i, %ebx                        # Carica l'elemento dello struct
    imull struct_item_size, %ebx       # Calcola l'elemento dello struct a cui si desidera accedere
    addl %ebx, %ecx                     # Aggiunge all'offset iniziale
    addl %ecx, %edi                     # Aggunge l'offeset all'indirizzo del valore in memoria da accedere
    leal (%edi, %ecx), %edi             # Calcola l'indirizzo corrente dell'array di strutture
    movl temp, %ebx
    movl %ebx, (%edi)                   # Salva il valore temporaneo nella posizione corrente dell'array

    incw i                              # incremento la i, infatti vorrò andare a puntare al prossimo elemento
    movl $0, temp
    
    jmp _read_loop

.type concatena, @function
concatena:
    movl $0, i
    movl temp, %esi

    _ripeti:



# Chiude il file
_close_file:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_start:

    # prendo il parametro il parametro del file di lettura:
#    popl %ecx
#    popl %ecx
#    popl %ecx
#    movl %ecx, temp
#    call concatena

    jmp _open               # Chiama la funzione per aprire il file

    # Fine programma
    jmp _exit
