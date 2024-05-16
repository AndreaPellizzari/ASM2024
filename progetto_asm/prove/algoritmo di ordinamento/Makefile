AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

#	sall: bin/readfile3

bin/ordinamento: obj/ordinamento.o
	ld $(LD_FLAGS)  obj/ordinamento.o -o bin/ordinamento

obj/ordinamento.o: src/ordinamento.s
	as $(AS_FLAGS) $(DEBUG) src/ordinamento.s -o obj/ordinamento.o

clean:
	rm -f obj/*.o bin/ordinamento