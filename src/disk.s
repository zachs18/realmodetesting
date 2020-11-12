	.code16
	.section ".boot_text","a"
	.globl	boot_disk_read
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
	mov	$2,%ah
	int	$0x13
	ret


	.section ".text16","a"
	.globl	disk_read16
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
	mov	$2,%ah
	int	$0x13
	ret
