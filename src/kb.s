	.code16
	.section ".text16","a"
	.global install_kb_handler
/*
	@param AX ISR function
	@param CS ISR segment
*/
install_kb_handler:
	cli
	mov	%ax,0x24
	mov	%cx,0x26
	sti
	ret

	.section ".text16","a"
	.global default_kb_handler
default_kb_handler:
	// EOI
	mov	$0x61,%al
	out	%al,$0x20

	iret
