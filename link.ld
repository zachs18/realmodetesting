SECTIONS {
	. = 0x7C00;
	.text : {
		* (.text.entry);
		* (.text);
	}

	. = 0x7DFE;
	.signature : {
		SHORT(0xaa55);
	}
}
