import ffvideo
from PIL import Image, ImageEnhance
import math

ORIGIN = (0, 0)
WIDTH = 720
FINAL_SIZE = (128, 96)

PADDED_CHAR_WIDTH = 16  # power of 2 to ensure sectors end at a line boundary

FRAME_DATA_BYTES = PADDED_CHAR_WIDTH * FINAL_SIZE[1]
FRAME_BYTES = 512 * int(math.ceil(FRAME_DATA_BYTES / 512.0))
PADDING_BYTES = FRAME_BYTES - FRAME_DATA_BYTES

ASPECT = float(FINAL_SIZE[0]) / FINAL_SIZE[1]
HEIGHT = int(WIDTH / ASPECT)

START_FRAME = 0

vs = ffvideo.VideoStream('clips/jules-quarterscreen-2.m4v')
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

	img = img.transpose(Image.FLIP_LEFT_RIGHT)
	img = img.convert('1')
	# img.save("screens/jules-quarterscreen-2/%s.png" % i)
	frames.append(img.tostring() + ("\0" * PADDING_BYTES))

f = open('build/quarterscreen_sprites.bin', 'w')
selected_frames = frames[START_FRAME:START_FRAME+14] + frames[START_FRAME+14:START_FRAME+28] + frames[START_FRAME+28:START_FRAME+42] + frames[START_FRAME+14:START_FRAME+28]
f.write(''.join(selected_frames))
f.close
