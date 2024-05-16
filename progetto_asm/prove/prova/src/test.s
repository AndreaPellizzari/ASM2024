.section .data
path:      .string "/Ordini/"
filename:  .string "input.txt"

.section .bss
path_input: .space 35  # Spazio per la stringa concatenata

.section .text
.global _start

_start:
    # Copia 'path' in 'path_input'
    movl $path, %esi        # Puntatore alla stringa 'path'
    movl $path_input, %edi  # Puntatore alla destinazione 'path_input'

copy_path:
    movb (%esi), %al        # Carica un byte da (%esi) a %al
    movb %al, (%edi)        # Memorizza il byte in %al a (%edi)
    inc %esi                # Incrementa %esi per il prossimo byte
    inc %edi                # Incrementa %edi per il prossimo byte
    testb %al, %al          # Controlla se %al è zero (terminatore di stringa)
    jnz copy_path           # Se non è il terminatore, continua a copiare

    # Decrementa %edi per sovrascrivere il terminatore nullo
    dec %edi

    # Copia 'filename' in 'path_input' dopo 'path'
    movl $filename, %esi    # Puntatore alla stringa 'filename'

copy_filename:
    movb (%esi), %al        # Carica un byte da (%esi) a %al
    movb %al, (%edi)        # Memorizza il byte in %al a (%edi)
    inc %esi                # Incrementa %esi per il prossimo byte
    inc %edi                # Incrementa %edi per il prossimo byte
    testb %al, %al          # Controlla se %al è zero (terminatore di stringa)
    jnz copy_filename       # Se non è il terminatore, continua a copiare

    # Stampa la stringa concatenata
    movl $4, %eax           # Syscall numero per sys_write
    movl $1, %ebx           # File descriptor 1 (stdout)
    movl $path_input, %ecx  # Puntatore alla stringa da stampare
    movl $35, %edx          # Lunghezza massima della stringa
    int $0x80               # Interruzione del kernel

    # Termina il programma
    movl $1, %eax           # Syscall numero per sys_exit
    xorl %ebx, %ebx         # Stato di uscita
    int $0x80               # Interruzione del kernel
