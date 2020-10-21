#CFLAGS := -m16 -static -nostdlib -nostartfiles
CFLAGS := -static -nostdlib -nostartfiles

OBJECTS = entry.o keymap.o disk.o

.PHONY: default clean
default: test.bin
clean:
	rm -rf *.o *.bin

.PRECIOUS: $(OBJECTS)

%.o: %.s Makefile
	$(CC) $(CFLAGS) $< -c -o $@

test.bin.o: $(OBJECTS) link.ld
	$(CC) $(CFLAGS) $(filter-out %.ld,$^) -Wl,--build-id=none,-Tlink.ld -o $@

test.bin: test.bin.o
	objcopy $< -O binary $@

.PHONY: run
run: test.bin
	qemu-system-i386 -drive format=raw,file=test.bin
