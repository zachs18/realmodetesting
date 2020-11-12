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

	mov	$0x0013,%ax # set video mode to mode 13h (320x200 256 colors)
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

	mov	$.LC0,%ax
	mov	$180,%dx
	mov	$(6*9),%cx
	call	draw_str

	call install_kb_hdlr

.Lbegin:
	xor	%di,%di
	mov	color,%ax
	mov	$180,%dx
	mov	$0,%cx
	call	draw_uint16_hex

	add	$(6*5),%cx
	mov	$'"',%ax
	call	draw_char

	add	$6,%cx
	mov	color,%ax
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
	mov	color,%ax
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

draw_str: # Assumes %es:0x0000 points to video memory
/*
	@param AX str
	@param CX X
	@param DX Y
*/
	data32 pusha

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

	data32 popa
	ret

draw_char: # Assumes %es:0x0000 points to video memory
/*
	@param AL char
	@param CX X
	@param DX Y
*/
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

	mov	$2,%cl

	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	digits(%bx),%si
	call	draw_helper

	add	$6,%di
	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	digits(%bx),%si
	call	draw_helper

	add	$6,%di
	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	digits(%bx),%si
	call	draw_helper

	add	$6,%di
	pop	%ax
	mul	%cl
	mov	%ax,%bx
	mov	digits(%bx),%si
	call	draw_helper

	data32 popa
	ret

draw_helper:
//	%es:(%di) points to the top right corner of the current digit
//	%ds:(%si) points to the 45-byte (5x9) character to draw
//	clobbers %edx
.macro row n
	mov	%ds:(\n*5)(%si),%edx
	mov	%edx,%es:(\n*320)(%di)
	mov	%ds:(\n*5+4)(%si),%dl
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
	mov	$kb_hdlr_1,%eax
	cli
	mov	%eax,0x24 # interrupt vector 9
	sti
	pop	%eax
	ret

kb_hdlr_1:
	data32 pusha

	in	$0x60,%al
	test	$0x80,%al
	jnz	0f
	cmp	$1,%al
	je	.Lswitch_to_kb_hdlr2
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
.Lswitch_to_kb_hdlr2:
	push	%eax
	mov	$kb_hdlr_2,%eax
	mov	%eax,0x24 # interrupt vector 9
	mov	$0x2000,%ax
	mov	%ax,color
	pop	%eax
	jmp	0b

kb_hdlr_2:
	data32 pusha

	in	$0x60,%al
	test	$0x80,%al
	jnz	0f
	cmp	$1,%al
	je	.Lswitch_to_kb_hdlr1
	cmp	$10,%al # scan codes for 1-9 are 2-10
	ja	.Lharder
	sub	$1,%al
	jmp	.Lal_assigned
.Lharder:
	xor	%ah,%ah

2:	cmp	$30,%al # scan code for a
	jne	2f
	mov	$0xa,%ah
2:	cmp	$48,%al # scan code for b
	jne	2f
	mov	$0xb,%ah
2:	cmp	$46,%al # scan code for c
	jne	2f
	mov	$0xc,%ah
2:	cmp	$32,%al # scan code for d
	jne	2f
	mov	$0xd,%ah
2:	cmp	$18,%al # scan code for e
	jne	2f
	mov	$0xe,%ah
2:	cmp	$33,%al # scan code for f
	jne	2f
	mov	$0xf,%ah
2:

	mov	%ah,%al

.Lal_assigned:
//	mov	%al,color
	shlb	$4,color
	orb	%al,color
0:
	// EOI
	mov	$0x61,%al
	out	%al,$0x20

	data32 popa
	iret
.Lswitch_to_kb_hdlr1:
	push	%eax
	mov	$kb_hdlr_1,%eax
	mov	%eax,0x24 # interrupt vector 9
	mov	$0x1000,%ax
	mov	%ax,color
	pop	%eax
	jmp	0b


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
	.word 0x1000

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
digits:
digit0:	.word	char_048
digit1:	.word	char_049
digit2:	.word	char_050
digit3:	.word	char_051
digit4:	.word	char_052
digit5:	.word	char_053
digit6:	.word	char_054
digit7:	.word	char_055
digit8:	.word	char_056
digit9:	.word	char_057
digitA:	.word	char_065
digitB:	.word	char_066
digitC:	.word	char_067
digitD:	.word	char_068
digitE:	.word	char_069
digitF:	.word	char_070
digitEnd:
