#!/usr/bin/perl 
##################################################################################################
#
#  collecting the clustering trial info and printing a sorted list of the clustering results   By: Arad 3/18/13
#
##################################################################################################
$usage = "\nUsage: perl script.pl [output file]\n";

$outputFile = $ARGV[0] || die "$usage\n";

#######  Global variables
$line1=0; $tempn =0; @temp1=();
$iterNum=0; $clusNum=0;

######  Opening trial files and begining print data

`tree -i | grep kmeans.100.txt > temp.txt`;
$temp = "temp.txt";
open (TEMP, "<$temp") || die "Can't open list of trial files.\n";
while ($line =<TEMP>){
	chomp($line);
	push (@trialFiles, $line);
}
$index = scalar(@trialFiles);
print "The number of trial files is $index\n";
open (OUT, ">$outputFile") || die "Can not open output file correctly\n";


for ($i = 0; $i< $index; $i++){
	$trialFile = "$trialFiles[$i]";
	if (-e $trialFile){
		open(CLUST, "<$trialFile")|| die "Could not open cluster trial $i"." correctly\n";
		while($line1=<CLUST>){
			chomp($line1);
			foreach($line1) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
			@temp1=split(/ /,$line1);
			if ($temp1[0] eq "#") {
				if ($temp1[3] eq "iterations") {
					$iterNum = $temp1[5];
				}
				if ($temp1[4] eq "clusters"){
					$clusNum = $temp1[6];
				}
			} 
			else { last; }
		}
		close(CLUST);
		print OUT "$trialFile\t$iterNum\t$clusNum\n";
	}
}
close (OUT);

system("sort -nrk3 $outputFile > $outputFile".".sorted.txt");
`rm temp.txt`;
