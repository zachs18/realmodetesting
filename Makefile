
.PHONY: default clean
default: test.bin
clean:
	rm -rf *.o *.bin

.PRECIOUS: %.o

%.o: %.s
	gcc -m16 $< -static -nostartfiles -nostdlib -c -o $@


%.bin: %.o
	#objcopy -O binary $< $@
	#gcc -m16 $< -static -nostartfiles -nostdlib -Wl,--oformat=binary,-Ttext=0x7C00,-Tsignature=0x7DFE -o $@
	gcc -m16 $< -static -nostartfiles -nostdlib -Wl,--oformat=binary,-Tlink.ld -o $@

.PHONY: run
run: test.bin
	qemu-system-i386 -drive format=raw,file=test.bin
