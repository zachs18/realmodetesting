	.code16
	.section ".boot_text","a"
	.globl boot_disk_read
/*
	@param ES:BX buffer address
	@param AL sector count
*/
boot_disk_read:
	mov	$2,%ah
	mov	$0x0001,%cx
	mov	$0x0080,%dx
	int	$0x13
	ret

