#!/usr/bin/perl

$fileinfo = "perl  script.pl  [input]  [output]";

$input = $ARGV[0] or die "$fileinfo\n";
$output = $ARGV[1] or die "$fileinfo\n";

open(INPUT, "<$input") or die "Cannot open input file $input. $!\n";
open(OUTPUT, ">$output") or die "Cannot open output file $output. $!\n";

while (my $line = <INPUT>)
{
	chomp($line);
	$line =~ s/^pknot\.Trial_//;
	$line =~ s/\.kmeans\.100\.txt//;
	print OUTPUT "$line\n";
}

close(INPUT);
close(OUTPUT);