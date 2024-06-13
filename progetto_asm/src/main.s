.section .data
    stringainizio: .ascii "\n\nScegli che algoritmo utilizzare:\n ➢ 1 = EDF;\n ➢ 2 = HDF;\n ➢ 3 = uscita\nInserisci valore: "
    stringainiziolenght: .long . - stringainizio
    
    stringaerrore: .ascii "\n\n❌ Inserisci valore valido! ❌\n\n"
    stringaerrorelenght: .long . - stringaerrore

    stringwrite: .ascii "stampa avvenuta con successo!"
    stringwritelgth: .long . - stringwrite

    error_input: .ascii "❌ Errore - Inserire il file input come parametro ❌ \n"
    error_input_lenght: .long . - error_input

    error_file: .ascii "❌ Errore - file di scrittura ❌ \n"
    error_file_lenght: .long . - error_file

    path: .string "./Ordini/"
    sceltascrittura: .int 0

    array_ptr: .long 0
    array_size: .long 0
    i: .long 0

    fd1: .long 0                                                             # file descriptor

.section .bss
    scelta: .space 2 
    filename: .space 20
    path_input: .space 35                                                   # path del file di input

.section .text
    .global _start

_save_second_param:
    movl $1, sceltascrittura                                                # imposto che vorrò scrivere su file
    movl %ecx, filename
    # apro il file in scrittura
    movl $5, %eax                                                           # syscall open
    movl (filename), %ebx                                                   # Nome del file
    movl $0x242, %ecx                                                       # Modalità di apertura (O_CREAT | O_WRONLY)
    movl $0x1A4, %edx                                                       # Permessi del file (0644 in ottale)
    int $0x80                                                               # Interruzione del kernel

    # Se c'è un errore, esce
    cmpl $0, %eax
    jle _error_file
    movl %eax, fd1                                                          # Salva il file descriptor in ebx

    jmp salva_dati

_start:

_save_param:
    popl %ecx                                                               # contiene il numero di paramentri, che dovranno essere minimo 1 e massimo 2
    popl %ecx                                                               # contiene il nome della funzione
    popl %ecx                                                               # prendo il parametro che mi interessa
    cmpl $0, %ecx
    je _error_param
    call _saveparam                                                         # in ecx ho il risultato e edx la lunghezza
    movl %ecx, filename                                                     # sposto il parametro in filename
    call concatena_input                                                    # richiamo al funzione di concatenzione con file_input
    popl %ecx                                                               # prendo il prossimo parametro
    cmpl $0, %ecx                                                           # controllo che non sia nullo, in tal caso non faccio nulla
    jne _save_second_param                                                  # se sono diversi, salvo il secondo parametro

salva_dati:
    movl $path_input, %eax                                                  # Mi passo il l'indirizzo di path_input
    call _save_data                                                         # salvataggio dei dati in uno spazio di memoria dinamica, ricevo l'indirizzo in EAX
    movl %eax, array_ptr                                                    # Carica il contenuto di memoria all'indirizzo puntato da eax in edx
    movl %ebx, array_size

    # inizializzo le variabili per la stampa
    movl $0, i
    movl array_ptr, %edi


stampa_dati:
    movl array_size, %ecx
    cmp i, %ecx
    jle _loop_choose_algorith
    movl (%edi), %eax
    addl $4, %edi 
    addl $4, i
    jmp stampa_dati


