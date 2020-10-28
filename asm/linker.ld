ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* ensure that the uefi header is at the beginning */
        *(.uefi_header)
    }

    .text :
    {
        *(.text)
    }
}