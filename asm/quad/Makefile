all: quad.elf quad.hex quad.txt

quad.elf: quad.S
	riscv64-unknown-elf-as -march=rv32i -o quad.elf quad.S

quad.hex: quad.elf
	elf2hex --bit-width 32 --input quad.elf --output quad.hex

quad.txt: quad.elf
	riscv64-unknown-elf-objdump -D quad.elf > quad.txt

clean:
	rm -f *.elf
	rm -f *.hex
	rm -f *.txt
