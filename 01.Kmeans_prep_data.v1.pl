#!/usr/bin/perl
# prepare data file for use in Kmeans_cluster.pl,
# the Kmeans scripts as used to cluster data in
# Sorin & Pande, Biophys J. 88, 2472-2493 (2005).
# Last modified 6-21-14 (version 2) by KN
# Original code by EJS


# -------  define I/O and open input/output files -----------
	$fileinfo = "\nUsage\:  Kmeans_pre_data.pl  [data file]  [min time (ps)]  [fields to take]\n\n";
	$input    = $ARGV[0] || die "$fileinfo";
	$mintime  = $ARGV[1] || die "$fileinfo";

	if($#ARGV < 3){ print "ya idiot"; die $fileinfo; }
	else{
		for($i=0;$i<20;$i++) { $field{$i} = ''; } 
		for($i=2;$i<=$#ARGV;$i++) { $field{$i} = $ARGV[$i]; }
	}

	$numfields = $i;


#-------  read in data file  -------------------------------
	$i = 0;
	open(DATA,"<$input") or die "Cannot read $input. $!\n";
	while(defined($line = <DATA>)) {  
		$i++;
		chomp($line);
		for($line) { s/^\s+//; s/\s+$//; s/\s+/ /g; }
		@indata = split(/ /,$line);

  		$time = $indata[3];
		if($time >= $mintime){
			for($f=2; $f<$numfields; $f++){
				printf STDOUT "%14f",$indata[$field{$f}];
			}
			# print run clone time project
			print STDOUT "\t$indata[1]\t$indata[2]\t$indata[3]\t$indata[0]\n"; 
		}
	} # end of reading input file
	close(DATA);
