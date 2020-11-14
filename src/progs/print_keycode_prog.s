	.code16
	.section ".text16","a"
	.global print_keycode_prog
	.type	print_keycode_prog,@function
print_keycode_prog:
	.cfi_startproc
	
	movb	$0,.Lquit
	
	lea	.Lprint_keycode_prog_kb_handler,%eax
	call install_kb_handler

.Lloop:
	cmpb	$0,.Lquit
	jne	menu
	
	lea	.Lkeycodes,%esi
	mov	$8,%ax
	mov	$0,%cx
	mov	$180,%dx
	call	draw_bytes_hex

	jmp	.Lloop

	.cfi_endproc
	.size print_keycode_prog, . - print_keycode_prog


	.section ".text16","a"
	.type	.Lprint_keycode_prog_kb_handler,@function
.Lprint_keycode_prog_kb_handler:
	.cfi_startproc
	push	%eax
	push	%esi
	push	%edi
	push	%es
	
	xor	%ax,%ax
	mov	%ax,%es
	
	lea	.Lkeycodes+6,%esi
	lea	.Lkeycodes+7,%edi
	std
	mov	$7,%ecx
	rep movsb
	cld
	
	in	$0x60,%al
	cmp	$1,%al
	jne	1f
	orb	$1,.Lquit
1:
	mov	%al,.Lkeycodes

	// EOI
.Leoi:
	mov	$0x61,%al
	out	%al,$0x20
	
	pop	%es
	pop	%edi
	pop	%esi
	pop	%eax
	iret
	.cfi_endproc
	.size	.Lprint_keycode_prog_kb_handler, .-.Lprint_keycode_prog_kb_handler
	
	.section	".data16","a"
.Lkeycodes:
	.long 0
	.long 0
.Lquit:
	.byte 0
