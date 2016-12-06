#!/usr/bin/perl
# use FileHandle;
# flush anything in buffer to output 
# to avoid delayed outputing
# STDOUT->autoflush(1); 

# =============================================================================#
#   Calculating Cluster Center Distances and average population spreads        #
#   Written by:  Khai  08/09/2014                                              #
# =============================================================================#

# ==============================================================================
# GATHERING INPUT FILES AND OUTPUT NAMES
	$usage   = "perl scriptName <input-dir>  <output-dir>\n";
	$dir_input  = $ARGV[0] or die "$usage"; # contains cluster trials
	$dir_output = $ARGV[1] or die "$usage"; # output files location

# ==============================================================================
# EXTRACT CENTERS INFORMATION INTO AN ARRAY
	# get a list of clustering trial files
	@trials = `ls $dir_input | grep rmsd.txt`;

	# work on each of those trial files
	foreach my $trial (@trials) {
		chomp($trial); # remove new-line character due to `ls` command
		my $input = $dir_input . "/" . $trial;
		open (CLUSTER, "<$input") # open trial file
		or die "Could not open input file $trial. $!\n";

		%centers      = (); # stores information of mean centers
		# "false" if not reach lines of centers, "true" if reached
		$centerBlock  = "false";

		while (my $line = <CLUSTER>){
			chomp($line); foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;}
			@lineElements = split(/ /,$line);
			
			if ( ($lineElements[0] eq "#") && 
			     ($lineElements[1] eq "group") && 
			     ($lineElements[2] eq "pop") &&
			     ($lineElements[3] eq "centers")){
				$centerBlock = "true";
				next; 
			}

			# an empty line (i.e. scalar (@line) == 0) 
			# means reading the centers is done,
			# so quit reading
			if (($centerBlock eq "true") && (scalar(@lineElements) == 0)){
				last;
			}

			# if the centers section is reached, make an array for the centers
			# also initialize hash table to store radii for each center
			if (($centerBlock eq "true") && (scalar(@lineElements) != 0)){
				my @vector = (); # stores the center vector
				for (my $i=2; $i < scalar(@lineElements); $i++) {
					push @vector, $lineElements[$i];
				}
				$centers{$lineElements[0]} = [@vector];
			}
		} # END OF while (my $line = <CLUSTER>)
		close(CLUSTER);

		# FOR TESTING PURPOSE:
		# Print out the centers, uncomment lines below
		# =======================

		print "=============================================================\n";
		print "Imported cluster centers:\n";
		foreach my $clusterID (sort {$a <=> $b} keys %centers){
		print "$clusterID: ";
		foreach my $item (@{$centers{$clusterID}}) { print $item,"\t"; }
		print "\n";
		} print "\n";

# ==============================================================================
# CALCULATE DISTANCE BETWEEN ANY TWO CENTERS
	@clusterIDs = sort {$a <=> $b} keys %centers;
	$vectorLength = 7; # may be different for other clustering trial(s)

	# stores center-center distance between any pair of cluster-cluster
	%center_center_distances = (); 
	
	for (my $i=0; $i < scalar @clusterIDs; $i++) {
		for (my $j=$i+1; $j < scalar @clusterIDs; $j++) {

			my $clu_i        = $clusterIDs[$i];
			my $clu_j        = $clusterIDs[$j];
			my $sumOfSquares = 0;
			
			# $k is going through all dimensions of each center
			for (my $k=0; $k < $vectorLength ; $k++) {
				# Find difference in each dimension and square it, then add
				# to a sum ($sumOfSquares)
				$sumOfSquares += (${$centers{$clu_i}}[$k] - ${$centers{$clu_j}}[$k])**2;
			} # END OF DIMENSION LOOPING

			$center_center_distances{ "$clu_i-$clu_j" }
				= sqrt ($sumOfSquares);
		} # END OF INNER LOOP
	} # END OF OUTTER LOOP

# ==============================================================================
# OUTPUT
	$output = $trial;
	$output =~ s/\.kmeans\.100\.txt$//;
	$output = $dir_output."/".$output."_clusterDistance.txt";

	open (OUTPUT, ">$output") or die "Cannot write to output file $output. $!\n";

	for (my $i=0; $i < scalar @clusterIDs; $i++) {
		for (my $j=$i+1; $j < scalar @clusterIDs; $j++) {
			print OUTPUT "$clusterIDs[$i]\t";
			print OUTPUT "$clusterIDs[$j]\t";
			printf OUTPUT "% 8.2f\n",
			$center_center_distances{ "$clusterIDs[$i]-$clusterIDs[$j]" };
		}
	}	

	close(OUTPUT);
	} # END OF WORKING A TRIAL FILE