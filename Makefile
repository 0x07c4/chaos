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

iso: build/kernel.elf limine.conf
	rm -rf iso_root
	mkdir -p iso_root

	cp build/kernel.elf iso_root/kernel.elf
	cp limine.conf iso_root/limine.conf
	cp limine/limine-bios.sys iso_root/
	cp limine/limine-bios-cd.bin iso_root/
	cp limine/limine-uefi-cd.bin iso_root/

	xorriso -as mkisofs \
		-b limine-bios-cd.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--efi-boot limine-uefi-cd.bin \
		-efi-boot-part \
		--efi-boot-image \
		--protective-msdos-label \
		iso_root \
		-o chaos.iso

	./limine/limine bios-install chaos.iso

.PHONY: iso

run: iso
	qemu-system-x86_64 -cdrom chaos.iso -debugcon stdio
