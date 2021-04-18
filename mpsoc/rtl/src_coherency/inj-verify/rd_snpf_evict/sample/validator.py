#! /usr/bin/env python
"""
A skeleton python script which reads from an input file,
writes to an output file and parses command line arguments
"""
from __future__ import print_function
import sys
import argparse
import binascii

EVENTS=["MISS","WAIT","WAIT_FOR"]

MAP_REQID={}

class bcolors:
	HEADER = '\033[95m'
	OKBLUE = '\033[94m'
	OKGREEN = '\033[92m'
	WARNING = '\033[93m'
	FAIL = '\033[91m'
	ENDC = '\033[0m'
	BOLD = '\033[1m'
	UNDERLINE = '\033[4m'

def printError(_str):
	global errors
	errors += 1
	print(bcolors.FAIL + _str + bcolors.ENDC)

def printWarning(_str):
	global warnings
	warnings += 1
	print(bcolors.WARNING + _str + bcolors.ENDC)	

def printGood(_str):
	print(bcolors.OKGREEN + _str + bcolors.ENDC)	

def filterLine(line):
	# Filter: remove end ogf line
	line = line.replace("\n", "")
	# get list of strings
	line = line.split(' ')
	#print(line)
	return line

# Event Id: Cycle CPU ID WAIT cycles instructions
# Event Id: Cycle CPU ID WAIT FOR Req Id Address
# Event Id: Cycle CPU ID MISS Req Id @ D/I LD/ST [X/E] 
#
#
#

def checkEvent(event,currentReqId):
	if event[0][0] == "[" or event[0][0] == "P":
		return currentReqId
	elif event[0] == EVENTS[0]:
		return checkMiss(event,currentReqId)#print(EVENTS[0])
	elif event[0] == EVENTS[1] :
		return checkWait(event,currentReqId)#print(EVENTS[1])
	else: #EVENT[2]
		return checkWaitFor(event,currentReqId)#print(EVENTS[2])




def checkWait(event,currentReqId):
	# check if it has size 5
	error=0
	if (len(event) != 4):
		printError("ERROR: Size of WAIT != 4 : "+str(len(event)))
		error+=1

	if (int(event[1]) < 0):   
		printError("ERROR: WAIT Format error #Cycles : " + event[1])  
		error+=1

	if (int(event[2]) < 0):   
		printError("ERROR: WAIT Format error #Instr committed : "+ event[2])
		error+=1

	if (int(event[3]) < 0):   
		printError("ERROR: WAIT Format error #Instr committed : "+ event[3])
		error+=1

	return currentReqId,error

def checkWaitFor(event,currentReqId):
	error=0
	# check if it has size 5
	if (len(event) != 3):
		printError("ERROR: Size of WAIT FOR != 3 : " + str(len(event)))
		error+=1
	if (not int(event[1]) in MAP_REQID):
		printError("ERROR: WAIT FOR of req id without MISS")
		error+=1
	#if (int(event[1]) < 4194200 and int(event[1]) > currentReqId):
	#	printError("ERROR: WAIT FOR req id before miss of that req id : " + event[1])
	#		error+=1 
	elif (int(event[1]) < 0):   
		printWarning("WARNING: WAIT FOR reqId not found : " + event[1])
		error+=1
	else:
		if (MAP_REQID[int(event[1])] != event[2]):
			printError("ERROR: WAIT FOR Address don't match: " + event[2])
			error+=1
	if (int(event[1]) in MAP_REQID):
		del MAP_REQID[int(event[1])]
		

	return currentReqId,error

def checkMiss(event,currentReqId):
	error=0
	# check if it has size 5 or 6 
	if (len(event) != 5 and len(event) != 6):
		printError("ERROR: Size of MISS != 5|6 : " + str(len(event)))
		error+=1

	#if (int(event[1]) == 0 and len(event) == 6 and event[6]=="X"):   
#		a = 0


	#Check req id is one bigger than the old one?
	if (int(event[1]) == 0):   
		b = 0
		#printWarning("WARNING: MISS Format warning Req Id :  " + event[4])
	elif int(event[1]) < currentReqId:
		printError("ERROR: MISS Format error Req Id : " + event[1])
		print(event)
		error+=1

	else:
		if int(event[1])==4194303:
			currentReqId=0
		else:
			currentReqId=int(event[1])	
	
	#Check @
	if (event[2][0]!="0" and event[2][1]!="X"):   
		printError("ERROR: MISS Format error @ : " + event[3])
		error+=1
	else: 
		#TODO Check repeated????
		MAP_REQID[int(event[1])] = event[2]	
	
	#Check D|I
	if (event[3]!="D" and event[3]!="I"):   
		printError("ERROR: MISS Format error D|I : " + event[4])
		error+=1
	
	#Check LD|ST
	if (event[4]!="LD" and event[4]!="ST"):   
		printError("ERROR: MISS Format error LD|ST : " + event[5])
		error+=1
	
	#Check last thing is E|X
	if (len(event)==6 and (event[5]!="E" and event[5]!="X")):   
		printError("ERROR: MISS Format error E|X: " + event[6])
		error+=1
	  
	return currentReqId,error

