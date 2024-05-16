AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/test

bin/test: obj/test.o 
	ld $(LD_FLAGS)  obj/test.o -o bin/test

obj/test.o: src/test.s
	as $(AS_FLAGS) $(DEBUG) src/test.s -o obj/test.o


clean:
	rm -f obj/*.o bin/test