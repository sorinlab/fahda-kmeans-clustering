#!/usr/bin/perl 
##################################################################################################
#
#  collecting the clustering trial info and printing a sorted list of the clustering results   By: Arad 3/18/13
#
##################################################################################################
$usage = "\nUsage: perl aqui_optimal\.pl [trial start #] [trial end #] [output file]\n";

$startI     = $ARGV[0] || die "$usage\n";
$endI       = $ARGV[1] || die "$usage\n";
$outputFile = $ARGV[2] || die "$usage\n";

#######  Global variables
$line1=0; $tempn =0; @temp1=();
$iterNum=0; $clusNum=0;

######  Opening trial files and begining print data
open (OUT, ">$outputFile") || die "Can not open output file correctly\n";

for ($i = $startI; $i<= $endI; $i++){
	$trialFile = "pknotTrial_$i".".kmeans.100.txt";
	if (defined($trialFile)){
	open(CLUST, "<$trialFile")|| die "Could not open cluster trial $i"." correctly\n";
	while($line1=<CLUST>){
		chomp($line1);
		foreach($line1) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
		@temp1=split(/ /,$line1);
		if ($temp1[0] eq "#") {
			if ($temp1[4] eq "iterations" && $temp1[5] eq "prior") {
				$iterNum = $temp1[9];
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

system("sort -nrk3 $outputFile >> $outputFile".".sorted.txt");
