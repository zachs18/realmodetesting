	.code16
	.section ".boot_text","a"
	.globl	boot_disk_read
	.type	boot_disk_read,@function
/*
	//https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)#Reading_sectors_with_a_CHS_address
	@param ES:BX buffer address
	@param AL sector count
	@param CH cylinder
	@param CL sector (< 64)
	@param DH head
	@param DL drive number
*/
boot_disk_read:
	.cfi_startproc
	mov	$2,%ah
	int	$0x13
	ret
	.cfi_endproc
	.size boot_disk_read, .-boot_disk_read


	.section ".text16","a"
	.globl	disk_read16
	.type	disk_read16,@function
/*
	//https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)#Reading_sectors_with_a_CHS_address
	@param ES:BX buffer address
	@param AL sector count
	@param CH cylinder
	@param CL sector (< 64)
	@param DH head
	@param DL drive number
*/
disk_read16:
	.cfi_startproc
	mov	$2,%ah
	int	$0x13
	ret
	.cfi_endproc
	.size disk_read16, .-disk_read16
