.section .data

ordinamento_e: .ascii "\n✅ Ordinamento per durata effettuato ✅\n\n"
ordinamento_e_lenght: .long . - ordinamento_e

scelta2: .ascii "\nPianificazione EDF:\n"
scelta2lenght: .long . - scelta2

separatore: .ascii ":"
separatorelenght: .long . - separatore

caporiga2: .ascii "\n\n"

conclusione2: .ascii "Conclusione: "
conclusionelenght2: .long . - conclusione2

penalty2: .ascii "\nPenalty: "
penaltylenght2: .long . - penalty2

sceltascrittura2: .long 0

fd2: .long 0                                                             # file descriptor write

array_ptr: .long 0
array_size: .long 0
array_size_lenght: .long . - array_size

elementi: .long 0
elemento: .long 0
margine: .long 0
elemento_ptr: .long 0
elemento_successivo: .long 0
elemento_successivo_ptr: .long 0
temp: .long 0
temp2: .long 0

durata: .long 0
priorita: .long 0
penalita1: .long 0

i1: .long 0
i2: .long 0
target: .long 0

indice: .long 0

.section .text
	.global edf

.type edf, @function
edf:
	movl %eax, array_ptr
	movl %ebx, array_size
	movl %ecx, sceltascrittura2
	movl %edx, fd2

    movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal scelta2, %ecx        		# | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             			# Execute syscall

	cmpl $1, sceltascrittura2
	jne a
	
    movl $4, %eax	        		# Set system call WRITE
	movl fd2, %ebx	        		# | <- standard output (video)
	leal scelta2, %ecx        		# | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             			# Execute syscall

a:
	mov $0, %ecx            #   Inizializza il contatore esterno (indice i)

ordinamento:
	movl array_size, %eax  # Carica il valore di 'array_size' nel registro %eax
    movl %eax, elementi    # Copia il valore di %eax in 'elementi'

	movl elementi, %eax   # Carica il valore di 'elementi' nel registro %eax
    shrl $4, %eax         # Esegui lo shift a destra di 4 bit (divisone per 16)
    movl %eax, elementi   # Salva il risultato di nuovo in 'elementi'

	addl $1, elementi

passo1:
	movl $0, i1

loop:
	movl array_ptr, %eax
	movl %eax, indice

	addl $8, indice

	movl i1, %eax
	inc %eax
	movl %eax, i1

	movl $0, i2

	movl elementi, %eax
	cmp i1, %eax
	jl conteggio

	movl i1, %eax
	movl elementi, %ebx

	movl %ebx, target
	subl $1, target

loop_2:
	movl i2, %eax
	inc %eax
	movl %eax, i2

	movl target, %eax
	cmp i2, %eax
	jl loop

	# Le righe che seguono servono ad inserire in elemento il valore da controllare , ciò è stato scritto così
	# per smarcare qualsiasi problema di mismatch tra gli operandi
	movl indice, %eax    # Carica il valore di array_ptr (indirizzo dell'array) in %eax
    movl (%eax), %ebx       # Carica il valore puntato da %eax (primo elemento dell'array) in %ebx
	movl %eax, elemento_ptr
    movl %ebx, elemento     # Salva il valore di %ebx in 'elemento'

	# Le righe che seguono servono ad inserire in elemento il valore da controllare , ciò è stato scritto così
	# per smarcare qualsiasi problema di mismatch tra gli operandi
	movl indice, %eax
    addl $16, %eax
	movl (%eax), %ebx
	movl %eax, elemento_successivo_ptr
    movl %ebx, elemento_successivo

	movl elemento, %eax
	cmp %eax, %ebx
	jl scambio

	cmp %eax, %ebx
	je parita

	jmp cambio_indici
	
