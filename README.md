# x16-music-player
Simple way to try out the YM2151 sound chip on the X16


## What it does
This is an X16 program "PLAYER.PRG" that will play music from a file called MUSIC.SP.
Currently, MUSIC.SP is loaded into one bank of high ram, so the maximum supported file size is 8KB.
To run the player you can do the following.
> x16emu -prg PLAYER.PRG -run

Also included is a python script spconvert.py.  This script converts a human readable text file, such as the included music.spt file, into a file that can be read by PLAYER.PRG.  
Here is a command to convert the included music.spt to MUSIC.SP
>python3 spconvert.py -i music.spt -o MUSIC.SP -mode dec

Noticed the -mode flag.  This can be set to hex or dec to read in numbers as either hexidecimal or decimal depending on what you would prefer.

## Building and Running the Player

Running make should generate the PLAYER.PRG and MUSIC.SP files needed to run this in the X16 emulator.  This should work on any build of the emulator that has sound included.
>make

There are additional options in the makefile to make things easier.  If you have the emulator in a folder called bin located in the parent directory of the player, the following will work.
>make run

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
