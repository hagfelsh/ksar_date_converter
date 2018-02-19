#!/usr/bin/perl

# This is a timestamp conversion tool to adjust the time stamps created by systat's sar from 12 hour to 24 hour
# so that ksar can make use of the ascii file in its graphing.
# KSAR can be found at http://sourceforge.net/projects/ksar/

use strict;
use warnings;

my $num_args = @ARGV;
    
if ($num_args != 1) {
    die "Usage: $0 <iostat file to read>"
}

my $filename = shift;
my $writetofile = $filename . "_converted-for-ksar";
my $linecount 	= undef;

# Open log file for reading
open (my $r_fh, '<', $filename) or die "can't open $filename - $!";

# Open converted file for writing
open (my $w_fh, '>', $writetofile) or die "can't open $writetofile - $!";

while ( my $line = <$r_fh> ) {
    chomp $line;

	# target date format 	= 16:35:46
	# original date format 	= 04:35:46 PM
	
	# Regex to capture 12 hour time stamp
	if ($line =~ /^(\d{2}):(\d{2}):(\d{2}) (\w{2})(.*)/) {
	
		my $hour    	= undef; 
		my $minute  	= undef; 
		my $second  	= undef; 
		my $ampm		= undef;
		my $body		= undef;
		my $time_fmt	= undef;
		
		$hour			= $1;
		$minute			= $2;
		$second			= $3;
		$ampm			= $4;
		$body			= $5;
		
		# Add 12 hours if the time stamp is PM
		if ($ampm =~ "PM") {
			$hour = $hour + 12;			
		} 
		
		$time_fmt = "$hour" . ":" . "$minute" . ":" . "$second\t$body";
		print $w_fh "$time_fmt\n";	
			
		$linecount++;
	} else {
		print $w_fh "$line\n";	
	}
}

close ($r_fh);
close ($w_fh);
print "Done! -- $linecount lines converted and written to file $writetofile\n";