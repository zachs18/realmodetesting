	.code16
	.section ".text16","a"
	.globl	main
main:
	call	simd_setup

	xorps	%xmm0,%xmm0

	mov	$.LC0,%si
	call	puts
	ret

simd_setup: https://wiki.osdev.org/SSE#Adding_support
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
