CC := clang
LD := ld.lld

CFLAGS := \
		-ffreestanding \
		-fno-stack-protector \
		-fno-pic \
		-m64 \
		-Wall	\
		-Wextra

LDFLAGS := \
		-T kernel/linker.ld \
		-nostdlib

build/kernel.elf: kernel/main.c kernel/linker.ld
		mkdir -p build
		$(CC) $(CFLAGS) -c kernel/main.c -o build/main.o
		$(LD) $(LDFLAGS) build/main.o -o build/kernel.elf

clean:
	rm -rf build

.PHONY:	clean
