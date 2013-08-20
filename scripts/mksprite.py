from PIL import Image
import sys

im = Image.open(sys.argv[1])

im = im.convert('1')
out = file(sys.argv[2], 'wb')
out.write(im.tostring())
out.close()
