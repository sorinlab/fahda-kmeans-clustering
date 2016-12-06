#!/usr/bin/perl
use FileHandle;
STDOUT->autoflush(1); # flush anything in buffer to output to avoid delayed outputing
#############################################################################################
########   Tabulating Cluster Gap Distances                                    ##############
########   Written by:  Arad  4/16/2014                                         ##############
#############################################################################################
$output = $ARGV[0] || die "You need to tell me an output, Umm-K\nSo just type it in after the name of the script, Ummm-K?\n";
open (OUTF, ">$output") || die "What?? Something happended, and I couldn't open your output file\n";
for ($i=1; $i<=100; $i++){
	$tiny =0; $small=0; $big=0; $huge=0;
	$newFile = "pknotTrial-Trial-$i".".kmeans.100-gaps.txt";
	open (NEWF, "<$newFile") || die "Couldn't open yoor file cuz!\nCheck your spellin!\n";
	while ($line=<NEWF>){
		chomp($line); foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		@info = split(/ /,$line);
		$gap = $info[5];
		if ($gap < -100){
			$tiny++;
		}
		if($gap >= -100 && $gap < 0){
			$small++;
		}
		if ($gap >=0 && $gap <100){
			$big++;
		}
		if ($gap >= 100){
			$huge++;
		}
	}
	close(NEWF);
	printf OUTF "%5d %8d %8d %8d %8d\n", $i, $tiny, $small, $big, $huge;
}
close(OUTF);
