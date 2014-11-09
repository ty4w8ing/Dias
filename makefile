
dias: dias.o
	ld -m elf_i386 -o dias dias.o

dias.o: dias.asm
	nasm -f elf -g -F stabs dias.asm -l dias.lst
