#!/usr/bin/perl

$fileInfo = "perl  script.pl  [script-to-run]";

$script = $ARGV[0] or die "$fileInfo\n";

# get file names of all trial files into an array
@fileNames = `tree -i | grep kmeans.100.txt`;

foreach my $file (@fileNames){
	chomp($file);
	$file =~ s/....$//; # remove the extension, including the dot
	print "Calculating gaps on $file.txt... ";
	`$script  $file.txt  $file-gaps.txt`;
	print "\tDone!\n";
}