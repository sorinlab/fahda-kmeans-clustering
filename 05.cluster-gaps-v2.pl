#!/usr/bin/perl
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

	%centers      = (); # stores information of mean centers
	%clusterRadii = (); # store average radii of clusters
	%clusterPop   = (); # store population for each cluster
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
			#print "\$centerBLock = $centerBlock\n";
		}

		# an empty line (i.e. scalar (@line) == 0) means reading the centers is done
		# quit reading
		if (($centerBlock == 1) && (scalar(@lineElements) == 0)){
			last;
		}

		# if the centers section is reached, make an array for the centers
		# also initialize hash table to store radii for each center
		if (($centerBlock == 1) && (scalar(@lineElements) != 0)){
			@{$centers{$lineElements[0]}} = ();
			$centers{$lineElements[0]} = [@lineElements];
			$clusterRadii{$lineElements[0]} = 0; # initialize the hash at the same time
			$clusterPop{$lineElements[0]} = 0;
		}
	} # END OF while (my $line = <CLUSTER>)
	close(CLUSTER);

	print "CENTERS:\n";
	foreach my $clusterID (sort {$a <=> $b} keys %centers){
		print "$clusterID: ";
		foreach my $item (@{$centers{$clusterID}}) { print $item,"\t"; }
		print "\n";
		$centersFields = scalar(@{$centers{$clusterID}});
	} print "\n";

	# print "Initialized hash \%clusterRadii:\n";
	# foreach my $clusterID (sort {$a <=> $b} keys %clusterRadii){ # sort hash by keys natually
	# 	print "$clusterID:\t$clusterRadii{$clusterID}\n";
	# } print "\n";
	
	# $centersFields = scalar(@{$centers{0]}); 
	print "\$centersFields = $centersFields\n"; # number of columns for centers
	$numOfCens   = scalar(keys %centers); # number of centers
	print "Finished reading in cluster centers and have registered $numOfCens clusters.\n";
	#exit();

###############################################################################################################
# CALCULATE DISTANCE BETWEEN ANY TWO CENTERS
	# i and j is for calculating every center-center possible
	@centers2 = ();
	foreach my $clusterID (sort {$a <=> $b} keys %centers){
		push @centers2, [@{$centers{$clusterID}}];
	}

	for ($i=0; $i<$numOfCens; $i++) {
		for ($j=$i+1; $j<$numOfCens; $j++){
			my $sumSquaredDimDiff = 0;
			for ($k=2; $k<$centersFields; $k++){ # $k is going through all dimensions of each center
				$sumSquaredDimDiff += ($centers2[$i][$k] - $centers2[$j][$k])**2;   
				## Shorthand for: Calculating each dimension vector seperatly, squaring it, then add to a sum.
			}
			$cDist{"$centers2[$i][0]:$centers2[$j][0]"} = sqrt($sumSquaredDimDiff); # square root of this sum is the distance
		}
	}

	print "\nCenter-center distance:\n";
	foreach my $clusterID (sort {$a <=> $b} keys %cDist){
		print "$clusterID:\t$cDist{$clusterID}\n";
	} print "\n";

###############################################################################################################
# CALCULATING RADIUS OF ANY CLUSTER
# Starting of actual clusters is signaled by the line "# Class	dist(1)	dist(2)	<Delta(dist)>"
	open (CLUSTER, "<$clusterFile") || die "Cannot open cluster file $clusterFile. $!.\n";
	$clusterBlock = 0; # this equals 1 when file is read to the clusters lines
	$numLines = 0;
	while(my $line=<CLUSTER>){
		$numLines++;
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
			
			# Calculate the distance to corresponding center
			for (my $i=2; $i < $centersFields; $i++){
					#print "($pop[$i+2] - $centers{$pop[0]}[$i])\t";
					$sumSquaredDimDiff += ($pop[$i+2]-$centers{$pop[0]}[$i])**2;
			}
			#print "\t$sumSquaredDimDiff";
			$clusterRadii{$pop[0]} += sqrt($sumSquaredDimDiff);  # summing the distances for each cluster
			$clusterPop{$pop[0]}++;
			$sumSquaredDimDiff = 0;
			#print "\n";
		}

	} # END OF while(my $line=<CLUSTER>)
	close(CLUSTER);

	# Calculates the mean radius for each cluster
	#print "\nSum of distances for each cluster:\n";
	foreach my $clusterID (sort {$a <=> $b} keys %clusterRadii){
		#print "$clusterID:\t$clusterRadii{$clusterID}\n";
		$clusterRadii{$clusterID} = ($clusterRadii{$clusterID}/$clusterPop{$clusterID});	
	} #print "\n";

	print "Read to line $numLines from $clusterFile\n";
	print "\nAverage radii for all clusters:\n";
	print "Cluster\t\t<Radius>\t\tCounted pop\t\tExpected pop\n";
	foreach my $clusterID (sort {$a <=> $b} keys %clusterRadii){
		print "$clusterID:\t$clusterRadii{$clusterID}\t\t $clusterPop{$clusterID} \t\t $centers{$clusterID}[1]\n";
	}

###############################################################################################################
#  STARTING TO EVALUATE ALL POSIBLE PAIRS OF CLUSTER CENTERS
	$x=0; $y=0; $A=0; $B=0;
	open (OUTF, ">$outputFile") || die "Cannot write to output file $outputFile. $!\n";
	for ($x=0; $x<$numOfCens; $x++){
		for ($y=$x+1; $y<$numOfCens; $y++){
		##  Establishing the pair of centers to be evaluated
			$A = $centers2[$x][0];
			$B = $centers2[$y][0];
			print "Comparing clusters $A and $B...\n";
		
		##  Calculating gap between 2 clusters
			#print $cDist{"$A:$B"},"-",$clusterRadii{$A},"-",$clusterRadii{$B},"\n";
			$gap = $cDist{"$A:$B"}-$clusterRadii{$A}-$clusterRadii{$B};
		##  Formatting output
			#printf OUTF "%4s \t %4s \t %5.4f \t %5.4f \t %5.4f \t %5.4f\n", $A,$B,$cDist{"$A:$B"},$clusterRadii{$A}, $clusterRadii{$B}, $gap;	
			print OUTF "$A\t$B\t",$cDist{"$A:$B"},"\t$clusterRadii{$A}\t$clusterRadii{$B}\t$gap\n";	
		} # END OF for ($y=$x+1; $y<$numOfCens; $y++) 
	} # END OF for ($x=0; $x<$numOfCens; $x++)
	close(OUTF);
