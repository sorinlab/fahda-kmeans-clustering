#!/usr/bin/perl
use IO::Handle qw( );  # For autoflush
STDOUT -> autoflush(1);

# ==============================================================================
# AUTHOR  : KHAI NGUYEN
# DATE    : FALL 2014
# INPUT   :
# OUTPUT  :
# PURPOSE :
# ==============================================================================

$usage = "perl script.pl  <-i1 input1.txt>  <-i2 input2.txt>  <-o output.txt>";

#-----------------------GET ARGUMENTS-------------------------------------------
	$input1 = "";
	$input2 = "";
	$output = "";

	if (defined @ARGV)
	{
		for (my $i = 0; $i <= $#ARGV; $i++)
		{
			$flag = $ARGV[$i];

			if ($flag eq "-i1") { $i++; $input1 = $ARGV[$i]; next; }
			if ($flag eq "-i2") { $i++; $input2 = $ARGV[$i]; next; }
			if ($flag eq "-o")  { $i++; $output = $ARGV[$i]; next; }

			if ($ARGV[0] eq "-h") { print "$usage\n"; exit; }
		}
	}
	else
	{
		print "ERROR: Missing one or more arguments.\n$usage\n";
		exit;
	}

	print "==================== INPUT ARGUMENTS ====================\n";
	print "input1: $input1\n";
	print "input2: $input2\n";
	print "output: $output\n";


#------------------------ IMPORT FROM $input1 ----------------------------------
	%inputs1  = (); # "project-run-clone-time" => 1
	%clusters = (); # "project-run-clone-time" => cluster ID/number

	open (INPUT1, "<$input1") or die "Cannot open input file $input1. $!\n";
	
	print "Importing info for real centers from $input1... ";
	while (my $line = <INPUT1>)
	{
		foreach($line) 
		{ 
			s/^\s+//;
			s/\s+$//; 
			s/\s+/ /g; 
		}
		my @items = split(/ /, $line);
		
		my $project = $items[14];
		my $run     = $items[11];
		my $clone   = $items[12];
		my $time    = $items[13];
		my $cluster = $items[0];

		$inputs1{"$project-$run-$clone-$time"}  = 1;
		$clusters{"$project-$run-$clone-$time"} = $cluster;

	} # END OF READING $input1
print " DONE!\n";
close INPUT1;

# Print out info imported from $input1
foreach my $key (keys %inputs1)
{
	print "$key:\t$inputs1{$key}\t$clusters{$key}\n";
}
print "\n\n";


#-------------------------------------------------------------------------------
# Extract info from $input2 using info from $input1 (project-run-clone-time)
	open (INPUT2, "<$input2") or die "Cannot open input file $input2. $!\n";
	open (OUTPUT, ">", $output) or die "Cannot write to output $output. $!\n";

	print "Extracting info from $input2... ";
	while (my $line = <INPUT2>)
	{
		my $original = $line; chomp($original);
		foreach ($line)
		{
			s/^\s+//;
			s/\s+$//;
			s/\s+/ /g;
		}
		my @items = split(' ', $line);

		my $project = $items[0];
		my $run     = $items[1];
		my $clone   = $items[2];
		my $time    = $items[3];

        #print "$project-$run-$clone-$time\n";

		if ($inputs1{"$project-$run-$clone-$time"} == 1)
		{
			print "Found info from $input2 matched $project-$run-$clone-$time.\n";
			print OUTPUT $clusters{"$project-$run-$clone-$time"}, "\t$original\n";
		}

	} # END OF READING FROM $input2
	print " DONE!\n";

close INPUT2;
close OUTPUT;
print "\n[Program exited]!\n";
