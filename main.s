	.code16
	.section ".text16","a"
	.globl	main
main:
	call	simd_setup

	xorps	%xmm0,%xmm0

	mov	$.LC0,%si
	call	puts

	xor	%cx,%cx
1:
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt
	hlt

	mov	$0x0013,%ax # set video mode to mode 12 (640x480 16 colors)
	int	$0x10

	push	%es
	mov	$0xA000,%ax
	mov	%ax,%es
/*.Ltry_video:
	xor	%di,%di
	mov	$0x7D00,%cx
	rep stosb
	xor	$0x80,%al
	mov	$0x7D00,%cx
	rep stosb
	xor	$0x80,%al
	inc	%al
	hlt
	jmp	.Ltry_video
//	jnz	.Ltry_video
*/

	call install_kb_hdlr

.Lbegin:
	xor	%di,%di
	movzxb	color,%ax
	mov	$180,%dx
	mov	$0,%cx
	call	draw_uint16_hex

	xor	%di,%di
	xor	%dx,%dx # row
.Lloop0:
	xor	%cx,%cx # col
.Lloop1:
//	cmp	$256,%cx
	mov	color,%al
	mov	%al,%es:(%di)
	inc	%di
	inc	%cx
	cmp	$320,%cx
	jb	.Lloop1
	inc	%dx
	cmp	$180,%dx
	jb	.Lloop0
	hlt
	jmp	.Lbegin



	pop	%es

/*
	mov	$0x0F,%ah
	int	$0x10
// AL = video mode, AH = #columns, BH = active page

	mov	$0x0012,%ax # set video mode to mode 12h
// http://www.minuszerodegrees.net/video/bios_video_modes.htm
	int	$0x10

	xor	%cx,%cx
	xor	%dx,%dx
	mov	$0x0C00,%ax
.Ltry_video_bios:
	int	$0x10
//	inc	%al
	add	$1,%cx
	cmp	$640,%cx
	jb	0f
	xor	%cx,%cx
	add	$1,%dx
	cmp	$480,%dx
	jb	0f
	xor	%dx,%dx
	inc %al
0:
	jmp	.Ltry_video_bios
*/
	ret

draw_uint16_hex: # Assumes %es:0x0000 points to video memory
/*
	@param AX value
	@param CX X
	@param DX Y
*/

	data32 pusha

	push	%ax

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

	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx
	shr	$4,%ax

	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx
	shr	$4,%ax

	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx
	shr	$4,%ax

	mov	%ax,%cx
	and	$0x000f,%cx
	push	%cx
	shr	$4,%ax

//Stack now holds the digits as words in order to be drawn

	pop	%ax
	call	draw_helper
	add	$6,%di
	pop	%ax
	call	draw_helper
	add	$6,%di
	pop	%ax
	call	draw_helper
	add	$6,%di
	pop	%ax
	call	draw_helper

	data32 popa
	ret

draw_helper:
//	%es:(%di) points to the top right corner of the current digit
//	%al is the digit we are printing
//	clobbers %ax, %bx, %edx, %si
//	assumes %ds == 0
	mov	$(5*9),%cl
	mul	%cl
	mov	%ax,%bx
	mov	$digit0,%si
//	now %ax is the byte index after digit0 we are looking for
.macro row n
	mov	%ds:(\n*5)(%bx,%si),%edx
	mov	%edx,%es:(\n*320)(%di)
	mov	%ds:(\n*5+4)(%bx,%si),%dl
	mov	%dl,%es:(\n*320+4)(%di)
.endm
	ROW 0
	ROW 1
	ROW 2
	ROW 3
	ROW 4
	ROW 5
	ROW 6
	ROW 7
	ROW 8


	ret

install_kb_hdlr:
	push	%eax
	mov	$kb_hdlr,%eax
	cli
	mov	%eax,0x24 # interrupt vector 9
	sti
	pop	%eax
	ret

kb_hdlr:
	data32 pusha

	in	$0x60,%al
	test	$0x80,%al
	jnz	0f
//	mov	%al,color
	shlb	color
	test	$1,%al
	setnz	%al
	orb	%al,color
	clc
0:
	// EOI
	mov	$0x61,%al
	out	%al,$0x20

	data32 popa
	iret

simd_setup: # https://wiki.osdev.org/SSE#Adding_support
	mov	%cr0,%eax
	and	$0xFFFB,%ax
	or	$0x0002,%ax
	mov	%eax,%cr0

	mov	%cr4,%eax
	or	$0x0600,%ax
	mov	%eax,%cr4

	ret

	.section ".data16","a"
.LC0:
	.string "This is printed from main running in RAM."
color:
	.byte 0

	.section ".text16","a"
	.globl	puts
/*
	@param DS:SI string
	clobbers AX
*/
puts:
	lodsb
	test	%al,%al
	jz	.Lputs_end
	cmp	$'\n',%al
	je	.Lputs_newline
	mov	$0x0E,%ah
	int $0x10
	jmp	puts
.Lputs_newline:
	mov	$0x0E00+'\r',%ax
	int $0x10
	mov	$0x0E00+'\n',%ax
	int $0x10
	jmp puts
.Lputs_end:
	mov	$0x0E00+'\r',%ax
	int $0x10
	mov	$0x0E00+'\n',%ax
	int $0x10
	ret

	.section ".data16","a"
digit0:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digit1:
	.byte  0, 0,15, 0, 0
	.byte  0,15,15, 0, 0
	.byte 15, 0,15, 0, 0
	.byte  0, 0,15, 0, 0
	.byte  0, 0,15, 0, 0
	.byte  0, 0,15, 0, 0
	.byte  0, 0,15, 0, 0
	.byte  0, 0,15, 0, 0
	.byte 15,15,15,15,15
digit2:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0,15, 0
	.byte  0, 0,15, 0, 0
	.byte  0,15, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15,15
digit3:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0,15,15,15, 0
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digit4:
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15,15,15,15,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
digit5:
	.byte 15,15,15,15,15
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15, 0
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digit6:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digit7:
	.byte 15,15,15,15,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
digit8:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digit9:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15,15
	.byte  0, 0, 0, 0,15
	.byte  0, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digitA:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15,15,15,15,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
digitB:
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15,15,15,15, 0
digitC:
	.byte  0,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0,15
	.byte  0,15,15,15, 0
digitD:
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15, 0, 0, 0,15
	.byte 15,15,15,15, 0
digitE:
	.byte 15,15,15,15,15
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15,15
digitF:
	.byte 15,15,15,15,15
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15,15,15,15, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
	.byte 15, 0, 0, 0, 0
digitEnd:
