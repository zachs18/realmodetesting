# https://stackoverflow.com/a/5268120/5142683

	.section ".boot_entry","a"
	.code16
	.globl	_start
_start:
	cli
	mov	$0x7000,%ax
	mov	%ax,%ss
	mov	$0xFFF0,%sp
	sti
	xor	%ax,%ax
	mov	%ax,%ds
	mov	$boot_msg,%si
//	add	$0x7c00,%si
.Lprint_loop:
	lodsb
	test	%al,%al
	jz	.Lend_print_loop
	mov	$0xE,%ah
	int	$0x10
	jmp	.Lprint_loop

.Lend_print_loop:
	xor	%eax,%eax
	mov	$keyboard_handler,%ax
//	add	$0x7c00,%ax
	cli
	mov	%eax,0x24 # interrupt vector 9 offset
	sti

	mov	$text16_sectorcount,%ax
	call boot_print_uint16
	call print_newline

.Linit_memory:
	mov	$text16_start,%bx
	mov	$text16_sectorcount,%al
	mov	$0x0002,%cx
	mov	$0x0080,%dx
	call	boot_disk_read

	call main

.Lend:
	hlt
	jmp	.Lend

	.section ".boot_rodata","a"
boot_msg:
	.string "Hello, World!\r\n"


	.section ".boot_text", "a"
	.globl	boot_print_uint16
boot_print_uint16:
	# takes unsigned short in %ax and prints it
	# clobbers %dx, %cx
	test %ax,%ax
	jnz	1f
# zero
	mov	$0x0E00+'0',%ax
	int	$0x10
	ret
1:
	pushw	$0
.Lloop:
	xor	%dx,%dx
	mov	$10,%cx
	div	%cx
	add	$0x0E00+'0',%dx
	push	%dx
	test	%ax,%ax
	jnz	.Lloop
.Lprint:
	pop	%ax
	test	%ax,%ax
	jz	0f
	int	$0x10
	jmp	.Lprint
0:
	ret

	.section ".boot_text", "a"
	.globl	print_newline
print_newline:
	mov	$0x0E00+'\r',%ax
	int	$0x10
	mov	$0x0E00+'\n',%ax
	int	$0x10
	ret


	.section ".boot_text", "a"
	.globl	keyboard_handler
keyboard_handler:
# http://inglorion.net/documents/tutorials/x86ostut/keyboard/
	pusha # push all registers

	in	$0x60,%al # read code into %al

	test 	$0x80,%al
	jnz	0f # don't handle high-bit-set codes

	# read ASCII code from table
	xor	%ah,%ah
//	mov	$0x7c00,%bx
//	add	$keymap,%bx
	mov	$keymap,%bx
	add	%ax,%bx
	push	%bx
	call	boot_print_uint16
	call	print_newline
	pop	%bx
	movb	(%bx),%al

	# print integer value of ASCII code
	xor	%ah,%ah
	push	%ax
	call	boot_print_uint16
	call	print_newline
	pop	%ax

	# Print code
	mov	$0xE,%ah
	int	$0x10
	call	print_newline
0:
	# send EOI (End Of Interrupt)
	mov	$0x61,%al
	out	%al,$0x20
	# return
	popa
	iret



