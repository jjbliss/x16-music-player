X16EMU_PATH  := $(PWD)/../bin

all: PLAYER.PRG MUSIC.SP

PLAYER.PRG: player.asm
	acme player.asm

MUSIC.SP: music.spt
	python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

run: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG -run

debug: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG -run -debug


start: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG


clean:
	rm -f PLAYER.PRG MUSIC.SP
