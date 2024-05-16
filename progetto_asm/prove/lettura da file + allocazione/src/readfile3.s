.section .data
filename: .string ""    # Nome del file di testo da leggere

path: .string "...../Ordini/"

fd:
    .int 0               # File descriptor

buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee
temp: .int 0             # variabile temporanea multiuso
i: .int 0                # indice struct
array_ptr: .int 0

struct_size: .long 16     # dimensione totale della struttura (4 interi)
struct_item_size: .long 4
array_size: .long 10      # dimensione iniziale dell'array

.section .bss
.align 4
path_input: .space 35
path_output: .space 35

.section .text
    .globl _start

# Apre il file
_open:
    mov $5, %eax                    # syscall open
    mov path_input, %ebx           # Nome del file
    mov $0, %ecx                    # Modalità di apertura (O_RDONLY)
    int $0x80                       # Interruzione del kernelp

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

# Salvo parametro numero 1
_parametro_1:               # prendo il parametro il parametro del file di lettura:
    popl %ecx
    popl %ecx
    # salvo il primo parametro
    popl %ecx
    call _saveparam         # in ecx ho il risultato e edx la lunghezza
    movl %ecx, filename

    # concatena il file con la path
    call concatena_input

    # conta numero righe file
    call _countline

    # calcolo la memoria necessaria da allocare dinamicamente (EAX RISULTATO)
    movl lines, %eax
    movl %eax, array_size
    imul struct_size, %ebx

    # allocamento con syscall brk
    movl $45, %eax
    # in ebx ho la quantità di memoria
    movl %eax, array_ptr

    # lettura da file + salva nella memoria dinamica
    jmp _open               # Chiama la funzione per aprire il file


    # Fine programma
    jmp _exit


# ---------------------------------------------------
# funzione di concatenazione tra path e filename (input)
.type concatena_input, @function
concatena_input:
    # Copia 'path' in 'path_input'
    movl $path, %esi        # Puntatore alla stringa 'path'
    movl $path_input, %edi  # Puntatore alla destinazione 'path_input'
    add $3, %esi

copy_path:
    movb (%esi), %al        # Carica un byte da (%esi) a %al
    movb %al, (%edi)        # Memorizza il byte da %al a (%edi)
    inc %esi                # Incrementa %esi per il prossimo byte
    inc %edi                # Incrementa %edi per il prossimo byte
    testb %al, %al          # Controlla se %al è zero (terminatore di stringa)
    jnz copy_path           # Se non è il terminatore, continua a copiare

    # Decrementa %edi per sovrascrivere il terminatore nullo
    dec %edi

    # Copia 'filename' in 'path_input' dopo 'path'
    movl filename, %esi    # Puntatore alla stringa 'filename'

copy_filename:
    movb (%esi), %al        # Carica un byte da (%esi) a %al
    movb %al, (%edi)        # Memorizza il byte in %al a (%edi)
    inc %esi                # Incrementa %esi per il prossimo byte
    inc %edi                # Incrementa %edi per il prossimo byte
    testb %al, %al          # Controlla se %al è zero (terminatore di stringa)
    jnz copy_filename       # Se non è il terminatore, continua a copiare

    movl $4, %eax           # Syscall numero per sys_write
    movl $1, %ebx           # File descriptor 1 (stdout)
    movl $path_input, %ecx  # Puntatore alla stringa da stampare
    movl $35, %edx          # Lunghezza massima della stringa
    int $0x80               # Interruzione del kernel

    ret

# ---------------------------------
# restituisce quante righe ci sono dentro il file di input
.type _countline, @function
_countline:
_opencountfile:
    mov $5, %eax        # syscall open
    mov filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit
    mov %eax, fd      # Salva il file descriptor in ebx

readcount_loop:
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor
    mov $buffer, %ecx   # Buffer di input
    mov $1, %edx        # Lunghezza massima
    int $0x80        

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle close_file     # Se ci sono errori o EOF, chiudo il file
    
    # Controllo se ho una nuova linea
    movb buffer, %al    # copio il carattere dal buffer ad AL
    cmpb newline, %al   # confronto AL con il carattere \n
    jne readcount_loop     # se sono diversi vado aumento il parametro
    incw lines          # altrimenti, incremento il contatore
    jmp readcount_loop

close_file:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel
    ret
