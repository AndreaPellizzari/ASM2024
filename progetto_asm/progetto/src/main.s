.section .data
    stringainizio: .ascii "Scegli che algoritmo utilizzare:\n ➢ 1 = EDF;\n ➢ 2 = HDF;\n ➢ 3 = uscita\nInserisci valore: "
    stringainiziolenght: .long . - stringainizio
    
    stringaerrore: .ascii "\n\nInserisci valore valido!\n\n"
    stringaerrorelenght: .long . - stringaerrore

.section .bss
    scelta: .space 2 

.section .text
    .global _start

_start:

_loop_choose_algorith:
    # stampa a video della stringa di scelta
    movl $4, %eax                                                       # Uso la WRITE
    movl $2, %ebx                                                       # Stampo su stdout
    leal stringainizio, %ecx                                            # Carico l'indirizzo di stringainizio in EXC
    movl stringainiziolenght, %edx                                      # Carico la stringainiziolenght in EDX
    int $0x80                                                           # syscall

    # lettura da tastiera della scelta dell'algoritmo da parte dell'utente
    movl $3, %eax                                                       # syscall number for sys_read
    movl $0, %ebx                                                       # file descriptor 0 (stdin)
    movl $scelta, %ecx                                                  # buffer per salvare l'input
    movl $2, %edx                                                       # massimo numero di byte da leggere
    int $0x80                                                           # syscall

    movb scelta, %bl
    cmp $'1', %bl
    je _edf_algorith
    cmp $'2', %bl
    je _hpf_algorith
    cmp $'3', %bl
    je _exit   

    # stampa a video della stringa di scelta
    movl $4, %eax                                                       # Uso la WRITE
    movl $2, %ebx                                                       # Stampo su stdout
    leal stringaerrore, %ecx                                            # Carico l'indirizzo di stringainizio in EXC
    movl stringaerrorelenght, %edx                                      # Carico la stringainiziolenght in EDX
    int $0x80                                                           # syscall

    jmp _loop_choose_algorith

_exit:
    movl $1, %eax                   # Systemcall EXIT
    movl $0, %ebx                   # codice di uscita 0
    int $0x80

_edf_algorith:
    call edf

    jmp _loop_choose_algorith

_hpf_algorith:
    call hpf
    jmp _loop_choose_algorith

