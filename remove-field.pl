#!/usr/bin/perl

$fileInfo = "perl script-name  [input-matrix]  [column]  [output]";

$input  = $ARGV[0];
$column = $ARGV[1];
$output = $ARGV[2];

open (INPUT, "<$input") or die "Cannot open input file $input. $!\n";
open (OUTPUT, ">$output") or die "Cannot open output file $output. $!\n";
while (my $line = <INPUT>) {
	chomp($line);
	foreach($line) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
	my @lineItems = split(/ /,$line);
	for ($i = 0; $i<scalar(@lineItems); $i++){
		if ($i == $column) { next; }
		else {
			print OUTPUT $lineItems[$i],"\t";
		}
	} # END OF for ($i = 0; $i<scalar(@lineItems); $i++)
	print OUTPUT "\n"; # enter a newline after every line
} # END OF while (my $line = <INPUT>)
close INPUT;
close OUTPUT;