scambio:
	#	movl elemento, %eax
	#	movl elemento_successivo, %ebx

	movl elemento_ptr, %ecx
	movl %ecx, temp
	subl $8, temp
	movl elemento_successivo_ptr, %edx
	movl %edx, temp2
	subl $8, temp2
	movl temp, %ecx
	movl temp2, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr, %ecx
	movl %ecx, temp
	subl $4, temp
	movl elemento_successivo_ptr, %edx
	movl %edx, temp2
	subl $4, temp2
	movl temp, %ecx
	movl temp2, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr, %ecx
	movl elemento_successivo_ptr, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)

	movl elemento_ptr, %ecx
	movl %ecx, temp
	addl $4, temp
	movl elemento_successivo_ptr, %edx
	movl %edx, temp2
	addl $4, temp2
	movl temp, %ecx
	movl temp2, %edx
	movl (%ecx), %eax
	movl (%edx), %ebx
	movl %eax, (%edx)
	movl %ebx, (%ecx)
	
	#	movl elemento_successivo_ptr, %eax
	#	movl %eax, elemento_ptr
	#	addl $16, %eax
	#	movl %eax, elemento_successivo_ptr

	#	movl elemento_ptr, %ecx
	#	movl elemento_successivo_ptr, %edx
	#	movl %eax, (%edx)
	#	movl %ebx, (%ecx)

cambio_indici:
	movl elemento_successivo_ptr, %eax
	movl %eax, indice

	jmp loop_2

parita:
	movl elemento_ptr, %ecx
	movl %ecx, temp
	addl $4, %ecx
	movl (%ecx), %eax
	movl %eax, temp
	movl temp, %ecx
	movl elemento_successivo_ptr, %edx
	movl %edx, temp2
	addl $4, %edx
	movl (%edx), %eax
	movl %eax, temp2

	cmp %ecx, temp2
	jg scambio

	cmp %ecx, temp2
	jle cambio_indici

penalita:
	movl durata, %eax
	movl margine, %ebx

	subl %ebx, %eax
	imull priorita, %eax     # Moltiplica il valore di %ebx per %eax, risultato in %eax
	addl %eax, penalita1

	jmp cambio

conteggio:
	movl array_ptr, %eax 
	addl $4, %eax
	movl %eax, elemento_ptr
	movl array_ptr, %ebx
	addl $20, %ebx
	movl %ebx, elemento_successivo_ptr	
	movl elemento_ptr, %eax
	movl elemento_successivo_ptr, %ebx
	movl (%eax), %ecx
	movl (%ebx), %edx
	movl %ecx, elemento
	movl %edx, elemento_successivo
	movl $0, %eax
	movl %eax, i1
	movl elemento_ptr, %eax
	addl $4, %eax
	movl (%eax), %ebx
	movl %ebx, margine
	movl elemento_ptr, %eax
	addl $8, %eax
	movl (%eax), %ebx
	movl %ebx, priorita

loop_conteggio:
	
	movl elementi, %eax
	subl $1, %eax
	cmpl %eax, i1
	jg _continua_2
		
	movl elemento_ptr, %eax
	subl $4, %eax
	movl (%eax), %eax
	
	movl fd2, %ebx	

	# stampa a video
	call itoa		# stampa ID

	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal separatore, %ecx        	# | <- destination
	movl $1, %edx        			# | <- length
	int $0x80             			# Execute syscall
	
	movl durata, %eax
	movl fd2, %ebx
	call itoa		# stampa durata

	# stampa \n
	movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal caporiga2, %ecx        # | <- destination
	movl $1, %edx        # | <- length
	int $0x80             # Execute syscall	
		
	# stampa su file
	movl elemento_ptr, %eax
	subl $4, %eax
	movl (%eax), %eax
	movl fd2, %ebx
	
	cmpl $1, sceltascrittura2
	je _stampaparametrofile

_continua_2:
	movl elementi, %eax
	cmp i1, %eax
	jl fine

	movl durata, %eax
	addl elemento, %eax
	movl %eax, durata
	movl margine, %eax

	cmp durata, %eax
	jl penalita
	#	movl elemento_ptr2, %eax
	#	addl $16, %eax
	#	movl %eax, %ecx
	#	movl %ecx, %eax
	#	movl (%eax), %ebx
	#	addl %ebx, durata2

