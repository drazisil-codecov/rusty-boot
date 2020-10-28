# This is a multi-stage dockerfile.
# * stage1 - Create a base image to build the kernel in
# * stage2 - Build the kernel in the stage1 image
# * export-stage - Export the final files from stage2 to the host
FROM ubuntu:18.04 as stage1

RUN apt update && \
    echo "no" | apt install -y \
        build-essential \
        wget \
        bison \
        flex \
        python3 \
        nasm \
        xorriso

# Download and build grub2
RUN wget ftp://ftp.gnu.org/gnu/grub/grub-2.04.tar.gz
RUN zcat grub-2.04.tar.gz | tar xvf -
RUN cd grub-2.04 && \
    ./configure && \
    make install

FROM stage1 as stage2

ARG CACHEBUST=1 

WORKDIR /app

COPY asm asm

COPY isofiles isofiles

COPY Makefile Makefile



RUN make .iso-in-docker

FROM scratch AS export-stage
COPY --from=stage2 /app/asm/uefi_header.o .
COPY --from=stage2 /app/asm/boot.o .
COPY --from=stage2 /app/out/kernel.bin .
COPY --from=stage2 /app/os.iso .
