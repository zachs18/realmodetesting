	.code16
	.section ".text16","a"
	.globl	draw_rectangle
	.type	draw_rectangle,@function
draw_rectangle: # Assumes %es:0x0000 points to video memory
/*
	@param AL color
	@param CX X
	@param DX Y
	@param SI W
	@param DI H
*/
	.cfi_startproc
	push	%ebx
	push	%ebp
	push	%es
	xor	%bx,%bx
	mov	%bx,%es
	
	sub	$8,%sp
	mov	%sp,%bp
	mov	%si,4(%bp)
	mov	%di,2(%bp)
	mov	$320,%si
	sub	4(%bp),%si
	mov	%si,6(%bp)
/*
	ix is at 0(%bp) [W down to 0) (needs to be reinited to W each iteration)
	jy is at 2(%bp) [H down to 0)
	W  is at 4(%bp)
	320-W at 6(%bp)
*/

	mov	$0xA0000,%edi
	movzx	%cx,%ecx
	add	%ecx,%edi
	
	mov	%ax,%cx
	
	movzx	%dx,%eax
	mov	$320,%edx
	mul	%edx
	add	%eax,%edi
	
	mov %cx,%ax
	
.Lrow:
	cmpw	$0,2(%bp)
	jz	.Lendrow
	mov	4(%bp),%cx
	mov	%cx,0(%bp)

	movzxw	4(%bp),%ecx
	rep stosb %al,(%edi)
	
	movzxw	6(%bp),%ecx
	add	%ecx,%edi
	decw	2(%bp)
	jmp	.Lrow
.Lendrow:
	
	add	$8,%sp
	pop	%es
	pop	%ebp
	pop	%ebx
	ret
	.cfi_endproc
	.size	draw_rectangle, .-draw_rectangle

	.section ".text16","a"
	.globl	draw_str
	.type	draw_str,@function
draw_str: # Assumes %es:0x0000 points to video memory
/*
	@param AX str
	@param CX X
	@param DX Y
*/
	.cfi_startproc
	push	%ebx

	mov	%ax,%bx
0:
	mov	(%bx),%al
	inc	%bx
	test	%al,%al
	jz	1f
	call	draw_char
	add	$6,%cx
	jmp	0b
1:

	pop	%ebx
	ret
	.cfi_endproc
	.size	draw_str, .-draw_str

	.section ".text16","a"
	.globl	draw_char
	.type	draw_char,@function
draw_char: # Assumes %es:0x0000 points to video memory
/*
	@param AL char
	@param CX X
	@param DX Y
*/
	.cfi_startproc
	data32 pusha

	push	%ax
// calculate %di
//	%di = width*Y+X (320*%dx+%cx)
	mov	%cx,%di
//	%dx:%ax = %ax * 320
	mov	%dx,%ax
	mov	$320,%cx
	mul	%cx
//	now %dx:%ax = 320*width (which is at most 0xFA00, so %dx == 0)
	add	%ax,%di
//	now %di points to the top left corner of where we'll be placing
	pop	%ax

// calculate %si
	mov	$(5*9),%cl
	mul	%cl
	mov	%ax,%bx
	lea	char_000(%bx),%si

	call	draw_helper

	data32 popa
	ret
	.cfi_endproc
	.size	draw_char, .-draw_char


	.section ".text16","a"
	.globl	draw_bytes_hex
	.type	draw_bytes_hex,@function
draw_bytes_hex: # Assumes %es:0x0000 points to video memory
/*
	@param ESI data (ptr)
	@param AX count
	@param CX X
	@param DX Y
*/
	.cfi_startproc
	data32 pusha

	push	%ax
// count is at %ss:0(%bp)

//	%di = width*Y+X (320*%dx+%cx)
	mov	%cx,%di
//	%dx:%ax = %ax * 320
	mov	%dx,%ax
	mov	$320,%cx
	mul	%cx
//	now %dx:%ax = 320*width (which is at most 0xFA00, so %dx == 0)
	add	%ax,%di

//	now %di points to the top left corner of where we'll be placing

	xor	%ebx,%ebx
	mov	%sp,%bp
.Lloop1:
	cmp	%bx,%ss:(%bp)
	jz	.Lend1

	movb	(%esi,%ebx),%al
	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx
	shr	$4,%ax
	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx

	inc	%bx
	jmp	.Lloop1
.Lend1:
//Stack now holds the digits as words in order to be drawn

	xor	%dx,%dx
.Lloop2:
	cmp	%dx,%ss:(%bp)
	jz	.Lend2

	mov	$2,%cl

	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	.Ldigits(%bx),%si
	call	draw_helper
	add	$6,%di

	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	.Ldigits(%bx),%si
	call	draw_helper
	add	$6,%di

	inc	%dx
	jmp	.Lloop2
.Lend2:
	pop	%ax # count

	data32 popa
	ret
	.cfi_endproc
	.size	draw_bytes_hex, .-draw_bytes_hex

	.type	draw_helper,@function
draw_helper:
	.cfi_startproc
//	%es:(%di) points to the top right corner of the current digit
//	%ds:(%si) points to the 45-byte (5x9) character to draw
.macro row n
	mov	%ds:(\n*5)(%si),%edx
	mov	%edx,%es:(\n*320)(%di)
	mov	%ds:(\n*5+4)(%si),%dl
	mov	%dl,%es:(\n*320+4)(%di)
.endm
	push	%edx
	ROW 0
	ROW 1
	ROW 2
	ROW 3
	ROW 4
	ROW 5
	ROW 6
	ROW 7
	ROW 8
	pop	%edx
	ret
	.cfi_endproc
	.size	draw_helper, .-draw_helper

	.section ".data16","a"
.Ldigits:
	.word	char_048
	.word	char_049
	.word	char_050
	.word	char_051
	.word	char_052
	.word	char_053
	.word	char_054
	.word	char_055
	.word	char_056
	.word	char_057
	.word	char_065
	.word	char_066
	.word	char_067
	.word	char_068
	.word	char_069
	.word	char_070
.LdigitsEnd:
