.section .data
filename:
    .ascii "input.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor

buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee
temp: .int 0
i: .int 0

struct_size: .long 16     # dimensione totale della struttura (4 interi)
array_size: .long 10      # dimensione iniziale dell'array
array_ptr: .long 0        # puntatore all'array di strutture

.section .bss

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
    jne _print_line     # se sono diversi stampo la linea
    incw lines          # altrimenti, incremento il contatore
    incw i
    # rimane da aggiungere
    movl $0, temp


_print_line:

#    mov $4, %eax        # syscall write
#    mov $1, %ebx        # File descriptor standard output (stdout)
#    mov $buffer, %ecx push temp  # Buffer di output
#    int $0x80

    movb buffer, %bl

    cmp $44, %bl
    je _virgola_trovata

    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $buffer, %ecx   # Buffer di output
    int $0x80           # addl $4, imovl temp, (%edi)
    mulb %dl                # EBX = EBX * 10
    addl %ebx, %eax
    movl %eax, temp

    // in temp abbiamo i valori senza virgola

    jmp _read_loop      # Torna alla lettura del file

_virgola_trovata:
    movl array_ptr, %edi         # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl i, %ecx             # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull $struct_size, %ecx     # Calcola l'offset (dimensione di ogni struttura * indice)
    leal (%edi, %ecx), %edi      # Calcola l'indirizzo corrente dell'array di strutture
    movl temp, (%edi)            # Salva il valore temporaneo nella posizione corrente dell'array
    incw i

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
    # Calcola la dimensione totale dell'array
    mov $struct_size, %eax       # car    movl array_ptr, iica la dimensione totale della struttura in eax
    imul array_size, %eax        # moltiplica per il numero di strutture nell'array
    mov %eax, %ebx               # salva il risultato in ebx
    
    # Alloca memoria per l'array di strutture
    mov $0, %edi            # EDI = NULL
    mov %ebx, %ebx          # EBX = dimensione totale dell'array
    mov $12, %eax            # syscall brk (numero 4)
    int $0x80               # Interruzione del kernel
    
    # Controlla se c'è stato un errore durante l'allocazione di memoria
    cmp $-1, %eax
    je _exit                # Se c'è stato un errore, esce
    
    mov %eax, array_ptr     # Salva il puntatore all'array

    jmp _open          # Chiama la funzione per aprire il file

    # Fine programma
    jmp _exit
