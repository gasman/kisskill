Kiss Kill - Source code package - Candy Says & Gasman
=====================================================

This package contains the full ZX Spectrum source code to the Kiss Kill video.
For reasons of copyright and file size, some of the original assets (including
the source video footage and audio) are omitted, but these are provided in
Spectrum-converted format instead - which should (hopefully) provide everything
you need to hack on the code, fix bugs, port it to other disk systems, learn
how it was done, and do all kinds of weird and wonderful things with it that I
haven't even thought of...

The overall build process is handled by 'maze'. This is a build manager in the
spirit of UNIX 'make', Ruby's 'rake', Java's 'ant' and so on - but geared
towards ZX Spectrum development. It reads a set of tasks defined in 'Mazefile'
and determines which output files need to be built or rebuilt - these output
files are contained within the 'build' directory.

For completeness, I've included the scripts for converting the original
audio / video assets to Spectrum format - including the 'vid2scr' utility
that translates a video file (in any format supported by FFMPEG) into a
sequence of ZX Spectrum screens. Since the original source audio / video is
not included in this package, I've fiddled the Mazefile so that this is no
longer considered part of the build process - instead, it will take the
Spectrum-converted files in the 'assets' directory as the starting point.

To build the overall kiss_kill.hdf image file (which will be located in
'build'):

  ./maze kiss_kill.hdf

Alternatively,

  ./maze

will build kiss_kill.hdf and launch it in the Fuse emulator - but this is
currently Mac OS X specific, and will need some hacking of the Mazefile to make
it work on other platforms.

At minimum, if you tinker with the .asm source files then you'll need the
following tools:
* ruby: http://ruby-lang.org/
* hdfmonkey: https://github.com/gasman/hdfmonkey
* Pasmo: http://pasmo.speccy.org/

Depending on how deep you go into editing other data files and scripts, you
may also need:
* perl
* python
* PIL (the Python imaging library)
* zmakebas: www.svgalib.org/rus/zmakebas.html
* the esxdos.inc development header - http://esxdos.org/ (as of ESXDOS 0.8 this
  is not yet public, so you'll need to contact Phoenix for a copy. Place this
  in the 'esxdos' subfolder)

To play with the supporting tools / scripts that have been chopped out of the
build process, you will also need:
* the ffmpeg library and a C compiler to build the 'vid2scr'
  video-to-Spectrum-screen conversion tool found in the 'divideo-source'
  directory
* the 'ffvideo' python library


Roadmap to the source code:
---------------------------
assets/ - audio / video data in Spectrum format, converted from raw audio / video footage not supplied in this package
attrfuzz.asm - code for the colour square effect immediately before / after the 'falling' scene
boot.szx - emulator snapshot with ESXDOS firmware preloaded, ready to run the demo
build/ - generated output files
contention_test.asm - tests which 128K memory pages are contended, so that we can select the most suitable ones to load demo code/data into
deltaplay.asm - video player code for the Juju-with-guitar four-vertical-slices scene
divideo-source/ - source code for the vid2scr conversion tool, which converts video files to ZX Spectrum screens. (Based on my DivIDEo project http://divideo.zxdemo.org/ , but with the compression / audio support left out)
esxdos/ - ESXDOS system files that need to be copied to the final .hdf image. (The esxdos.inc header file for ESXDOS development also needs to be placed here)
falling.asm - code for the 'falling' scene
images/ - various image files to be converted and imported into the Spectrum executable
kiss_kill.asm - top-level control code to handle timings and trigger each scene in turn
kiss_kill.bas - BASIC loader stub
lightning.asm - line/box drawing code for the frames around the animations during the oscilloscope scene
loadingstripes_data.asm - wrapper to make the 'kissing heads' image data into a full Spectrum screen (i.e. append a load of blue-on-black attributes to it)
loadingstripes.asm - code for the 'loading stripes' intro
maze - build script
Mazefile - task definitions for the build script to work with
oscilloscope.asm - code for the oscilloscope display in the oscilloscope scene
palettes/ - Palettes used for the plasma background of the 'leap into the blue' scene, in GIMP palette format
plasma.asm - code for the 'leap into the blue' scene
quarterscreen.asm - video player code for the Juju-with-microphone four-quarters scene
rotozoom.asm - code for the first 'runner following trails' scene
runner.asm - code for the runner animation in the oscilloscope scene
scripts/ - various scripts for data generation / conversion:
    convert_palette.py - convert GIMP palette files to ZX Spectrum attributes
    deltacompress.py - library for computing byte differences between animation frames, used for simple video compression
    deltacompress.vsplit.py - apply delta compression on the Juju-with-guitar four-vertical-slices scene
    jules_quarterscreen_2_convert.py - convert the video for the Juju-with-microphone four-quarters scene into Spectrum 'sprite' format to be streamed from disk
    leap_convert.py - convert the images for the 'leap into the blue' scene into Spectrum sprite format
    matt_clap_convert.py - convert the clap animation into Spectrum 'sprite' format to be streamed from disk
    matt_ontheradio_convert.py - convert the mouth closeup animation into Spectrum 'sprite' format to be streamed from disk
    mksprite.py - convert the images for the 'falling' scene into Spectrum sprite format
    oscilloscope.py - extract samples from the song wave file to use as data for the oscilloscope scene
    perspective.rb - library for perspective calculations used in skips.rb
    plasma_sine.rb - generate the sine table used in the plasma background for the 'leap into the blue' scene
    poster2scr.py - convert the 'kissing heads' image into Spectrum screen format
    rand_squares.py - generate random square coordinates for the 'leap into the blue' scene
    roto_sine.rb - generate the sine table used for rotations in the two 'runner following trails' scenes
    running_convert.py - convert the runner animation into Spectrum sprite format, rotated in all four directions
    scrcat.py - concatenate screen files for the main video parts into kisskill.dat, with padding bytes to allow them to be streamed from disk
    skips.rb - calculate pixel spacing for rendering the sky in perspective, for the 'leap into the blue' scene
    skyconv.py - make minor colour / format adjustments to the sky bitmap used in the 'leap into the blue' scene
    xbm2asm.pl - convert .xbm images to Spectrum sprite format (used for the 'candysays' ending logo)
spiral.asm - code for the second 'runner following trails' scene
spriteplay.asm - code for streaming the mouth/clap animations from disk in the oscilloscope part
tvnoise.asm - code for the 'tv noise' outro part
vidplay.asm - code for streaming the main full-screen video sections from disk


Licence
-------
The DivIDEo / vid2scr converter is published under the GNU General Public Licence version 2 (divideo-source/COPYING);
all other source code and scripts are distributed under the MIT licence (LICENSE.txt).

Contact
-------
gasman@raww.org
http://matt.west.co.tt/
https://twitter.com/gasmanic
