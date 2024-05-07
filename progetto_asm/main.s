.section .data
    stringainizio:
        .ascii "Scegli che algoritmo utilizzare: 1 = EBF; 2 = HDF"

    stringainiziolenght:
        .long . - stringainizio

    scelta:
        .long 0                     # scelta dell'utente che farà
.section .text
    .global _start

_start:
    # stampa a video
    movl $4, %eax                   # Uso la WRITE
    movl $1, %ebx                   # Stampo su stdout
    leal stringainizio, %ecx        # Carico l'indirizzo di stringainizio in EXC
    movl stringainiziolenght, %edx           # Carico la stringainiziolenght in EDX

    int $0x80




    movl $1, %eax                   # Systemcall EXIT
    movl $0, %ebx                   # codice di uscita 0
    int $0x80