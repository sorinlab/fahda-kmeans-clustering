#!/usr/bin/perl
use Statistics::Descriptive;
use FileHandle;
STDOUT->autoflush(1); # flush anything in buffer to output to avoid delayed outputing
#############################################################################################
########   Calculating Cluster Center Distances and average population spreads ##############
########   Written by:  Arad  4/8/2014                                         ##############
#############################################################################################

#############################################################################################################
# GATHERING INPUT FILES AND OUTPUT NAMES
	$fileInfo    = "perl scriptName [cluster-file]  [output]\n";
	$clusterFile = $ARGV[0] || die "$fileInfo"; # contains clusters
	$outputFile  = $ARGV[1] || die "$fileInfo"; # output

#############################################################################################################
# EXTRACT CENTERS INFORMATION INTO AN ARRAY
	open (CLUSTER, "<$clusterFile") || die "Could not open input file $clusterFile. $!\n";

	@centers      = (); # stores information of mean centers
	%clusterRadii = (); # store average radii of clusters
	$centerBlock  = 0; # 0 if not reach lines of centers, 1 if reached

	while (my $line = <CLUSTER>){
		chomp($line); foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		@lineElements = split(/ /,$line);
		
		if ( ($lineElements[0] eq "#") && 
		     ($lineElements[1] eq "group") && 
		     ($lineElements[2] eq "pop") &&
		     ($lineElements[3] eq "centers")){
			$centerBlock=1;
			next; 
			print "\$centerBLock = $centerBlock\n";
		}

		# an empty line (i.e. scalar (@line) == 0) means reading the centers is done
		# quit reading
		if (($centerBlock == 1) && (scalar(@lineElements) == 0)){
			last;
		}

		# if the centers section is reached, make an array for the centers
		# also initialize hash table to store radii for each center
		if (($centerBlock == 1) && (scalar(@lineElements) != 0)){
			push (@centers, [@lineElements]);
			@{$clusterRadii{$lineElements[0]}} = (); # initialize the hash at the same time
		}
		
	} # END OF while (my $line = <CLUSTER>)
	close(CLUSTER);

	print "Centers with mean values:\n";
	foreach my $item (@centers){
		foreach (@{$item}){
			print "$_\t";
		}
		print "\n";
	}
	
	$centersFields = scalar(@{$centers[0]}); print "\$centersFields = $centersFields\n"; # number of columns for centers
	$numOfCens   = scalar(@centers); # number of centers
	print "Finished reading in cluster centers and have registered $numOfCens clusters.\n";
	
	#exit();

###############################################################################################################
# CALCULATE DISTANCE BETWEEN ANY TWO CENTERS
	# i and j is for calculating every center-center possible
	for ($i=0; $i<$numOfCens; $i++) {
		for ($j=$i+1; $j<$numOfCens; $j++){
			my $sumSquaredDimDiff = 0;
			for ($k=2; $k<$centersFields; $k++){ # $k is going through all dimensions of each center
				$sumSquaredDimDiff += ($centers[$i][$k] - $centers[$j][$k])**2;   
				## Shorthand for: Calculating each dimension vector seperatly, squaring it, then add to a sum.
			}
			$cDist{"$centers[$i][0]:$centers[$j][0]"} = sqrt($sumSquaredDimDiff); # square root of this sum is the distance
		}
	}

	foreach my $item (keys %cDist){
		print $item,": ",$cDist{$item},"\n";
	}

###############################################################################################################
# CALCULATING RADIUS OF ANY CLUSTER
# Starting of actual clusters is signaled by the line "# Class	dist(1)	dist(2)	<Delta(dist)>"
	open (CLUSTER, "<$clusterFile") || die "Cannot open cluster file $clusterFile. $!.\n";
	$clusterBlock = 0; # this equals 1 when file is read to the clusters lines

	while(my $line=<CLUSTER>){
		chomp($line);
		foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
		my @pop = split(/ /,$line);

		if (($pop[0] eq "#") &&
		    ($pop[1] eq "Class") &&
		    ($pop[2] eq "dist(1)") &&
		    ($pop[3] eq "dist(2)") &&
		    ($pop[4] eq "<Delta(dist)>")) {
			$clusterBlock = 1;
			next;
		}
		
		# if an empty line is reached after clusters, ends reading
		if (($clusterBlock == 1) && (scalar(@pop) == 0)){
			last;
		}

		if (($clusterBlock == 1) && (scalar(@pop) != 0)){
			my $sumSquaredDimDiff = 0;
			for (my $i=2; $i < $centersFields; $i++){
				$sumSquaredDimDiff += ($pop[$i+2]-$centers[$pop[0]][$i])**2;
				
			}
			print "$sumSquaredDimDiff\n";
			push @{$clusterRadii{$pop[0]}}, sqrt($sumSquaredDimDiff);  # push the distances into each cluster
		}
	} # END OF while(my $line=<CLUSTER>)
	close(CLUSTER);

	# Calculate the average distance (or radius) for each cluster
	print "\nRadii for all clusters:\n";
	foreach my $center (keys %clusterRadii){
		my $sum = 0;
		foreach (@{$clusterRadii{$center}}) {
			$sum += @{$clusterRadii{$center}}[$_];
		}
		print "$center:\t@{$clusterRadii{$center}}\t\t size: ".scalar(@{$clusterRadii{$center}})." Sum: $sum\n";
	}

	foreach my $center (keys %clusterRadii){
		# my $sum = 0;
		# foreach (@{$clusterRadii{$center}}) {
		# 	$sum += @{$clusterRadii{$center}}[$_];
		# }
		my $stat = Statistics::Descriptive::Sparse->new();
		$stat->add_data(@{$clusterRadii{$center}});
		my $mean = $stat->mean();
		$clusterRadii{$center} = $mean; #$sum/(scalar(@{$clusterRadii{$center}}));
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
			# $clustA = "C$A";
			# $clustB = "C$B";
			# $diffA  = ($cDist{"$A:$B"} - $clusterRadii{$A});   
			# $diffB  = ($cDist{"$B:$A"} - $clusterRadii{$B}); 
			$gap = $cDist{"$A:$B"} - $clusterRadii{$A} - $clusterRadii{$B};
		##  Formatting output
			printf OUTF "%4s \t %4s \t %5.4f \t %5.4f \t %5.4f \t %5.4f\n",
			            $A,$B,$cDist{"$A:$B"},$clusterRadii{$A}, $clusterRadii{$B}, $gap;	
		} # END OF for ($y=$x+1; $y<$numOfCens; $y++) 
	} # END OF for ($x=0; $x<$numOfCens; $x++)
	close(OUTF);