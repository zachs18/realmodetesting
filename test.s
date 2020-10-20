# https://stackoverflow.com/a/5268120/5142683

	.code16
_start:
	mov	$0x8000,%sp
	xor	%ax,%ax
	mov	%ax,%ds
	mov	$msg,%si
//	add	$0x7c00,%si
print_loop:
	lodsb
	test	%al,%al
	jz	end_print_loop
	mov	$0xE,%ah
	int	$0x10
	jmp	print_loop

end_print_loop:
	xor	%eax,%eax
	mov	$keyboard_handler,%ax
//	add	$0x7c00,%ax
	cli
	mov	%eax,0x24 # interrupt vector 9 offset
	sti

end:
	jmp	end

print_uint16:
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

print_newline:
	mov	$0x0E00+'\r',%ax
	int	$0x10
	mov	$0x0E00+'\n',%ax
	int	$0x10
	ret

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
	call	print_uint16
	call	print_newline
	pop	%bx
	movb	(%bx),%al

	# print integer value of ASCII code
	xor	%ah,%ah
	push	%ax
	call	print_uint16
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

keymap:
# http://inglorion.net/documents/tutorials/x86ostut/keyboard/us_keymap.inc
	.ascii	"\x00\x1b", "1234567890-=\x08\x09" # GNU AS interprets \x1b123456789 all as one char
	.ascii	"qwertyuiop[]\r\x00", "as"
	.ascii	"dfghjkl;'`\x00\\zxcvb" # LShift is \x00
	.ascii	"nm,./\x00*\x00 "
//	.zero 7
//	.zero 64

//	.ascii	"0123456789abcdef"
//	.ascii	"ghijklmnopqrstuv"
//	.ascii	"wxyzABCDEFGHIJKL"
//	.ascii	"MNOPQRSTUVWXYZ,."
//	.ascii	"~!@#$%^&*()_+-=`"
//	.ascii	"[]{}\|;:'\"<>?/  "
/*
	0:
	1: Escape
	2-10: 1-9
	11: 0
	12: -
	13: =
	14: Backspace
	15: Tab

	16-27: qwertyuiop[]
	28: Return (and Keypad Return)
	29: Ctrl
	30-40: asdfghjkl;'
	41: `
	42: LShift
	43: \

	44-53: zxcvbnm,./ (53 is also Keypad /)
	54: RShift
	55: (Keypad) *
	56: Alt
	57: Space
	58: Caps Lock
	

*/
msg:
	.string "Hello, World!\r\n"