_loop_choose_algorith:
    # stampa a video della stringa di scelta
    movl $4, %eax                                                           # Uso la WRITE
    movl $2, %ebx                                                           # Stampo su stdout
    leal stringainizio, %ecx                                                # Carico l'indirizzo di stringainizio in EXC
    movl stringainiziolenght, %edx                                          # Carico la stringainiziolenght in EDX
    int $0x80                                                               # syscall

    # lettura da tastiera della scelta dell'algoritmo da parte dell'utente
    movl $3, %eax                                                           # syscall number for sys_read
    movl $0, %ebx                                                           # file descriptor 0 (stdin)
    movl $scelta, %ecx                                                      # buffer per salvare l'input                                                        # syscall
    int $0x80
    
    movb scelta, %bl
    cmp $'1', %bl
    je _edf_algorith
    cmp $'2', %bl
    je _hpf_algorith
    cmp $'3', %bl
    je _exit   

    # stampa a video della stringa di scelta
    movl $4, %eax                                                           # Uso la WRITE
    movl $2, %ebx                                                           # Stampo su stdout
    leal stringaerrore, %ecx                                                # Carico l'indirizzo di stringainizio in EXC
    movl stringaerrorelenght, %edx                                          # Carico la stringainiziolenght in EDX
    int $0x80                                                               # syscall

    jmp _loop_choose_algorith

_exit:
    # CHIUSURA FILE
    movl $6, %eax                                                           # syscall close
    movl fd1, %ecx                                                          # File descriptor
    int $0x80                                                               # Interruzione del kernel

    movl $1, %eax                                                           # Systemcall EXIT
    movl $0, %ebx                                                           # codice di uscita 0
    int $0x80

_exit_error:
    movl $1, %eax                                                           # Systemcall EXIT
    movl $1, %ebx                                                           # codice di uscita 0
    int $0x80


_edf_algorith:
    movl array_ptr, %eax
    movl array_size, %ebx
    movl sceltascrittura, %ecx
    movl fd1, %edx

    call edf

    jmp _loop_choose_algorith


_hpf_algorith:
    movl array_ptr, %eax
    movl array_size, %ebx
    movl sceltascrittura, %ecx
    movl fd1, %edx

    call hpf
    
    jmp _loop_choose_algorith

_error_param:
    movl $4, %eax	        		                                    # Set system call WRITE
	movl $1, %ebx	        		                                    # | <- standard output (video)
	leal error_input, %ecx        		                                # | <- destination
	movl error_input_lenght, %edx                                       # | <- length
	int $0x80             			                                    # Execute syscall

    jmp _exit_error

_error_file:
    movl $4, %eax	        		                                    # Set system call WRITE
	movl $1, %ebx	        		                                    # | <- standard output (video)
	leal error_file, %ecx        		                                # | <- destination
	movl error_file_lenght, %edx                                        # | <- length
	int $0x80             			                                    # Execute syscall

    jmp _exit_error


# ---------------------------------------------------
# funzione di concatenazione tra path e filename (input)
.type concatena_input, @function
concatena_input:
    # Copia 'path' in 'path_input'
    movl $path, %esi                                                    # Puntatore alla stringa 'path'
    movl $path_input, %edi                                              # Puntatore alla destinazione 'path_input'

copy_path_input:
    movb (%esi), %al                                                    # Carica un byte da (%esi) a %al
    movb %al, (%edi)                                                    # Memorizza il byte da %al a (%edi)
    inc %esi                                                            # Incrementa %esi per il prossimo byte
    inc %edi                                                            # Incrementa %edi per il prossimo byte
    testb %al, %al                                                      # Controlla se %al è zero (terminatore di stringa)
    jnz copy_path_input                                                 # Se non è il terminatore, continua a copiare

    # Decrementa %edi per sovrascrivere il terminatore nullo
    dec %edi

    # Copia 'filename' in 'path_input' dopo 'path'
    movl filename, %esi                                                 # Puntatore alla stringa 'filename'

copy_filename_input:
    movb (%esi), %al                                                    # Carica un byte da (%esi) a %al
    movb %al, (%edi)                                                    # Memorizza il byte in %al a (%edi)
    inc %esi                                                            # Incrementa %esi per il prossimo byte
    inc %edi                                                            # Incrementa %edi per il prossimo byte
    testb %al, %al                                                      # Controlla se %al è zero (terminatore di stringa)
    jnz copy_filename_input                                             # Se non è il terminatore, continua a copiare

    ret