from PIL import Image

img = Image.open('clips/kissing-heads.jpg')
img = img.resize((256, 192), Image.ANTIALIAS)
img = img.convert("1", dither=Image.FLOYDSTEINBERG)

pixels = img.getdata()
f = open('build/poster.scr', 'w')

for ythird in range(0, 192, 64):
	for ypix in range(0, 8):
		for ychar in range(0, 64, 8):
			y = ythird + ypix + ychar
			for xchar in range(0, 256, 8):
				byte = 0
				for xpix in range(0, 8):
					byte |= (pixels[(y << 8) | xchar | xpix] & (1 << (7 - xpix)))
				f.write(chr(byte))

f.close()
