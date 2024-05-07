AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/eseguibile

bin/eseguibile: obj/main.o obj/EDF.o obj/HPF.o
	ld $(LD_FLAGS) obj/main.o obj/EDF.o obj/HPF.o -o bin/eseguibile

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/EDF.o: src/EDF.s
	as $(AS_FLAGS) $(DEBUG) src/EDF.s -o obj/EDF.o

obj/HPF.o: src/HPF.s
	as $(AS_FLAGS) $(DEBUG) src/HPF.s -o obj/HPF.o

#clean:
#	rm -f obj/*.o bin/itoa
