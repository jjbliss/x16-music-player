X16EMU_PATH  := $(PWD)/../bin

all: YMPLAYER.PRG MUSIC.SP VERAPLAYER.PRG MUSIC.VSP

YMPLAYER.PRG: ymplayer.asm macros.inc
	acme ymplayer.asm

VERAPLAYER.PRG: veraplayer.asm macros.inc vera.inc
	acme veraplayer.asm


MUSIC.SP: music.spt
	python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

MUSIC.VSP: veramusic.vspt
	python3 vspconvert.py -i veramusic.vspt -o MUSIC.VSP -mode dec

runym: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG -run

runvera: all
	$(X16EMU_PATH)/x16emu -prg VERAPLAYER.PRG -run


debug: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG -run -debug


debugvera: all
	$(X16EMU_PATH)/x16emu -prg VERAPLAYER.PRG -run -debug


start: all
	$(X16EMU_PATH)/x16emu -prg PLAYER.PRG


clean:
	rm -f PLAYER.PRG MUSIC.SP VERAPLAYER.PRG MUSIC.VSP
