nasm -f elf64 -g -F dwarf -l ./build/index.lst -o ./build/index.o juego.asm

gcc -no-pie -o ./build/index ./build/index.o
