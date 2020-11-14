	.code16
	.section ".text16","a"
	.global menu
	.type	menu,@function
menu:
	.cfi_startproc
	movb	$0,.Linput
	
	xor	%ax,%ax
	xor	%cx,%cx
	xor	%dx,%dx
	mov	$320,%si
	mov	$200,%di
	call draw_rectangle

	lea	.LC0,%ax
	mov	$0,%cx
	mov	$0,%dx
	call	draw_str

	lea	.LC1,%ax
	mov	$0,%cx
	mov	$10,%dx
	call	draw_str

	lea	.LC2,%ax
	mov	$0,%cx
	mov	$20,%dx
	call	draw_str

	lea	.Lmenu_kb_handler,%eax
	call	install_kb_handler

.Lwhile:
	hlt
	mov	.Linput,%al
	test	%al,%al
	jz	.Lwhile

	cmp	$1,%al
	je	hex_color_prog

	cmp	$2,%al
	je	type_prog

	cmp	$3,%al
	je	print_keycode_prog

	jmp	.Lwhile
	
	.cfi_endproc
	.size	menu, .-menu

	.type	.Lmenu_kb_handler,@function
.Lmenu_kb_handler:
	.cfi_startproc
	push	%eax
	in	$0x60,%al
	test	$0x80,%al
	jnz	.Leoi
	cmp	$2,%al
	jb	.Leoi
	cmp	$10,%al
	ja	.Leoi
	dec	%al
	mov	%al,.Linput

	// EOI
.Leoi:
	mov	$0x61,%al
	out	%al,$0x20
	
	pop	%eax
	iret
	
	.cfi_endproc
	.size .Lmenu_kb_handler, .-.Lmenu_kb_handler

	.section ".data16","a"
.LC0:	.string "1) Hex Input Color Testing"
.LC1:	.string "2) Typing"
.LC2:	.string "3) Print key codes"
.Linput:	.byte 0
