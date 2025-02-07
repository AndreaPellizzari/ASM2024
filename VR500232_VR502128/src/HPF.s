.section .data

scelta2: .ascii "\nPianificazione HPF:\n"
scelta2lenght: .long . - scelta2

ordinamento_e: .ascii "\n✅ Ordinamento per durata effettuato ✅\n\n"
ordinamento_e_lenght: .long . - ordinamento_e

separatore2: .ascii ":"
separatorelenght2: .long . - separatore2

conclusione: .ascii "Conclusione: "
conclusionelenght: .long . - conclusione

penalty: .ascii "\nPenalty: "
penaltylenght: .long . - penalty

caporiga: .ascii "\n\n"

sceltascrittura3: .long 0

array_ptr: .long 0
indice2: .long 0
array_size: .long 0
array_size_lenght: .long . - array_size

elementi2: .long 0
margine2: .long 0
elemento2: .long 0
elemento_ptr2: .long 0
elemento_successivo2: .long 0
elemento_successivo_ptr2: .long 0
temp3: .long 0
temp22: .long 0

durata2: .long 0
priorita2: .long 0
penalita2: .long 0

i12: .long 0
i22: .long 0
target2: .long 0

fd1: .long 0                                                             # file descriptor write

.section .text
.globl _start

.section .text
	.global hpf

.type hpf, @function
hpf:
	movl %eax, array_ptr
	movl %ebx, array_size
	movl %ecx, sceltascrittura3
	movl %edx, fd1

    movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal scelta2, %ecx        		# | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             			# Execute syscall

	cmpl $1, sceltascrittura3
	jne _continua_1

	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal scelta2, %ecx        		# | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             			# Execute syscall

_continua_1:
	mov $0, %ecx            		#   Inizializza il contatore esterno (indice2 i)

ordinamento:
	movl array_size, %eax  			# Carica il valore di 'array_size' nel registro %eax
    movl %eax, elementi2    		# Copia il valore di %eax in 'elementi22'

	movl elementi2, %eax   			# Carica il valore di 'elementi22' nel registro %eax
    shrl $4, %eax         			# Esegui lo shift a destra di 4 bit (divisone per 16)
    movl %eax, elementi2   			# Salva il risultato di nuovo in 'elementi2'

	addl $1, elementi2

passo1:
	movl $0, i12

loop:
	movl array_ptr, %eax
	movl %eax, %ecx

	movl i12, %eax
	inc %eax
	movl %eax, i12

	movl $0, i22

	movl elementi2, %eax
	cmp i12, %eax
	jl conteggio

	movl i12, %eax
	movl elementi2, %ebx

	movl %ebx, target2
	subl $1, target2

	movl %ecx, indice2
	addl $12, indice2

loop_2:
	movl i22, %eax
	inc %eax
	movl %eax, i22

	movl target2, %eax
	cmp i22, %eax
	jl loop

	# Le righe che seguono servono ad inserire in elemento il valore da controllare , ciò è stato scritto così
	# per smarcare qualsiasi problema di mismatch tra gli operandi
	movl indice2, %eax    # Carica il valore di array_ptr (indirizzo dell'array) in %eax
    movl (%eax), %ebx       # Carica il valore puntato da %eax (primo elemento dell'array) in %ebx
	movl %eax, elemento_ptr2
    movl %ebx, elemento2     # Salva il valore di %ebx in 'elemento'

	# Le righe che seguono servono ad inserire in elemento il valore da controllare , ciò è stato scritto così
	# per smarcare qualsiasi problema di mismatch tra gli operandi
	movl indice2, %eax
    addl $16, %eax
	movl (%eax), %ebx
	movl %eax, elemento_successivo_ptr2
    movl %ebx, elemento_successivo2

	movl elemento2, %eax
	cmp %eax, %ebx
	jg scambio

	cmp %eax, %ebx
	je parita

	jmp cambio_indici
	
scambio:


	movl elemento_ptr2, %ecx
	movl %ecx, temp3
	subl $12, temp3
	movl elemento_successivo_ptr2, %edx
	movl %edx, temp22
	subl $12, temp22
	movl temp3, %ecx
	movl temp22, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr2, %ecx
	movl %ecx, temp3
	subl $8, temp3
	movl elemento_successivo_ptr2, %edx
	movl %edx, temp22
	subl $8, temp22
	movl temp3, %ecx
	movl temp22, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr2, %ecx
	movl %ecx, temp3
	subl $4, temp3
	movl elemento_successivo_ptr2, %edx
	movl %edx, temp22
	subl $4, temp22
	movl temp3, %ecx
	movl temp22, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr2, %ecx
	movl elemento_successivo_ptr2, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

cambio_indici:
	movl elemento_successivo_ptr2, %eax
	movl %eax, indice2

	jmp loop_2

parita:
	movl elemento_ptr2, %ecx
	movl %ecx, temp3
	subl $4, %ecx
	movl (%ecx), %eax
	movl %eax, temp3
	movl elemento_successivo_ptr2, %edx
	movl %edx, temp22
	subl $4, %edx
	movl (%edx), %eax
	movl %eax, temp22
	movl temp3, %ecx

	cmp %ecx, temp22
	jl scambio

	cmp %ecx, temp22
	jge cambio_indici

