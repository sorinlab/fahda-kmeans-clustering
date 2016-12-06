#!/usr/bin/perl

# by Khai Nguyen, Mar 26th, 2014, CSULB

$fileInfo = " \$perl script.pl [input file]  [output file]";


# ====================================================================================
# Take in arguments
	$input  = $ARGV[0] or die "$fileInfo\n";
	$output = $ARGV[1] or die "$fileInfo\n";
# ====================================================================================


# ====================================================================================
# Magic goes here
	open(INPUT,"<$input") or die "Cannot open input file $input. $!\n";
	open(OUTPUT,">$output") or die "Cannot write to output file $output. $!\n";
	while (my $line = <INPUT>){
		chomp($line);
		foreach($line) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
		my @items = split(/ /,$line);
		for(my $i=7; $i <= 10; $i++ ){
			$items[$i] = int($items[$i]);
		}
		for(my $i=0; $i<scalar(@items); $i++){
			print OUTPUT $items[$i],"\t";
		}
		print OUTPUT "\n";
	} # END OF while (my $line = <INPUT>)

	close INPUT;
	close OUTPUT;
# ====================================================================================	
