	.code16
	.section ".text16","a"
	.global install_kb_handler
	.type	install_kb_handler,@function
/*
	@param EAX ISR segment:function
*/
install_kb_handler:
	.cfi_startproc
	cli
	mov	%eax,0x24
	sti
	ret
	.cfi_endproc
	.size	install_kb_handler, .-install_kb_handler

	.section ".text16","a"
	.global	default_kb_handler
	.type	default_kb_handler,@function
default_kb_handler:
	.cfi_startproc
	// EOI
	mov	$0x61,%al
	out	%al,$0x20

	iret
	.cfi_endproc
	.size	default_kb_handler, .-default_kb_handler
