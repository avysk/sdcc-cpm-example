SOURCES = main.c greet.c

REL = ${SOURCES:.c=.rel}

SDCC_FLAGS = -mz80 --std-c23

all: main.com

crt0.rel: crt0.s
	sdasz80 -g -l -o crt0.rel crt0.s

%.rel: %.c
	sdcc ${SDCC_FLAGS} -c $<

main.ihx: crt0.rel ${REL}
	sdcc ${SDCC_FLAGS} --no-std-crt0 $< ${REL} -o $@

main.com: main.ihx
	objcopy -I ihex -O binary $< $@

clean:
	rm -f *.rel *.ihx *.com *.lk *.map *.noi *.asm

.PHONY: all clean
