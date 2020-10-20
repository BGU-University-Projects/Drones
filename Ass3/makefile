all: ass3

libs: asm-lib

ass3: ass3.s
	# flags meanings:
	# -g = debug symbolx
	# -f elf = output format (ELF 32 bit)
	# -o add.o = write assembled file to add.o
	nasm -f elf ass3.s -o ass3.o
	nasm -f elf scheduler.s -o scheduler.o
	nasm -f elf printer.s -o printer.o
	nasm -f elf drone.s -o drone.o
	nasm -f elf target.s -o target.o




	gcc -g -m32 -Wall -g ass3.o scheduler.o printer.o drone.o target.o -o ass3

.PHONY: clean
clean:
	rm -rf ./*.o ass3
