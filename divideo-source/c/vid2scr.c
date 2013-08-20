#include <argtable2.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "video_reader.h"
#include "image_preprocessor.h"
#include "image_to_spectrum.h"

int main(int argc, char **argv) {
	
	struct arg_lit *colour_opt = arg_lit0("c", "colour", "Perform conversion in colour");
	struct arg_int *dither_opt = arg_int0("d", "dither", NULL, "Set dither size (1 = none, 2 = 2x2, 4 = 4x4)");
	struct arg_int *frames_opt = arg_int0("f", "frames", "<N>", "Only convert the first N frames");
	struct arg_dbl *contrast_opt = arg_dbl0("k", "contrast", NULL, "Set contrast (5.5 works well)");
	struct arg_dbl *brightlevel_opt = arg_dbl0("l", "brightlevel", NULL, "Set midpoint brightness level (0.3 works well)");
	struct arg_lit *mono_opt = arg_lit0("m", "mono", "Perform conversion in black and white");
	struct arg_lit *help_opt = arg_lit0("h", "help", "Print this help and exit");
	
	struct arg_file *files_opt = arg_filen(NULL, NULL, "", 2, 2, NULL);
	struct arg_rem *dest_opt = arg_rem ("INFILE OUTDIR", NULL);
	
	struct arg_end *end_opts = arg_end(20);
	
	void *argtable[] = {colour_opt, dither_opt, frames_opt, contrast_opt,
		brightlevel_opt, mono_opt, help_opt, files_opt, dest_opt, end_opts};
	
	if (arg_nullcheck(argtable) != 0) {
		printf("error: insufficient memory\n");
		return -1;
	}
	
	/* set defaults */
	dither_opt->ival[0] = 2;
	frames_opt->ival[0] = -1;
	contrast_opt->dval[0] = -1;
	brightlevel_opt->dval[0] = -1;
	
	int nerrors = arg_parse(argc,argv,argtable);

	/* special case: '--help' takes precedence over error reporting */
	if (help_opt->count > 0)
		{
		printf("Usage: %s", "vid2scr");
		arg_print_syntax(stdout,argtable,"\n");
		arg_print_glossary(stdout,argtable,"  %-25s %s\n");
		return 0;
	}
	
	if (nerrors > 0) {
		arg_print_errors(stdout, end_opts, "vid2scr");
		printf("Usage: %s", "vid2scr");
		arg_print_syntax(stdout,argtable,"\n");
		return -1;
	}
	
	
	const char *input_file = files_opt->filename[0];
	const char *output_dir = files_opt->filename[1];

	mkdir(output_dir, S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
	static char output_file[256];

	int use_colour = (colour_opt->count >= mono_opt->count);
	
	video_reader_init();
	st_video_reader_data vrdata;
	video_reader_init_data(&vrdata);
	int error = video_reader_open(&vrdata, input_file);
	if (error < 0) return error;

	long frame_number = 0;
	long max_frames = frames_opt->ival[0];
	static char bitmap[256*192*4];
	int frame_ppm_size;
	static unsigned char screen[0x1b00];

	st_converter_data zx_converter;
	image_to_spectrum_converter_init( &zx_converter, use_colour, dither_opt->ival[0] );

	while(1) {
		char *frame_ppm = video_reader_read_ppm(&vrdata, &frame_ppm_size);
		frame_number++;
		if (frame_ppm == NULL) break;
		if (max_frames > 0 && frame_number > max_frames) break;
		image_preprocessor_ppm_to_bitmap(frame_ppm, frame_ppm_size,
			contrast_opt->dval[0], brightlevel_opt->dval[0], bitmap);
		free(frame_ppm);
		image_to_spectrum_convert( &zx_converter, (unsigned char *)bitmap, screen );
		snprintf(output_file, 255, "%s/%08ld.scr", output_dir, frame_number);
		printf("writing %s\n", output_file);
		FILE *f = fopen(output_file, "w");
		fwrite(screen, 0x1b00, 1, f);
		fclose(f);
	}

	return 0;
}
