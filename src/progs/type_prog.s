	.code16
	.section ".text16","a"
	.global type_prog
	.type	type_prog,@function
type_prog:
	.cfi_startproc

	data32 pusha

	mov	$0x20,%ax
	mov	$0x20,%cx # X
	mov	$0x20,%dx # Y
	mov	$0x20,%si # W
	mov	$0x20,%di # H
	call draw_rectangle

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
	hlt
	hlt
	hlt

	data32 popa

	jmp	menu

	.cfi_endproc
	.size type_prog, . - type_prog
