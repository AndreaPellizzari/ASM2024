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
array_size: .long 0                                                     # dimensione iniziale dell'array

error_file2: .ascii "❌ Errore - File inesistente ❌ \n"
error_file_lenght2: .long . - error_file2

.section .bss
    path_input: .space 35                                                   # path del file di input

.section .text
    .global _save_data

.type _save_data, @function
_save_data:
    movl %eax, %ebx
    movl %ebx, path_input
    movl $0, lines
    # conto quante linee ci sono all'interno del file di input
    call _countline

    # alloco la giusta quantità di memoria nell'heap
    # calcolo la memoria necessaria da allocare dinamicamente (EBX RISULTATO)
    movl lines, %eax
    imul struct_size, %eax
    movl %eax, array_size

    # Ottieni l'attuale break
    movl $45, %eax                         # Syscall 45: brk
    xorl %ebx, %ebx                        # Passa 0 per ottenere l'attuale break
    int $0x80                              # Effettua la syscall
    movl %eax, %esi                        # Salva l'attuale break in %esi

    # Imposta il nuovo break
    addl array_size, %esi                  # Aggiungi la dimensione della memoria da allocare al break attuale
    movl $45, %eax                         # Syscall 45: brk
    movl %esi, %ebx                        # Passa il nuovo break
    int $0x80                              # Effettua la syscall

    testl %eax, %eax                       # Controlla se il valore richiesto e quello ottenuto sono uguali
    jl _exit_error                         # Se fallisce, esci con errore

    mov %eax, array_ptr


    movl $0, lines
# Apre il file
_open:
    movl $5, %eax                    # syscall open
    movl path_input, %ebx           # Nome del file
    movl $0, %ecx                    # Modalità di apertura (O_RDONLY)
    int $0x80                       # Interruzione del kernelp

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _error_file

    movl %eax, fd      # Salva il file descriptor in ebx

# Legge il file riga per riga
_read_loop:
    # lettura
    movl $3, %eax        # syscall read
    movl fd, %ebx        # File descriptor
    movl $buffer, %ecx   # Buffer di input
    movl $1, %edx        # Lunghezza massima
    int $0x80        

    cmpl $0, %eax        # Controllo se ci sono errori o EOF
    jle _close_file     # Se ci sono errori o EOF, chiudo il file
    
    # Controllo se ho una nuova linea
    movb buffer, %al    # copio il carattere dal buffer ad AL
    cmpb newline, %al   # confronto AL con il carattere \n
    jne _save_line     # se sono diversi stampo la linea

    # salvo in memoria, vale per il parametro 4
    movl array_ptr, %edi                # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl lines, %ecx                    # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull struct_size, %ecx            # Calcola l'offset (dimensione di ogni struttura * numero righe)
    movl i, %ebx                        # Carica l'elemento dello struct
    imull struct_item_size, %ebx       # Calcola l'elemento dello struct a cui si desidera accedere
    addl %ebx, %ecx                     # Aggiunge all'offset iniziale
    addl %ecx, %edi                     # Aggunge l'offeset all'indirizzo del valore in memoria da accedere
    movl temp, %ebx
    movl %ebx, (%edi)
    movl (%edi), %eax

    incw lines          # altrimenti, incremento il contatore
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


    jmp _read_loop      # Torna alla lettura del file

_virgola_trovata:
    # salvo in memoria, vale per i parametri 1,2,3
    movl array_ptr, %edi                # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl lines, %ecx                    # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull struct_size, %ecx            # Calcola l'offset (dimensione di ogni struttura * numero righe)
    movl i, %ebx                        # Carica l'elemento dello struct
    imull struct_item_size, %ebx       # Calcola l'elemento dello struct a cui si desidera accedere
    addl %ebx, %ecx                     # Aggiunge all'offset iniziale
    addl %ecx, %edi                     # Aggunge l'offeset all'indirizzo del valore in memoria da accedere
    movl temp, %ebx
    movl %ebx, (%edi)
    movl (%edi), %eax

    incw i                              # incremento la i, infatti vorrò andare a puntare al prossimo elemento
    movl $0, temp
    
    jmp _read_loop


# Chiude il file
_close_file:
    movl array_ptr, %edi                # Carica l'indirizzo di memoria dell'array di strutture in EDI
    movl lines, %ecx                    # Carica il numero corrente di linee lette in ECX (indice dell'array)
    imull struct_size, %ecx            # Calcola l'offset (dimensione di ogni struttura * numero righe)
    movl i, %ebx                        # Carica l'elemento dello struct
    imull struct_item_size, %ebx       # Calcola l'elemento dello struct a cui si desidera accedere
    addl %ebx, %ecx                     # Aggiunge all'offset iniziale
    addl %ecx, %edi                     # Aggunge l'offeset all'indirizzo del valore in memoria da accedere
    movl temp, %ebx
    movl %ebx, (%edi)

    mov $6, %eax        # syscall close
    mov fd, %ebx        # File descriptor
    int $0x80           # Interruzione del kernel

    # sposto il puntatore array_ptr in eax
    movl array_ptr, %eax
    movl array_size, %ebx
    ret

_exit:
    movl $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_exit_error:
    movl $1, %eax        # syscall exit
    movl $1, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_error_file:
    movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal error_file2, %ecx        		# | <- destination
	movl error_file_lenght2, %edx        # | <- length
	int $0x80             			# Execute syscall

    jmp _exit_error

# ------------------------------------------------------------------------
# apertura del file in modalità di lettura
.type openfile, @function
openfile:
    movl $5, %eax                    # syscall open
    movl path_input, %ebx           # Nome del file
    movl $0, %ecx                    # Modalità di apertura (O_RDONLY)
    int $0x80                       # Interruzione del kernelp

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _exit
    movl %eax, fd      # Salva il file descriptor in ebx

    ret

# ------------------------------------------------------------------------
# restituisce quante righe ci sono dentro il file di input
.type _countline, @function
_countline:
_opencountfile:
    movl $5, %eax        # syscall open
    movl path_input, %ebx # Nome del file
    movl $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmpl $0, %eax
    jl _error_file
    movl %eax, fd      # Salva il file descriptor in ebx

readcount_loop:
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
    jne readcount_loop     # se sono diversi vado aumento il parametro
    incw lines          # altrimenti, incremento il contatore
    jmp readcount_loop

close_file:
    mov $6, %eax        # syscall close
    mov fd, %ebx        # File descriptor
    int $0x80           # Interruzione del kernel
    ret

