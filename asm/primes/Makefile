all: primes.elf primes.hex primes.txt

primes.elf: primes.S
	riscv64-unknown-elf-as -march=rv32i -o primes.elf primes.S

primes.hex: primes.elf
	elf2hex --bit-width 32 --input primes.elf --output primes.hex

primes.txt: primes.elf
	riscv64-unknown-elf-objdump -D primes.elf > primes.txt
