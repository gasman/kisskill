import random

random.seed(44)


def randrect():
	while True:
		x1 = random.randrange(0, 32)
		x2 = random.randrange(0, 32)
		y1 = random.randrange(0, 24)
		y2 = random.randrange(0, 24)

		left = min(x1, x2)
		width = abs(x2 - x1) + 1
		top = min(y1, y2)
		height = abs(y2 - y1) + 1

		if width > 1 and height > 1:
			break

	return left, top, width, height


colours = [0x09+64, 0x12+64, 0x1b+64]
for beat in range(0, 14):
	random.shuffle(colours)
	for colour in colours:
		(left, top, width, height) = randrect()
		print "\tdb %d, %d, %d, %d, %d" % (left, top, width, height, colour)

# skybox enters
colours = [0x09+64, 0x12+64]
for beat in range(14, 21):
	random.shuffle(colours)
	for colour in colours:
		(left, top, width, height) = randrect()
		print "\tdb %d, %d, %d, %d, %d" % (left, top, width, height, colour)

	skysize = (beat - 13) * 3
	left = 66 - beat * 3
	top = 12 - int(beat / 2)
	print "\tdb %d, %d, %d, %d, %d" % (left, top, skysize, skysize, 0x42)

# skybox stays
for beat in range(21, 27):
	random.shuffle(colours)
	for colour in colours:
		(left, top, width, height) = randrect()
		print "\tdb %d, %d, %d, %d, %d" % (left, top, width, height, colour)
	print "\tdb %d, %d, %d, %d, %d" % (6, 2, 21, 21, 0x42)

# skybox leaves
for beat in range(27, 30):
	random.shuffle(colours)
	for colour in colours:
		(left, top, width, height) = randrect()
		print "\tdb %d, %d, %d, %d, %d" % (left, top, width, height, colour)
	skysize = (30 - beat) * 6
	top = beat - 25
	left = 30 - beat
	print "\tdb %d, %d, %d, %d, %d" % (left, top, skysize, skysize, 0x42)

# padding
colours = [0x09+64, 0x12+64, 0x1b+64]
for beat in range(0, 14):
	random.shuffle(colours)
	for colour in colours:
		(left, top, width, height) = randrect()
		print "\tdb %d, %d, %d, %d, %d" % (left, top, width, height, colour)
