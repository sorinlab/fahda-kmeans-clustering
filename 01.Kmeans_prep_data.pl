#!/usr/bin/perl
# prepare data file for use in Kmeans_cluster.pl,
# the Kmeans scripts as used to cluster data in
# Sorin & Pande, Biophys J. 88, 2472-2493 (2005).
# Last modified 7-29-08 by EJS


######  define I/O and open input/output files  ######
$input   = "\nUsage\:  Kmeans_pre_data.pl  [data file]  [min time (ps)]  [fields to take]\n\n";
$data    = $ARGV[0] || die "$input\n";
$mintime = $ARGV[1] || die "$input\n";

if($#ARGV < 3){ 
   die $input; 
}else{
	for($i=0;$i<20;$i++){         $field{$i} = '';          } 
	for($i=2;$i<=$#ARGV;$i++) {   $field{$i} = $ARGV[$i];   }
}
$numfields = $i;


######  read in data file  ######
$i = 0;
open(DAT,"<$data") or die "Can't read from data file\n";
while(defined($line = <DAT>)) {  
	$i++;
	for($line) {  s/^\s+//; s/\s+$//; s/\s+/ /g; }
	@indata = split(/ /,$line);

  $time = $indata[3];
	if($time >= $mintime){
		for($f=2;$f<$numfields;$f++){
			printf STDOUT "%14f",$indata[$field{$f}];
		}
		print STDOUT "\n"; 
	}
}
close(DAT);