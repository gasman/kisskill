IMAGEMAGICK_ROOT = /opt/imagemagick
FFMPEG_ROOT = /opt/ffmpeg

OBJS = \
	delta_compressor.o \
	divideo_converter.o \
	image_preprocessor.o \
	image_to_spectrum.o \
	video_reader.o

LIBS = \
	`${IMAGEMAGICK_ROOT}/bin/MagickCore-config --ldflags` \
	-L${IMAGEMAGICK_ROOT}/lib ${IMAGEMAGICK_ROOT}/lib/libMagickCore.a -lm -lgomp -lclparser -framework OpenCL -L/System/Library/Frameworks/OpenCL.framework/Versions/A/Libraries -lm -lpthread \
	${FFMPEG_ROOT}/lib/libavutil.a \
	${FFMPEG_ROOT}/lib/libavformat.a \
	${FFMPEG_ROOT}/lib/libavcodec.a \
	${FFMPEG_ROOT}/lib/libswscale.a \
	/usr/local/lib/libargtable2.a \

all: divideo vid2scr

divideo: ${OBJS} divideo.o
	gcc `${IMAGEMAGICK_ROOT}/bin/MagickCore-config --cflags` -lbz2 -lz -lm ${LIBS} ${OBJS} divideo.o -o divideo

vid2scr: ${OBJS} vid2scr.o
	gcc `${IMAGEMAGICK_ROOT}/bin/MagickCore-config --cflags` -lbz2 -lz -lm ${LIBS} ${OBJS} vid2scr.o -o vid2scr

delta_compressor.o: delta_compressor.h delta_compressor.c
	gcc -c delta_compressor.c

divideo_converter.o: divideo_converter.h video_reader.h image_preprocessor.h image_to_spectrum.h delta_compressor.h divideo_converter.c
	gcc -c divideo_converter.c

image_preprocessor.o: image_preprocessor.h image_preprocessor.c
	gcc -c `${IMAGEMAGICK_ROOT}/bin/MagickCore-config --cflags` image_preprocessor.c

image_to_spectrum.o: image_to_spectrum.h image_to_spectrum.c
	gcc -c image_to_spectrum.c

video_reader.o: video_reader.h video_reader.c
	gcc -c video_reader.c

divideo.o: divideo_converter.h divideo.c
	gcc -c divideo.c

clean:
	rm -f *.o
	rm -f divideo
