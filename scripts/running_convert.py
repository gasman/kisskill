from PIL import Image, ImageSequence, ImageOps

im = Image.open('clips/runner.gif')

sprite_data = []
up_sprite_data = []
down_sprite_data = []
left_sprite_data = []

for i, frame in enumerate(ImageSequence.Iterator(im)):
	print repr(frame)
	frame = frame.crop((20, 10, 190, 180))
	frame = frame.resize((32, 32))
	shift = 1 + (i % 3) * 8 / 3
	frame = frame.crop((-shift, 0, 32-shift, 32))
	frame = frame.convert('1')
	frame = frame.convert('RGB')
	frame = ImageOps.invert(frame)
	frame = frame.convert('1')
	#frame.save("screens/runner/%s.png" % i)
	sprite_data.append(frame.tostring())

	frame_up = frame.transpose(Image.ROTATE_90)
	#frame_up.save("screens/runner-up/%s.png" % i)
	up_sprite_data.append(frame_up.tostring())

	frame_down = frame.transpose(Image.ROTATE_270)
	#frame_down.save("screens/runner-down/%s.png" % i)
	down_sprite_data.append(frame_down.tostring())

	frame_left = frame.transpose(Image.FLIP_LEFT_RIGHT)
	#frame_left.save("screens/runner-left/%s.png" % i)
	left_sprite_data.append(frame_left.tostring())

f = open('build/runner_sprites.bin', 'w')
f.write(''.join(sprite_data))
f.close

f = open('build/runner_up_sprites.bin', 'w')
f.write(''.join(up_sprite_data))
f.close

f = open('build/runner_down_sprites.bin', 'w')
f.write(''.join(down_sprite_data))
f.close

f = open('build/runner_left_sprites.bin', 'w')
f.write(''.join(left_sprite_data))
f.close
