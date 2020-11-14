	.code16
	.section ".text16","a"
	.global hex_color_prog
	.type	hex_color_prog,@function
hex_color_prog:
	.cfi_startproc
	movb	$0,.Lquit
	
	lea	.Lhex_color_prog_kb_handler,%eax
	call	install_kb_handler

.Lbegin:
	xor	%di,%di
	
	movzbw	.Lcolor,%ax
	push	%ax

	xor	%esi,%esi
	mov	%ss,%si
	shl	$4,%esi
	xor	%ecx,%ecx
	mov	%sp,%cx
	add	%ecx,%esi # lea %ss:(%sp),%esi (lea ignores segment overrides)

	mov	$2,%ax
	mov	$0,%cx
	mov	$180,%dx
	call	draw_bytes_hex
	add	$2,%sp

	add	$(6*5),%cx
	mov	$'"',%ax
	call	draw_char

	add	$6,%cx
	movzbw	.Lcolor,%ax
	call	draw_char

	add	$6,%cx
	mov	$'"',%ax
	call	draw_char

//	mov	$0x4F00


	xor	%di,%di
	xor	%dx,%dx # row
.Lloop0:
	xor	%cx,%cx # col
.Lloop1:
//	cmp	$256,%cx
	mov	.Lcolor,%ax
	mov	%al,%es:(%di)
	inc	%di
	inc	%cx
	cmp	$320,%cx
	jb	.Lloop1
	inc	%dx
	cmp	$180,%dx
	jb	.Lloop0
	hlt
	
	mov	.Lquit,%al
	test	%al,%al
	jnz	menu
	
	jmp	.Lbegin
	
	.cfi_endproc
	.size hex_color_prog, .-hex_color_prog

	.type .Lhex_color_prog_kb_handler,@function
.Lhex_color_prog_kb_handler:
	.cfi_startproc
	push %eax
	push %ecx
	
	in	$0x60,%al
	test	$0x80,%al
	jnz	.Leoi
	cmp	$1,%al # scan code for Esc
	jne	1f
	movb	$0x01,.Lquit
	jmp 	.Leoi
1:
	cmp	$10,%al # scan codes for 1-9 are 2-10
	ja	.Lharder
	sub	$1,%al
	jmp	.Lal_assigned
.Lharder:
	mov	%al,%ah

	mov $0x0,%al
	cmp	$11,%ah # scan code for 0
	je	.Lal_assigned

	mov $0xa,%al
	cmp	$30,%ah # scan code for a
	je	.Lal_assigned
	
	mov $0xb,%al
	cmp	$48,%ah # scan code for b
	je	.Lal_assigned
	
	mov $0xc,%al
	cmp	$46,%ah # scan code for c
	je	.Lal_assigned
	
	mov $0xd,%al
	cmp	$32,%ah # scan code for d
	je	.Lal_assigned
	
	mov $0xe,%al
	cmp	$18,%ah # scan code for e
	je	.Lal_assigned
	
	mov $0xf,%al
	cmp	$33,%ah # scan code for f
	je	.Lal_assigned
	
	jmp	.Leoi
	
.Lal_assigned:
	shlb	$4,.Lcolor
	orb	%al,.Lcolor
.Leoi:
	// EOI
	mov	$0x61,%al
	out	%al,$0x20

	pop	%ecx
	pop %eax
	iret
	
	.cfi_endproc
	.size	.Lhex_color_prog_kb_handler, .-.Lhex_color_prog_kb_handler

	.section ".data16","a"
.Lcolor:
	.byte	0
.Lquit:
	.byte	0
