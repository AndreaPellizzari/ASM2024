.section .data
    stringainizio:
        .ascii "Scegli che algoritmo utilizzare: 1 = EDF; 2 = HDF\n"

    stringainiziolenght:
        .long . - stringainizio

    uno:
        .int 1

    due:
        .int 2

.section .bss
    scelta:
        .int                     # scelta dell'utente che farà

.section .text
    .global _start

_start:
    jmp _ripeti

_ripeti:
    # stampa a video
    movl $4, %eax                            # Uso la WRITE
    movl $2, %ebx                            # Stampo su stdout
    leal stringainizio, %ecx                 # Carico l'indirizzo di stringainizio in EXC
    movl stringainiziolenght, %edx           # Carico la stringainiziolenght in EDX
    int $0x80

    # lettura da tastiera, scelta dell'algoritmo
    movl $3, %eax         # Set system call READ
	movl $0, %ebx         # | <- keyboard
	leal scelta, %ecx        # | <- destination             (qui abbiamo il risultato preso da tastiera)
	movl $1, %edx        # | <- string length
	int $0x80             # Execute syscall

    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta, %ecx        # | <- destination
	movl $1, %edx        # | <- length
    int $0x80 

    # confronto per scegliere il tipo di algoritmo
    movl (%ecx), %eax
    # movl $uno, %ebxsyscall brk
    # mov (%eax), %eax
    # call itoa
    cmpl $1, %eax
    je EDF
    
    movl $due, %ebx
    cmpl %eax, %ebx
    je HPF

    jump _ripeti

fine:
    movl $1, %eax                   # Systemcall EXIT
    movl $0, %ebx                   # codice di uscita 0
    int $0x80

.type EDF, @function
EDF:
    call edf

    jmp fine

.type HPF, @function
HPF:
    call hpf
    jmp fine

