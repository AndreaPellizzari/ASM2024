AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/EDF.o obj/HPF.o obj/itoa.o obj/saveparam.o obj/readfile.o
	ld $(LD_FLAGS) obj/main.o obj/EDF.o obj/HPF.o obj/itoa.o obj/saveparam.o obj/readfile.o -o bin/pianificatore

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/EDF.o: src/EDF.s
	as $(AS_FLAGS) $(DEBUG) src/EDF.s -o obj/EDF.o

obj/HPF.o: src/HPF.s	
	as $(AS_FLAGS) $(DEBUG) src/HPF.s -o obj/HPF.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

obj/saveparam.o: src/saveparam.s
	as $(AS_FLAGS) $(DEBUG) src/saveparam.s -o obj/saveparam.o

obj/readfile.o: src/readfile.s
	as $(AS_FLAGS) $(DEBUG) src/readfile.s -o obj/readfile.o

#clean:
#	rm -f obj/*.o bin/itoa
