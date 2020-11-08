#CFLAGS := -m16 -static -nostdlib -nostartfiles
CFLAGS := -static -nostdlib -nostartfiles

OBJECTS = entry.o keymap.o disk.o main.o font.o

.PHONY: default clean
default: test.bin
clean:
	rm -rf *.o *.bin

.PRECIOUS: $(OBJECTS)

font.s: make_font_s.py
	python3 $^ > $@

%.o: %.s Makefile
	$(CC) $(CFLAGS) $< -c -o $@

test.bin.o: $(OBJECTS) link.ld
	$(CC) $(CFLAGS) $(filter-out link.ld,$^) -Wl,--build-id=none,-Tlink.ld -o $@

test.bin: test.bin.o
	objcopy $< -O binary $@

.PHONY: run
run: test.bin
	qemu-system-i386 -drive format=raw,file=test.bin
.PHONY: rundebug
rundebug: test.bin
	qemu-system-i386 -S -s -drive format=raw,file=test.bin
