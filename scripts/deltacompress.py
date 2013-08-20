import os
import sys
import re


class Region(object):
	def __init__(self, x0, y0, w, h):
		# list of start addresses of screen pixel rows occupied by this region,
		# in address order
		y_addrs = []
		for ychar in range(y0, y0 + h):
			ychar_addr = ((ychar & 0x18) << 8) | ((ychar & 0x07) << 5)
			for ypix in range(0, 8):
				ypix_addr = ychar_addr | (ypix << 8)
				y_addrs.append(ypix_addr)
		y_addrs.sort()

		self.addresses = []
		last_address = None
		for y_addr in y_addrs:
			for x in range(x0, x0 + w):
				address = y_addr | x
				if (last_address is not None and address - last_address) > 255:
					raise Exception("gap between addresses %d and %d is too big!" % last_address, address)
				self.addresses.append(address)
				last_address = address

	def diffs(self, last_screen, this_screen):
		last_change = self.addresses[0] - 1
		last_addr = None

		diffs = []
		tentative_diffs = []

		for addr in self.addresses:
			if addr - last_change > 255:
				# insert a fake change item at the previous addr
				tentative_diffs.append(last_addr - last_change)
				tentative_diffs.append(this_screen[last_addr])
				last_change = last_addr
			elif this_screen[addr] != last_screen[addr]:
				diffs += tentative_diffs
				tentative_diffs = []
				diffs.append(addr - last_change)
				diffs.append(this_screen[addr])
				last_change = addr

			last_addr = addr

		diffs.append(0)
		diffs.append(0)

		return diffs


def write_deltas(filenames, regions, initial_state=0):
	diffs_total = 0

	last_screen = [initial_state] * 6144
	for filename in filenames:
		f = open(filename)
		screen = [ord(c) for c in f.read(6144)]

		for region in regions:
			diffs = region.diffs(last_screen, screen)
			diffstring = ''.join([chr(i) for i in diffs])
			sys.stdout.write(diffstring)
			diffs_total += len(diffs)

		last_screen = screen

	# print "total diffs: %d" % diffs_total