def main():
	parser = argparse.ArgumentParser(description=__doc__)

	parser.add_argument(
	"trace", nargs="?", default="-",
	metavar="INPUT_FILE", type=argparse.FileType("r"),
	help="path to the input file (read from stdin if omitted)")

	# parser.add_argument(
	#	"output", nargs="?", default="-",
	#	metavar="OUTPUT_FILE", type=argparse.FileType("w"),
	#	help="path to the output file (write to stdout if omitted)")
	args = parser.parse_args()
	currentReqId = 0
	coreId = -1 #TODO Improve this
	lastCycle = 0
	global errors
	errors = 0
	global warnings
	warnings = 0
	global MAP_REQID
	print( bcolors.HEADER + "[CHECKING]: " + str(sys.argv[1]) + bcolors.ENDC) 
	print( bcolors.OKBLUE + "[FILTERING]" + bcolors.ENDC) 
	
	mode_binary = "bin" in args.trace.name
	if (mode_binary):
		#name = args.trace.name + ".fixed" 
		#with open(name, "wb") as file_fixed:
			with open(args.trace.name, "rb") as f:
				byte = f.read(8)
				#print(byte)

				while byte:
					# Do stuff with byte.
					#aux = ord(byte)
					# Given raw bytes, get an ASCII string representing the hex values
					bits_array = ''.join(format(b, '08b') for b in byte)
					#bytes_as_bits2 = ''.join(format(b, '08b')[::-1] for b in byte)
					#print(bits_array)
					line = ""
					reqId = int(bits_array[0:22],2)
					
					commSveInstr = int(bits_array[1:10],2)
					commInstr = int(bits_array[11:22],2)
					#print(bits_array[0:22])
					#print(reqId)
					addr = int(bits_array[23:56],2)
					#print(hex(addr))
					opc = int(bits_array[57:59],2)
					#print(opc)
					excl = int(bits_array[59],2)
					#print(excl)
					st = int(bits_array[60],2)
					#print(st)
					OpCode = int(bits_array[61:64],2)
					#print(bits_array[61:64])
					#print(OpCode)

					if (OpCode==0 or OpCode==1):
						line+="MISS "+str(reqId)+" "+str(hex(addr))
						line+=" "+("D"if OpCode==0 else "I")
						line+=" "+("ST"if st else "LD")
						#print(line)

					elif (OpCode==2):
						line+="MISS "+str(reqId)+" "+str(hex(addr))
						line+=" D ST E"
						#print(line)

					elif (OpCode==4):
						line+="WAIT_FOR "+str(reqId)+" "+str(hex(addr))
						#print(line)

					elif (OpCode==5):
						line+="WAIT "+str(addr)+" "+str(commInstr)+" "+str(commSveInstr)
						#print(bits_array[0:22])
						#print(line)
					event = filterLine(line)
					print(event)
					currentReqId,error = checkEvent(event,currentReqId)
					#if (error<1):
					#	file_fixed.write(byte)
					#print(line.strip(), file=args.output)
					byte = f.read(8) 
					if (errors > 400):
						sys.exit()

				print( bcolors.OKBLUE + "[DONE]" + bcolors.ENDC)
					#print(MAP_REQID)
				if (errors):
					printError(bcolors.OKBLUE + "[RESULT]: " + bcolors.ENDC + bcolors.FAIL + "ERRORS: "+str(errors))
				else:
					printGood(bcolors.OKBLUE + "[RESULT]: " + bcolors.ENDC + bcolors.OKGREEN + "ERRORS: 0")	
				
				#print(bytes_as_bits2)
				#for i in range (0,64):
				#	print(str(i)+": "+bytes_as_bits2[i])
				#hex_data = binascii.hexlify(byte)  # Two bytes values 0 and 255
				#print("{0:b}".format(hex_data))
				# The resulting value will be an ASCII string but it will be a bytes type
				# It may be necessary to decode it to a regular string
				#text_string = hex_data.decode('utf-8')  # Result is string "00ff"

				#base64_data = binascii.b2a_base64(byte)
				#print(base64_data)

				# The base64_string is still a bytes type
				# It may need to be decoded to an ASCII string
				#print(base64_data.decode('utf-8'))
				#print(text_string)

				#i = ord(a_byte)
				#print("{0:b}".format(aux))
				#print('{0:08b}'.format(ord(byte[0])))
				
				#f.read(8)
				
	
	else:
	
		for line in args.trace:
			event = filterLine(line)
			#print(event)
			currentReqId,coreId,lastCycle = checkEvent(event,currentReqId,coreId,lastCycle)
			#print(line.strip(), file=args.output)
			if (errors > 400):
				sys.exit()
		print( bcolors.OKBLUE + "[DONE]" + bcolors.ENDC)
		#print(MAP_REQID)
		if (errors):
			printError(bcolors.OKBLUE + "[RESULT]: " + bcolors.ENDC + bcolors.FAIL + "ERRORS: "+str(errors))
		else:
			printGood(bcolors.OKBLUE + "[RESULT]: " + bcolors.ENDC + bcolors.OKGREEN + "ERRORS: 0")	

if __name__ == "__main__":
	main()
