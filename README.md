# x16-music-player
Simple way to try out the YM2151 sound chip and Vera PSG on the Commander X16


## What it does
The X16 program "PLAYER.PRG" will play music from a file called MUSIC.SP. Currently, MUSIC.SP is loaded into high ram, and it cycles through the banks, so MUSIC.SP must fit into however much high ram is available.
To run the player you can do the following.
> x16emu -prg PLAYER.PRG -run

Also included is a python script spconvert.py.  This script converts human readable text files, such as the included music.spt file, into a file that can be read by the program.
Here is a command to convert the included music.spt to MUSIC.SP
>python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

Noticed the -mode flag.  This can be set to hex or dec to read in numbers as either hexidecimal or decimal depending on what you would prefer.

## Building and Running the Player

Running make should generate the program and test music files needed to run this in the X16 emulator.
>make

There are additional options in the makefile to make things easier.  If you have the emulator in a folder called bin located in the parent directory of the player, the following will work to run the player.
>make run

## File format
The spt file format consists of a list of writes to the YM2151 and Vera PSG to be executed on one frame followed by a number of frames to wait.  Each frame is triggered by vsync on the X16.  All numbers are one byte, so they may be between 0 and 255.
Comments can be added by semicolon.  The following is using decimal values.
```
6       ; First line is the number of YM2151 writes this frame.
32, 215 ; This is a write to the YM2151, (REG, DATA)
40, 80  ; write 80 to reg 40
96, 7   ; write 7 to reg 96
128, 24	; write 24 to reg 128
224, 5	; write 5 to reg 224
8, 8    ; write 8 to reg 8
0		; Number of PSG writes this frame
128     ; Since we have defined all writes for the first frame, this is the number of frames to delay before the next write
1       ; Do 1 write to YM2151
40, 244 ; write 244 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 244 ; write 244 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
1       ; Do 1 write
40, 100 ; write 100 to reg 40
0		; Do 0 writes to PSG
10      ; wait 10 frames
2		; write twice to YM2151
40, 0	; Turn off channel 0
41, 0	; Turn off channel 1
0		; Write 0 times to PSG
10		; wait 10 frames
0		; Do 0 writes to YM2151
4		; Do 4 writes to PSG
0, 157	; Write 157 to low byte of channel 0 frequency
1, 4	; write 4 to high byte of channel 0 frequency
2, 255	; set channel 0 to full volume on L and R
3, 128	; set channel 0 to triangle wave
100		; wait 100 frames
0		; Do 0 writes to YM2151
1		; Do 1 write to PSG
1, 1	; Write 1 to the high byte of channel 0 frequency
20		; wait 20 frames
0		; Do 0 writes to YM2151
1		; Do 1 write to PSG
1, 4	; Write 4 to the high byte of channel 0 frequency
20		; wait 20 frames
0		; Do 0 writes to YM2151
1		; Do 1 write to PSG
1, 1	; Write 1 to the high byte of channel 0 frequency
20		; wait 20 frames
0		; Do 0 writes to YM2151
1		; Do 1 write to PSG
1, 4	; Write 4 to the high byte of channel 0 frequency
20		; wait 20 frames
0       ; Do 0 writes to YM2151
0		; Do 0 writes to PSG, this is interpreted as end of file when 0 writes is done to each
```
