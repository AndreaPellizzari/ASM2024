.section .data

scelta2: .ascii "\n✅ Hai scelto l'algoritmo EDF ✅\n\n"
scelta2lenght: .long . - scelta2

.section .text
	.global edf

.type edf, @function
edf:
    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta2, %ecx        # | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             # Execute syscall

    ret
	