#!/usr/bin/perl

# by Khai Nguyen, Mar 26th, 2014, CSULB

$fileInfo = " \$perl script.pl [input file]  [column]  [old min]  [old max]  [new min]  [new max]  [output file]";

# ====================================================================================
# Take in arguments
	$input = $ARGV[0] or die "$fileInfo\n";
	$column = $ARGV[1] or die "$fileInfo\n";
	$oldMin = $ARGV[2] or die "$fileInfo\n";
	$oldMax = $ARGV[3] or die "$fileInfo\n";
	$newMin = $ARGV[4] or die "$fileInfo\n";
	$newMax = $ARGV[5] or die "$fileInfo\n";
	$output = $ARGV[6] or die "$fileInfo\n";
	
	if ($ARGV[0] eq "h") { print "$fileInfo\n"; exit(); }
# ====================================================================================


# ====================================================================================
# Magic goes here
	open(INPUT,"<$input") or die "Cannot open input file $input. $!\n";
	open(OUTPUT,">$output") or die "Cannot write to output file $output. $!\n";
	while (my $line = <INPUT>){
		chomp($line);
		foreach($line) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
		my @items = split(/ /,$line);
		$items[$column] = ($newMax - $newMin)/($oldMax - $oldMin)*($items[$column] - $oldMin) + $newMin;
		for(my $i=0; $i < scalar(@items); $i++ ){
			printf OUTPUT "%f\t", $items[$i];
		}
		print OUTPUT "\n";
	} # END OF while (my $line = <INPUT>)

	close INPUT;
	close OUTPUT;
# ====================================================================================	
