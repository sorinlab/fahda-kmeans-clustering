#!/usr/bin/perl

# ====================================================================================
# FILE INFO
	$usage = "\$perl script.pl  [data]  [name]  [# start]  [# end]  [# of fields]  [# of centers]  [# of iteration]";

	$fileInfo = "e.g. \$perl  script.pl  con-files.txt  pknot  11  20  8  100  200
	This will run the Kmeans script 10 times, with 100 clustering centers each via 200 iterations.
	Ten output files will be generated: 
	pknot_trial11.kmeans.100.txt,
	pknot.trial12.kmeans.100.txt, 
	...
	pknot.trial20.kmeans.100.txt.
	NOTE: The Kmeans_clustering_v20.pl script must be in the SAME directory where you run the command, 
	but it does not have to be in the same directory as the wrapper script.\n
	";


# ====================================================================================
# GET ARGUMENTS FROM COMMAND & INITIALIZE VARS
	$data     = $ARGV[0] or die "$usage\n"; # input data for clustering
	$name     = $ARGV[1] or die "$usage\n"; # name, duh
	$startNum = $ARGV[2] or die "$usage\n"; # starting number for naming the files
	$endNum   = $ARGV[3] or die "$usage\n"; # ending number for naming the files
	$numexp   = $ARGV[4] or die "$usage\n"; # number of fields
	$K        = $ARGV[5] or die "$usage\n"; # number of cluster centers
	$n        = $ARGV[6] or die "$usage\n"; # number of iterations

	if ($ARGV[0] eq "h") { print $fileInfo; exit(); }

	$nameTrial = ""; # this is for attaching the number at the end of $name


# ====================================================================================
# RUN THE KMEANS SCRIPT
	$endNum++; # increase the ending number for the `for` loop
	for ($i = $startNum; $i < $endNum; $i++)
	{
		if ($i < 10) { $ID = "0".$i; }
		else { $ID = $i; }
		$nameTrial = $name."Trial_".$ID;
		# http://www.perlhowto.com/executing_external_commands
		`./02.a.Kmeans_clustering_v20.pl -data $data -name $nameTrial -k $K -nume $numexp -iter $n`;

		if ($? == -1) { print "Command failed. $!\n"; exit(); }
		else { print "Command exited with value $?\n";}
	}
