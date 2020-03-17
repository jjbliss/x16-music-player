# x16-music-player
Simple way to try out the YM2151 sound chip and Vera PSG on the Commander X16


## What it does
There are two X16 programs "YMPLAYER.PRG" and "VERAPLAYER.PRG" that will play music from a file called MUSIC.SP and MUSIC.VSP respectively.
Currently, MUSIC.SP is loaded into high ram, and it cycles through the banks, so MUSIC.SP must fit into however much high ram is available.
To run the player you can do the following.
> x16emu -prg YMPLAYER.PRG -run

or
> x16emu -prg VERAPLAYER.PRG -run

Also included are python scripts spconvert.py and vspconvert.py.  These scripts convert human readable text files, such as the included music.spt and veramusic.vspt files, into a file that can be read by the programs.
Here is a command to convert the included music.spt to MUSIC.SP
>python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

>python3 spconvert.py -i veramusic.vspt -o MUSIC.VSP -mode dec

Noticed the -mode flag.  This can be set to hex or dec to read in numbers as either hexidecimal or decimal depending on what you would prefer.

## Building and Running the Player

Running make should generate the program and test music files needed to run this in the X16 emulator.
>make

There are additional options in the makefile to make things easier.  If you have the emulator in a folder called bin located in the parent directory of the player, the following will work to run the player.
>make runym

>make runvera

## File format
The spt file format consists of a list of writes to the YM2151 to be executed on one frame followed by a number of frames to wait.  Each frame is triggered by vsync on the X16.  All numbers are one byte, so they may be between 0 and 255.
Comments can be added by semicolon.  The following is using decimal values.
```
6       ; First line is the number of writes this frame.
32, 215 ; This is a write to the YM2151, (REG, DATA)
40, 80  ; write 80 to reg 40
96, 7   ; write 7 to reg 96
128, 24	; write 24 to reg 128
224, 5	; write 5 to reg 224
8, 8    ; write 8 to reg 8
128     ; Since we have done 6 writes, this is the number of frames to delay before the next write
1       ; Do 1 write
40, 244 ; write 244 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
10      ; wait 10 frames
0       ; Do 0 writes, this is interpreted as end of file and will stop the player
```
For the VERA PSG player, the vspt format is very similar.  Refer to the Vera programming reference for details on the four bytes used in each channel definition.
```
1 ; modify one channel
0 ; PSG channel
1181 		; Pitch
0			; volume and LR channels off
128 		; triangle wave
100 ; wait for this many frames
1	; modify 1 channel
0 ; PSG channel
1181 		; Pitch
255			; Right left and full volume
128 		; triangle wave
255 ; wait for this many frames
2 ; num channels this frame
0 ; PSG channel
1181 		; Pitch
0			; off
128 		; triangle wave
1 ; channel
2181 		; Pitch
255			; volume and LR select
128 		; wave
255 ; wait for this many frames
1 ; num channels this frame
0 ; channel
1181 		; Pitch
255			; volume and LR select
64 			; wave
255 ; wait for this many frames
1 ; num channels this frame
0 ; channel
1181 		; Pitch
255			; volume and LR select
128 		; wave
255 ; wait for this many frames
0 ; end file
```
