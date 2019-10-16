all: PLAYER.PRG MUSIC.SP

PLAYER.PRG: player.asm
	acme player.asm

MUSIC.SP: music.spt
	python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

run: all
	../bin/x16emu -prg PLAYER.PRG -run


start: all
	../bin/x16emu -prg PLAYER.PRG


clean:
	rm -f PLAYER.PRG MUSIC.SP
