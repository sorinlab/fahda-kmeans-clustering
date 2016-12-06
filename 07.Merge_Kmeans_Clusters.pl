#!/usr/bin/perl
@clusters = (0);

#MADE BY SORIN FOR BEN&SAM'S BUCHE PROJECT TO MERGE CLUSTERS
# global variables #
$usage="\nUsage: \.\/Merge_Kmeans_Clusters\.pl \[Cluster Data File\]  \[output filename\]  \[\# to be merged\] \[List of Cluster \#'s\]\n\n";
$datafile   = $ARGV[0] || die "$usage\n";  
$outfile    = $ARGV[1] || die "$usage\n";  
$numtomerge = $ARGV[2] || die "$usage\n";
$lastinput  = $#ARGV + 1;
for($i=3;$i<$lastinput;$i++){   
	$test = $ARGV[$i]; 
	chomp $test;
	for($test){ s/^\s+//;s/\s+$//; s/\s+/ /g; }
	push(@clusters,$test); 
}
print STDOUT "@clusters\n\n";


# prep the list # 
@newclusters = sort(@clusters);
print STDOUT "@newclusters\n\n";
$newclusnum  = $newclusters[1]; 
$arraylength = @newclusters - 1;

# Read in the data file and ignore the stuff at the top #
open (OUT, ">$outfile") or die "Can't open $outfile\n";
print OUT "\# Merge_Kmeans_Clusters\.pl @ARGV\n";
open (MAP, "<$datafile") or die "Can't open $datafile\n";
while ($line = <MAP>){
	chomp ($line);
	$origline = $line;
	foreach($line) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
	@lineuseful = split(/ /,$line);
	if((@lineuseful[0] eq "\#")||(@lineuseful[0] eq "Clusters")){ 
		print OUT "$origline\n";  
	}else{
		$checker = 0;
		$oldC = @lineuseful[0];
		for($i=1;$i<=$arraylength;$i++){
			if($oldC == $newclusters[$i]){ $checker++; }  # is the cluster number in the array? 
		}	
		if($checker > 0){  $newC = $newclusnum; }else{ $newC = $oldC; }
		printf OUT "%6d $origline\n",$newC; 
	}	   
}
close(MAP);
close(OUT);

print STDOUT "newclusters = @newclusters\n\nnewclusnum = $newclusnum\n\narraylength = $arraylength\n\n";