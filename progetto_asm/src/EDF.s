.section .data

scelta: .ascii "Hai scelto l'algoritmo EDF:\n\n"
sceltalenght: .long . - scelta

.section .text
	.global edf

.type edf, @function
edf:
    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta, %ecx        # | <- destination
	movl sceltalenght, %edx        # | <- length
	int $0x80             # Execute syscall

    ret
	