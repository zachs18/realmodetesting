
.PHONY: default clean
default: test.bin
clean:
	rm -rf *.o *.bin

OBJECTS = entry.o keymap.o

.PRECIOUS: $(OBJECTS)

%.o: %.s Makefile
	gcc -m16 $< -static -nostartfiles -nostdlib -c -o $@


#test.bin: $(OBJECTS) link.ld
#	#objcopy -O binary $< $@
#	#gcc -m16 $< -static -nostartfiles -nostdlib -Wl,--oformat=binary,-Ttext=0x7C00,-Tsignature=0x7DFE -o $@
#	gcc -m16 $(filter-out %.ld,$^) -static -nostartfiles -nostdlib -Wl,--oformat=binary,-Tlink.ld -o $@

test.bin.o: $(OBJECTS) link.ld
	#objcopy -O binary $< $@
	#gcc -m16 $< -static -nostartfiles -nostdlib -Wl,--oformat=binary,-Ttext=0x7C00,-Tsignature=0x7DFE -o $@
	gcc -m16 $(filter-out %.ld,$^) -static -nostartfiles -nostdlib -Wl,--build-id=none,-Tlink.ld -o $@

test.bin: test.bin.o
	objcopy $< -O binary $@

.PHONY: run
run: test.bin
	qemu-system-i386 -drive format=raw,file=test.bin
