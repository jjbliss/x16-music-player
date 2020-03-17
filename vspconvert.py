import sys
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
	description='Converts text vspt file into a data vsp file.\n\n'
	'Examples:\n\n'
	'spconvert.py -i music.vspt -i MUSIC.VSP\n'
	'Read the file music.vspt and output a usable VSP binary file\n\n')
parser.add_argument('-i', help='the input filename')
parser.add_argument('-o', default='MUSIC.VSP', help='the output filename')
args = parser.parse_args()


fileOut = open(args.o, "wb")
arrayOut = [0,0]

with open(args.i, "r") as fileIn:
	f1 = fileIn.readlines()
	for x in f1:
		x = x.split(";")
		x = x[0] # remove any comments
		x = x.strip(" ")
		x = x.strip("\t")
		x = x.strip("\n")
		parts = x.split(":")
		if(len(parts) > 1):
			if((len(parts) != 5 )and (len(parts) != 6 )):
				print("ERROR, bad formatting")
				exit()
			channel = int(parts[0])
			pitch = int(parts[1])
			lr = parts[2]
			volume = int(parts[3])
			wave = int(parts[4])
			if(len(parts)==6):
				pulse = int(parts[5])
			else:
				pulse = 0
			arrayOut.append(channel)
			low = pitch & 255
			high = (pitch >> 8) & 255
			arrayOut.append(low)
			arrayOut.append(high)
			volume = volume & 63
			if(lr == "N"):
				volume = volume
			elif(lr == "L"):
				volume = volume | 128
			elif(lr == "R"):
				volume = volume | 64
			elif(lr == "LR"):
				volume = volume | 192
			arrayOut.append(volume)
			pulse = pulse & 63
			if(wave == 0):
				pulse = pulse
			elif(wave == 1):
				pulse = pulse | 64
			elif(wave == 2):
				pulse = pulse | 128
			elif(wave == 3):
				pulse = pulse | 192
			arrayOut.append(pulse)

		else:
			for j in parts:
				j = int(j)
				arrayOut.append(j)

fileOut.write(bytearray(arrayOut))
