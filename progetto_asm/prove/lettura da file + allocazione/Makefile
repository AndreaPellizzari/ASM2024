AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/readfile3

bin/readfile3: obj/readfile3.o obj/str2num.o obj/itoa.o obj/saveparam.o
	ld $(LD_FLAGS)  obj/readfile3.o obj/str2num.o obj/itoa.o obj/saveparam.o -o bin/readfile3

obj/readfile3.o: src/readfile3.s
	as $(AS_FLAGS) $(DEBUG) src/readfile3.s -o obj/readfile3.o

obj/str2num.o: src/str2num.s
	as $(AS_FLAGS) $(DEBUG) src/str2num.s -o obj/str2num.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

obj/saveparam.o: src/saveparam.s
	as $(AS_FLAGS) $(DEBUG) src/saveparam.s -o obj/saveparam.o
	

clean:
	rm -f obj/*.o bin/readfile3