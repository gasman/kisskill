import os
import re
from deltacompress import Region, write_deltas

dirname = 'assets/screens/jules-vsplit'
files = [
	os.path.join(dirname, f)
	for f in os.listdir(dirname)
	if re.match(r'\d+\.scr', f)
]
files.sort()

# odd-numbered ones only
files = [f for (i, f) in enumerate(files[4:20])]  # if i % 2 == 1]

regions = [
	Region(0, 0, 8, 12),  # x, y, w, h
	Region(0, 12, 8, 12),  # x, y, w, h
]

write_deltas(files, regions, initial_state=999)