cambio:
	movl elemento_ptr, %eax
	addl $16, %eax
	movl elemento_successivo_ptr, %ebx
	addl $16, %ebx
	movl (%eax), %ecx
	movl (%ebx), %edx
	movl %ecx, elemento
	movl %edx, elemento_successivo
	
	movl elemento_ptr, %eax
	addl $16, %eax
	movl %eax, elemento_ptr
	movl elemento_successivo_ptr, %ebx
	addl $16, %ebx
	movl %ebx, elemento_successivo_ptr
	
	movl elemento_ptr, %eax
	addl $4, %eax
	movl (%eax), %ebx
	movl %ebx, margine
	movl elemento_ptr, %eax
	addl $8, %eax

	movl (%eax), %ebx
	movl %ebx, priorita

	movl i1, %eax
	inc %eax
	movl %eax, i1

	jmp loop_conteggio

fine:
	# stampa a video
	#	Stampa Conclusione -> durata2
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal conclusione2, %ecx        	# | <- destination
	movl conclusionelenght2, %edx    # | <- length
	int $0x80             			# Execute syscall

	movl durata, %eax
	call itoa	
	#	Stampa Penalità -> penalita2
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal penalty2, %ecx        		# | <- destination
	movl penaltylenght2, %edx    	# | <- length
	int $0x80             			# Execute syscall

	movl penalita1, %eax
	call itoa

	# stampa caporiga
	movl $4, %eax	        		# Set system call WRITE
	movl $1, %ebx	        		# | <- standard output (video)
	leal caporiga2, %ecx        		# | <- destination
	movl $1, %edx    	# | <- length
	int $0x80             			# Execute syscall

	# stampa su file
	# Stampa Conclusione -> durata2
	cmpl $1, sceltascrittura2
	jne eb
	
	movl $4, %eax	        		# Set system call WRITE
	movl fd2, %ebx	        		# | <- standard output (video)
	leal conclusione2, %ecx        	# | <- destination
	movl conclusionelenght2, %edx    # | <- length
	int $0x80             			# Execute syscall

	movl durata, %eax
	movl fd2, %ebx
	call itoafile	
	#	Stampa Penalità -> penalita2
	movl $4, %eax	        		# Set system call WRITE
	movl fd2, %ebx	        		# | <- standard output (video)
	leal penalty2, %ecx        		# | <- destination
	movl penaltylenght2, %edx    	# | <- length
	int $0x80             			# Execute syscall

	movl penalita1, %eax
	movl fd2, %ebx
	call itoafile
	
	# stampa \n
	movl $4, %eax	        # Set system call WRITE
	movl fd2, %ebx	        # | <- standard output (video)
	leal caporiga2, %ecx        # | <- destination
	movl $1, %edx        # | <- length
	int $0x80             # Execute syscall

eb:
	movl $0, penalita1
	movl $0, durata

	ret

# stampa linea 
_stampaparametrofile:

	call itoafile		# stampa ID

	# stampa :
	movl $4, %eax	        # Set system call WRITE
	movl fd2, %ebx	        # | <- standard output (video)
	leal separatore, %ecx        # | <- destination
	movl $1, %edx        # | <- length
	int $0x80             # Execute syscall
	
	movl durata, %eax
	movl fd2, %ebx

	call itoafile		# stampa durata

	# stampa \n
	movl $4, %eax	        # Set system call WRITE
	movl fd2, %ebx	        # | <- standard output (video)
	leal caporiga2, %ecx        # | <- destination
	movl $1, %edx        # | <- length
	int $0x80             # Execute syscall

jmp _continua_2


_exit:
    movl $1, %eax                                                           # Systemcall EXIT
    movl $1, %ebx                                                           # codice di uscita 1 (error)
    int $0x80
