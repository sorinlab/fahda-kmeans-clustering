#!/usr/bin/perl
use FileHandle;
STDOUT->autoflush(1); # flush anything in buffer to output to avoid delayed outputing
#############################################################################################
########   Calculating Cluster Center Distances and average population spreads ##############
########   Written by:  Arad  4/8/2014                                         ##############
#############################################################################################

#############################################################################################################
# GATHERING INPUT FILES AND OUTPUT NAMES
	$fileInfo   = "perl scriptName [centers file]  [population file]  [center-center distances file] [output]\n";
	$cenFile    = $ARGV[0] || die "$fileInfo"; # contains centers with mean values
	$popFile    = $ARGV[1] || die "$fileInfo"; # contains time frames with actual values
	$cdistFile  = $ARGV[2] || die "$fileInfo"; # contains center-center distances
	$outputFile = $ARGV[3] || die "$fileInfo"; # output

#############################################################################################################
# OPENNING AND STORING CENTER CENTER
	open (CENT, "<$cenFile") || die "I wasn't able to open your centers file, bro?\n"."Check that you spelled it correctly.\n";

	@centers=(); # stores information of mean centers
	%clusterRadii = (); # store average radii of clusters

	while (my $line = <CENT>){
		chomp($line); foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		@useful = split(/ /,$line);
		push (@centers, [@useful]);
		@{$clusterRadii{$useful[0]}} = (); # initialize the hash at the same time
	}
	close(CENT);

	print "Centers with mean values:\n";
	foreach my $center (@centers){
		foreach (@{$center}){
			print "$_\t";
		}
		print "\n";
	}
	
	$numOfFields = scalar(@useful); print "\$numOfFields = $numOfFields\n";
	$numOfCens   = scalar(@centers);                                                                                                                                                                                            
	print "Finished reading in cluster centers and have registered $numOfCens clusters.\n";
	
###############################################################################################################
# OPENING AND STORING CENTER DISTANCES
	%cDist = ();
	open (CDIST, "<$cdistFile") || die "I was not able to open your center distances file, bro!\n"."Make sure you put in the right name.\n";
	while ($info = <CDIST>){
		chomp($info); foreach ($info) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		@seg = split(/ /,$info);
		$clustA = $seg[0];
		$clustB = $seg[1];
		$cDist{"$clustA:$clustB"} = $seg[2];
	}
	close(CDIST);


###############################################################################################################
# CALCULATING RADIUS OF ANY CLUSTER
	open (POPU, "<$popFile") || die "Cannot open population file $popFile. $!.\n";
	while(my $line=<POPU>){
		$sumSquaredDimDiff = 0;
		chomp($line);
		foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		my @pop = split(/ /,$line);

		for (my $i=2; $i < $numOfFields; $i++){
				$sumSquaredDimDiff = $sumSquaredDimDiff + ($pop[$i+2]-$centers[$pop[0]][$i])**2;
		}
		my $distance = sqrt($sumSquaredDimDiff);
		push @{$clusterRadii{$pop[0]}}, $distance;  # push the distances into each cluster
	}
	close(POPU);

	# Calculate the average distance (or radius) for each cluster
	foreach my $center (keys %clusterRadii){
		my $sum = 0;
		foreach (@{$clusterRadii{$center}}) {
			$sum += @{$clusterRadii{$center}}[$_];
		}
		$clusterRadii{$center} = $sum/scalar(@{$clusterRadii{$center}});
	}

	print "\nAverage radii for all clusters:\n";
	foreach my $center (keys %clusterRadii){
		print "$center:\t$clusterRadii{$center}\n";
	}

###############################################################################################################
#  STARTING TO EVALUATE ALL POSIBLE PAIRS OF CLUSTER CENTERS
	$x=0; $y=0; $A=0; $B=0;
	open (OUTF, ">$outputFile") || die "I couldn't open the output file for some reason.... huh?\nIDK what happended.\n";
	for ($x=0; $x<$numOfCens; $x++){
		for ($y=$x+1; $y<$numOfCens; $y++){
		##  Establishing the pair of centers to be evaluated
			$A = $centers[$x][0];
			$B = $centers[$y][0];
			print "Comparing clusters $A and $B...\n";
		
		##  Calculating gap between 2 clusters
			$clustA = "C$A";
			$clustB = "C$B";           
			$diffA  = ($cDist{"$clustA:$clustB"} - $clusterRadii{$A});   
			$diffB  = ($cDist{"$clustB:$clustA"} - $clusterRadii{$B}); 
			$gap = $cDist{"$clustA:$clustB"} - $clusterRadii{$A} - $clusterRadii{$B};
		##  Formatting output
			printf OUTF "%4s \t %4s \t %5.4f \t %5.4f \t %5.4f \t %5.4f \t %5.4f \t %5.4f\n",
			            $A,$B,$cDist{"$clustA:$clustB"},$clusterRadii{$A}, $diffA, $clusterRadii{$B}, $diffB, $gap;	
		} # END OF for ($y=$x+1; $y<$numOfCens; $y++) 
	} # END OF for ($x=0; $x<$numOfCens; $x++)
	close(OUTF);