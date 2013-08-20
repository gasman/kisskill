import ffvideo
from PIL import ImageEnhance
import math

ORIGIN = (200, 50)
WIDTH = 320
FINAL_SIZE = (64, 80)

PADDED_CHAR_WIDTH = 8  # power of 2 to ensure sectors end at a line boundary

FRAME_DATA_BYTES = PADDED_CHAR_WIDTH * FINAL_SIZE[1]
FRAME_BYTES = 512 * int(math.ceil(FRAME_DATA_BYTES / 512.0))
PADDING_BYTES = FRAME_BYTES - FRAME_DATA_BYTES

ASPECT = float(FINAL_SIZE[0]) / FINAL_SIZE[1]
HEIGHT = int(WIDTH / ASPECT)

START_FRAME = 15

vs = ffvideo.VideoStream('clips/matt-clap.m4v')
frames = []
for i, frame in enumerate(vs):
	img = frame.image()
	x0, y0 = ORIGIN
	img = img.crop((x0, y0, x0 + WIDTH, y0 + HEIGHT))
	img = img.resize(FINAL_SIZE)
	img = img.crop((0, 0, PADDED_CHAR_WIDTH * 8, FINAL_SIZE[1]))

	bright = ImageEnhance.Brightness(img)
	img = bright.enhance(1.6)

	contrast = ImageEnhance.Contrast(img)
	img = contrast.enhance(1.5)

	img = img.convert('1')
	# img.save("screens/matt-clap/%s.png" % i)
	frames.append(img.tostring() + ("\0" * PADDING_BYTES))

f = open('build/clap_sprites.bin', 'w')
f.write(''.join(frames[START_FRAME:START_FRAME+61]))
f.close
