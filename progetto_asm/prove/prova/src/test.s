.section .data
path_prefix: .asciz "/nome/"  # Prefisso della stringa
newline: .asciz "\n"          # Nuova riga

.section .bss
.lcomm full_path, 256         # Buffer per contenere la stringa finale

.section .text
.global _start

_start:
    # Carica il puntatore a `argv[1]` (primo parametro) in %ebx
    # addl $4, %esp
    # mov %esp, %ebx         # argv[1] è a 8 byte da ESP
    popl %ebx
    popl %ebx
    movl (%ebx), %eax

    # Copia il prefisso "/nome/" nel buffer
    mov $path_prefix, %esi    # src: path_prefix
    mov $full_path, %edi      # dest: full_path
    call strcpy               # Copia il prefisso nel buffer

    # Concatenare il parametro
    mov %ebx, %esi            # src: puntatore a argv[1]
    call strcat               # Concatenare il parametro al buffer

    # (DEBUG) Stampa il contenuto del buffer full_path
    mov $4, %eax              # syscall: sys_write
    mov $1, %ebx              # file descriptor: stdout
    mov $full_path, %ecx      # buffer: contenuto di full_path
    call strlen               # Calcola la lunghezza della stringa
    mov %eax, %edx            # size: lunghezza della stringa
    int $0x80                 # chiamata di sistema

    # Terminazione del programma
    mov $1, %eax              # syscall: sys_exit
    xor %ebx, %ebx            # codice di uscita 0
    int $0x80                 # chiamata di sistema

# Funzione strcpy per copiare la stringa
.type strcpy, @function
strcpy:
    .copy_loop:
        lodsb                # Carica un byte da [esi] a al, incrementa esi
        stosb                # Salva al in [edi], incrementa edi
        testb %al, %al       # Test se il byte è nullo
        jnz .copy_loop       # Ripeti finché non si trova il terminatore nullo
    ret

# Funzione strcat per concatenare la stringa
.type strcat, @function
strcat:
    # Trova la fine della stringa nel buffer di destinazione
    mov $full_path, %edi     # dest: full_path
    .find_end:
        lodsb                # Carica un byte da [esi] a al, incrementa esi
        testb %al, %al       # Test se il byte è nullo
        jnz .find_end        # Ripeti finché non si trova il terminatore nullo
    dec %esi                 # Torna indietro di un byte (terminatore nullo)

    # Concatenare la stringa
    .concat_loop:
        lodsb                # Carica un byte da [esi] a al, incrementa esi
        stosb                # Salva al in [edi], incrementa edi
        testb %al, %al       # Test se il byte è nullo
        jnz .concat_loop     # Ripeti finché non si trova il terminatore nullo
    ret

.type strlen, @function
strlen:
    xor %eax, %eax                # Lunghezza iniziale = 0
    mov %ecx, %esi                # src: puntatore alla stringa
.length_loop:
    lodsb                         # Carica un byte da [esi] a al, incrementa esi
    testb %al, %al                # Test se il byte è nullo
    jz .done                      # Se il byte è nullo, esci dal loop
    inc %eax                      # Incrementa la lunghezza
    jmp .length_loop              # Ripeti il loop
.done:
    ret