penalita:
	movl durata2, %eax
	movl margine2, %ebx

	subl %ebx, %eax
	imull priorita2, %eax     # Moltiplica il valore di %ebx per %eax, risultato in %eax
	addl %eax, penalita2

	jmp cambio

conteggio:
	movl array_ptr, %eax 
	addl $4, %eax
	movl %eax, elemento_ptr2
	movl array_ptr, %ebx
	addl $20, %ebx
	movl %ebx, elemento_successivo_ptr2	
	movl elemento_ptr2, %eax
	movl elemento_successivo_ptr2, %ebx
	movl (%eax), %ecx
	movl (%ebx), %edx
	movl %ecx, elemento2
	movl %edx, elemento_successivo2
	movl $0, %eax
	movl %eax, i12
	movl elemento_ptr2, %eax
	addl $4, %eax
	movl (%eax), %ebx
	movl %ebx, margine2
	movl elemento_ptr2, %eax
	addl $8, %eax
	movl (%eax), %ebx
	movl %ebx, priorita2

loop_conteggio:
	
	movl elementi2, %eax
	subl $1, %eax
	cmpl %eax, i12
	jg _continua_2
		
	movl elemento_ptr2, %eax
	subl $4, %eax
	movl (%eax), %eax
	
	movl fd1, %ebx	

	# stampa a video
	call itoa		# stampa ID

	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal separatore2, %ecx        	# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall
	
	movl durata2, %eax
	movl fd1, %ebx
	call itoa						# stampa durata

	# stampa \n
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal caporiga, %ecx        		# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall	
		
	# stampa su file
	movl elemento_ptr2, %eax
	subl $4, %eax
	movl (%eax), %eax
	movl fd1, %ebx
	
	cmpl $1, sceltascrittura3
	je _stampaparametrofile

_continua_2:
	movl elementi2, %eax
	cmp i12, %eax
	jl fine

	movl durata2, %eax
	addl elemento2, %eax
	movl %eax, durata2
	movl margine2, %eax

	cmp durata2, %eax
	jl penalita

cambio:
	movl elemento_ptr2, %eax
	addl $16, %eax
	movl elemento_successivo_ptr2, %ebx
	addl $16, %ebx
	movl (%eax), %ecx
	movl (%ebx), %edx
	movl %ecx, elemento2
	movl %edx, elemento_successivo2
	
	movl elemento_ptr2, %eax
	addl $16, %eax
	movl %eax, elemento_ptr2
	movl elemento_successivo_ptr2, %ebx
	addl $16, %ebx
	movl %ebx, elemento_successivo_ptr2
	
	movl elemento_ptr2, %eax
	addl $4, %eax
	movl (%eax), %ebx
	movl %ebx, margine2
	movl elemento_ptr2, %eax
	addl $8, %eax

	movl (%eax), %ebx
	movl %ebx, priorita2

	movl i12, %eax
	inc %eax
	movl %eax, i12

	jmp loop_conteggio

fine:
	# stampa a video
	#	Stampa Conclusione -> durata2
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal conclusione, %ecx        	# | <- destination
	movl conclusionelenght, %edx    # | <- length
	int $0x80             			# Execute syscall

	movl durata2, %eax
	call itoa	
	#	Stampa Penalità -> penalita2
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal penalty, %ecx        		# | <- destination
	movl penaltylenght, %edx    	# | <- length
	int $0x80             			# Execute syscall

	movl penalita2, %eax
	call itoa

	# stampa caporiga
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal caporiga, %ecx        		# | <- destination
	movl $1, %edx    	# | <- length
	int $0x80             			# Execute syscall

	# stampa su file
	# Stampa Conclusione -> durata2
	cmpl $1, sceltascrittura3
	jne eb
	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal conclusione, %ecx        	# | <- destination
	movl conclusionelenght, %edx    # | <- length
	int $0x80             			# Execute syscall

	movl durata2, %eax
	movl fd1, %ebx
	call itoafile	
	#	Stampa Penalità -> penalita2
	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal penalty, %ecx        		# | <- destination
	movl penaltylenght, %edx    	# | <- length
	int $0x80             			# Execute syscall

	movl penalita2, %eax
	movl fd1, %ebx
	call itoafile
	
	# stampa \n
	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal caporiga, %ecx        		# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall

eb:
	movl $0, penalita2
	movl $0, durata2

	ret

# stampa linea 
_stampaparametrofile:

	call itoafile					# stampa ID

	# stampa :
	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal separatore2, %ecx        	# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall
	
	movl durata2, %eax
	movl fd1, %ebx

	call itoafile					# stampa durata

	# stampa \n
	movl $4, %eax	        		# Set system call WRITE
	movl fd1, %ebx	        		# | <- standard output (video)
	leal caporiga, %ecx       	 	# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall

jmp _continua_2


_exit:
    movl $1, %eax                  # Systemcall EXIT
    movl $1, %ebx                  # codice di uscita 1 (error)
    int $0x80
