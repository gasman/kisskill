import sys
import math
from PIL import ImagePalette

data, rawmode = ImagePalette.load(sys.argv[1])

spec_colours = [
	[
		(0, 0, 0),
		(0, 0, 192),
		(192, 0, 0),
		(192, 0, 192),
		(0, 192, 0),
		(0, 192, 192),
		(192, 192, 0),
		(192, 192, 192),
	],
	[
		(0, 0, 0),
		(0, 0, 255),
		(255, 0, 0),
		(255, 0, 255),
		(0, 255, 0),
		(0, 255, 255),
		(255, 255, 0),
		(255, 255, 255),
	],
]


def attr_to_rgb(attr):
	ink = attr & 0x07
	paper = (attr & 0x38) >> 3
	bright = (attr & 0x40) >> 6

	ink_r, ink_g, ink_b = spec_colours[bright][ink]
	paper_r, paper_g, paper_b = spec_colours[bright][paper]

	return (ink_r * 0.25 + paper_r * 0.75, ink_g * 0.25 + paper_g * 0.75, ink_b * 0.25 + paper_b * 0.75)

spec_palette = [attr_to_rgb(i) for i in range(0, 128)]


def colour_diff(c1, c2):
	rdiff = c1[0] - c2[0]
	gdiff = c1[1] - c2[1]
	bdiff = c1[2] - c2[2]
	return math.sqrt(rdiff * rdiff + gdiff * gdiff + bdiff * bdiff)


def closest_spec_attr(rgb):
	best_diff = None
	best_attr = None
	for i, spec_colour in enumerate(spec_palette):
		diff = colour_diff(rgb, spec_colour)
		if best_diff is None or best_diff > diff:
			best_diff = diff
			best_attr = i

	return best_attr


if rawmode == 'RGBA':
	final_pal = []
	for i in range(0, len(data), 4):
		rgba = data[i:i+4]
		rgb = (ord(rgba[0]), ord(rgba[1]), ord(rgba[2]))
		final_pal.append(closest_spec_attr(rgb))
else:
	print "can't work with rawmode %s" % rawmode

for i in range(0, len(final_pal), 16):
	bytes = final_pal[i:i+16]
	print "\tdb %s" % ', '.join([str(b) for b in bytes])
