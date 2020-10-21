SECTIONS {
	. = 0x7C00;
	.boot_text : {
		* (.boot_entry);
		* (.boot_text);
	}

	.boot_data : {
		* (.boot_data);
	}

	.boot_rodata : {
		* (.boot_rodata);
	}

	. = 0x7DFE;
	.signature : {
		SHORT(0xaa55);
	}
}
