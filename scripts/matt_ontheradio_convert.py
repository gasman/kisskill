import ffvideo
from PIL import ImageEnhance
import math

ORIGIN = (200, 180)
WIDTH = 300
FINAL_SIZE = (112, 80)

PADDED_CHAR_WIDTH = 16  # power of 2 to ensure sectors end at a line boundary

FRAME_DATA_BYTES = PADDED_CHAR_WIDTH * FINAL_SIZE[1]
FRAME_BYTES = 512 * int(math.ceil(FRAME_DATA_BYTES / 512.0))
PADDING_BYTES = FRAME_BYTES - FRAME_DATA_BYTES

ASPECT = float(FINAL_SIZE[0]) / FINAL_SIZE[1]
HEIGHT = int(WIDTH / ASPECT)

START_FRAME = 5

vs = ffvideo.VideoStream('clips/matt-ontheradio-centre.m4v')
frames = []
for i, frame in enumerate(vs):
	img = frame.image()
	x0, y0 = ORIGIN
	img = img.crop((x0, y0, x0 + WIDTH, y0 + HEIGHT))
	img = img.resize(FINAL_SIZE)
	img = img.crop((0, 0, PADDED_CHAR_WIDTH * 8, FINAL_SIZE[1]))

	bright = ImageEnhance.Brightness(img)
	img = bright.enhance(3.0)

	contrast = ImageEnhance.Contrast(img)
	img = contrast.enhance(3.0)

	img = img.convert('1')
	# img.save("screens/matt-ontheradio2/%s.png" % i)
	frames.append(img.tostring() + ("\0" * PADDING_BYTES))

f = open('build/ontheradio_sprites.bin', 'w')
f.write(''.join(frames[START_FRAME:START_FRAME+75]))
f.close
