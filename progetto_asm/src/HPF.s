.section .data

scelta3: .ascii "Hai scelto l'algoritmo HPF:\n\n"
scelta3lenght: .long . - scelta3

.section .text
	.global hpf

.type hpf, @function
hpf:
    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta3, %ecx        # | <- destination
	movl scelta3lenght, %edx        # | <- length
	int $0x80             # Execute syscall

    ret
	