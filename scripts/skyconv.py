infile = open('images/sky.im8', 'rb')
outfile = open('build/sky.bin', 'wb')

infile.seek(416)
instr = infile.read(256*6)
outfile.write(instr)

instr = infile.read(256*2)
instr = instr.replace("\x6b", "\x6d")
outfile.write(instr)

infile.close()
outfile.close()
