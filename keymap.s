	.section ".rodata", "a"
	.globl	keymap
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
