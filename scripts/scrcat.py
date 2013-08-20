import os
import sys
import re

dirname = sys.argv[1]

files = [f for f in os.listdir(dirname) if re.match(r'\d+\.scr', f)]
files.sort()

for filename in files:
	f = open(os.path.join(dirname, filename))
	sys.stdout.write(f.read())
	sys.stdout.write("\0" * 256)
	f.close
