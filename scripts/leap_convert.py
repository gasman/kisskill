from PIL import Image, ImageOps

sprite_data = []

for i in range(1, 5):
	frame = Image.open('images/leap%d.png' % i)
	frame = frame.convert('RGB')
	frame = ImageOps.invert(frame)
	frame = frame.convert('1')
	sprite_data.append(frame.tostring())

f = open('build/leap.bin', 'w')
f.write(''.join(sprite_data))
f.close
