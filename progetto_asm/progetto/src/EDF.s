.section .data

scelta2: .ascii "\n✅ Hai scelto l'algoritmo EDF ✅\n\n"
scelta2lenght: .long . - scelta2

ordinamento_e: .ascii "\n✅ Ordinamento per durata effettuato ✅\n\n"
ordinamento_e_lenght: .long . - ordinamento_e

separatore: .ascii ":"
separatorelenght: .long . - separatore

sceltascrittura2: .long 0

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


    movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal scelta2, %ecx        # | <- destination
	movl scelta2lenght, %edx        # | <- length
	int $0x80             # Execute syscall

	mov $0, %ecx            #   Inizializza il contatore esterno (indice i)

	movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal array_size, %ecx        # | <- destination
	movl array_size_lenght, %edx        # | <- length
	int $0x80             # Execute syscall

ordinamento:
	movl array_size, %eax  # Carica il valore di 'array_size' nel registro %eax
    movl %eax, elementi    # Copia il valore di %eax in 'elementi'

	movl elementi, %eax   # Carica il valore di 'elementi' nel registro %eax
    shrl $4, %eax         # Esegui lo shift a destra di 4 bit (divisone per 16)
    movl %eax, elementi   # Salva il risultato di nuovo in 'elementi'

passo1:
	movl $1, i1

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
	jl fine

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
	addl $4, temp
	movl (temp), %ecx
	movl %ecx, temp
	movl elemento_successivo_ptr, %edx
	movl %edx, temp2
	addl $4, temp2
	movl (temp2), %edx
	movl %edx, temp2

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
	movl i1, %eax
	inc %eax
	movl %eax, i1

	movl elemento_ptr, %eax
	subl $4, %eax
	#	Stampa ID:durata

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

	jmp loop_conteggio

fine:

	#	Stampa Conclusione -> durata
	#	Stampa Penalità -> penalita1

	movl $4, %eax	        # Set system call WRITE
	movl $1, %ebx	        # | <- standard output (video)
	leal ordinamento_e, %ecx        # | <- destination
	movl ordinamento_e_lenght, %edx        # | <- length
	int $0x80             # Execute syscall
	
	ret
	