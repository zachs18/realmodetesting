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

	.text16 : ALIGN(512) {
		text16_start = .;
		* (.text16);
		* (.data16);
		. = ALIGN(512);
		data16_end = .;
	}
	text16_sectorcount = ABSOLUTE( ( data16_end - text16_start ) / 512);
}
