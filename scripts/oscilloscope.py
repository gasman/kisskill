import wave
import struct

BPM = 320.0
BEAT_LENGTH = 60.0 / BPM
START_BEAT = 80.0  # beat 80 is the 'huh' of the first 'uuh-huh'
START_TIME = START_BEAT * BEAT_LENGTH
BEAT_COUNT = 16.0
CLIP_LENGTH = BEAT_LENGTH * BEAT_COUNT

FRAME_RATE = 50.0
FRAME_LENGTH = 1 / FRAME_RATE
FRAME_COUNT = int(FRAME_RATE * CLIP_LENGTH)
PICK_RANGE = 0.008  # the duration of the span over which we pick our 32 samples each frame
PICK_INTERVAL = PICK_RANGE / 32

wav = wave.open('clips/kisskill_wipmix2_leadin.wav')
SAMPLE_RATE = wav.getframerate()

for frame in range(0, FRAME_COUNT):
	frame_offset = START_TIME + (frame * FRAME_LENGTH)
	for pick in range(0, 32):
		pick_offset = frame_offset + (pick * PICK_INTERVAL)
		wav.setpos(int(pick_offset * SAMPLE_RATE))
		v1, v2 = struct.unpack('<hh', wav.readframes(1))
		v = (v1 + v2) / 2
		print "\tdb %d" % ((v / 5000) + 12)
	print
