# per convertire i caratteri in numero si utilizza la formula ricorsiva
#
# 10*( 10*( 10*d + d ) + d ) + d
#             N-1 N-2   N-3   N-4
#

.section .data

.section .text
  .global _converti

.type _converti, @function
_converti:
  movl 12(%esp), %ecx
  pop %esp
  leal (%ecx), %esi
  movl $0, %ecx            # azzero il contatore
  movl $0, %ebx            # azzero il registro EBX


ripeti:
  # movb (%esi), %al
  movb (%ecx,%esi,1), %bl

  cmp $10, %bl             # vedo se e' stato letto il carattere '\n'
  je fine

  subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
  movl $10, %edx
  mulb %dl                # EBX = EBX * 10
  addl %ebx, %eax

  inc %ecx
  jmp ripeti


fine:
  # il risultato si trova in EAX
  movl $0, %ebx
  int $0x80
