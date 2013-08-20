#!/usr/bin/perl -w

# convert an XBM image to an input file that Pasmo can read

while (<>) {
	if (/^\s+(0x\w\w,\s*)*/) {
		s/^\s+/\tbd /; # this gets translated to db when mirroring bits. Worst. Hack. Ever.
		s/(,|};)\s+$/\n/;
		# bugger. need to mirror bits within the byte.
		tr/1234578abcde/84c2ae15d3b7/;
		s/0x(\w)(\w)/0x$2$1/g;
		print $_; 
	}
}