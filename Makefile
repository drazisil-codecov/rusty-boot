all: build

build: 
	rm -rf out
	DOCKER_BUILDKIT=1 docker build --file Dockerfile --output out --build-arg CACHEBUST=$(date +%s) .

.build-in-docker:
	nasm -f elf64 asm/uefi_header.asm
	nasm -f elf64 asm/boot.asm
	mkdir -p out
	ld -n -o out/kernel.bin -T asm/linker.ld asm/uefi_header.o asm/boot.o

.iso-in-docker: .build-in-docker
	cp out/kernel.bin isofiles/boot/
	grub-mkrescue -o os.iso isofiles
	# if grub-file --is-x86-multiboot2 os.iso; then \
	#  	echo "The file is multiboot2"; \
	# else \
	# 	echo "The file is not multiboot2!"; \
	# fi

run: build
	qemu-system-x86_64 -cdrom out/os.iso

.SILENT:
