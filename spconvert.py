import sys
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
	description='Converts text spt file into a data sp file.\n\n'
	'Examples:\n\n'
	'spconvert.py -i music.spt -i MUSIC.SP\n'
	'Read the file music.spt and output a usable SP binary file\n\n')
parser.add_argument('-i', help='the input filename')
parser.add_argument('-o', default='MUSIC.SP', help='the output filename')
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
				arrayOut.append(int(j,16))
			if(mode == "dec"):
				arrayOut.append(int(j))

fileOut.write(bytearray(arrayOut))
