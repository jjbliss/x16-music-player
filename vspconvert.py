import sys
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
	description='Converts text vspt file into a data vsp file.\n\n'
	'Examples:\n\n'
	'spconvert.py -i music.vspt -i MUSIC.VSP\n'
	'Read the file music.vspt and output a usable VSP binary file\n\n')
parser.add_argument('-i', help='the input filename')
parser.add_argument('-o', default='MUSIC.VSP', help='the output filename')
parser.add_argument('-mode', default='dec', help='can be set to hex or dec')
args = parser.parse_args()

mode = args.mode

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
		parts = x.split(",")
		for j in parts:
			if(mode == "hex"):
				j = int(j,16)
				if(j > 255):
					low = j & 255
					high = (j >> 8) & 255
					arrayOut.append(low)
					arrayOut.append(high)
				else:
					arrayOut.append(j)
			if(mode == "dec"):
				j = int(j)
				if(j > 255):
					low = j & 255
					high = (j >> 8) & 255
					arrayOut.append(low)
					arrayOut.append(high)
				else:
					arrayOut.append(j)

fileOut.write(bytearray(arrayOut))
