.section .data
    stringainizio:
        .ascii "Scegli che algoritmo utilizzare: 1 = EBF; 2 = HDF\n"

    stringainiziolenght:
        .long . - stringainizio

    scelta:
        .long 0                     # scelta dell'utente che farà
.section .text
    .global _start

_start:
    jmp _ripeti

_ripeti:
    # stampa a video
    movl $4, %eax                            # Uso la WRITE
    movl $1, %ebx                            # Stampo su stdout
    leal stringainizio, %ecx                 # Carico l'indirizzo di stringainizio in EXC
    movl stringainiziolenght, %edx           # Carico la stringainiziolenght in EDX

    int $0x80

    # lettura da tastiera, scelta dell'algoritmo
    movl $3, %eax         # Set system call READ
	movl $0, %ebx         # | <- keyboard
	leal scelta, %ecx        # | <- destination             (qui abbiamo il risultato preso da tastiera)
	movl $3, %edx        # | <- string length
	int $0x80             # Execute syscall


    movl scelta, %eax
    movl (%eax), %eax
    cmpl $1, scelta
    je EDF

    cmpl $2, %eax
    je HPF

    jmp _ripeti


EDF:
    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta, %ecx        # | <- destination
	movl $2, %edx        # | <- length
    int $0x80 
    call edf
    jmp _ripeti


HPF:
    call hpf
    jmp _ripeti

    movl $1, %eax                   # Systemcall EXIT
    movl $0, %ebx                   # codice di uscita 0
    int $0x80