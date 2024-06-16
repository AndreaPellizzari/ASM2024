# funzione che riceve in input un parametro (in %ECX) e retistuisce il parametro in stringa con la sua 
# dimensione
# in ECX --> indirizzo della stringa del parametro
# IN EDX --> dimensione della stringa
.section .data

new_line_char:
	.byte 10

.section .text
	.global _saveparam

.type _saveparam, @function
_saveparam:
    # il parametro lo ho già in %ecx
handle_par:
	testl %ecx, %ecx								# controlla se ECX e' 0 (NULL)
	jz fine
	call print_par									# stampa il parametro

fine:
	ret


# --------------------------------------
.type print_par, @function							# Stampa la stringa del parametro e va a capo
print_par:
	call count_char 
	ret
    # restituisce in %ecx la stringa e in %edx la lunghezza!

# --------------------------------------
.type count_char, @function							# conta da quanti caratteri è composta la stringa del parametro
													# il valore risultato è contenuto in edx
count_char:
	xorl %edx, %edx

iterate:
	movb (%ecx,%edx), %al 							# mette il carattere della stringa in al
	testb %al, %al 									# se il carattere è 0 (\0) la stringa è finita
	jz end_count				
	incl %edx
	jmp iterate

end_count:
	ret
