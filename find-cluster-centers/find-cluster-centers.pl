#!/usr/bin/perl
# SAMPLE INPUT FILE IS SHOWN AT THE END OF THIS FILE

$fileinfo = "perl script.pl [cluster file]  [vector length]  [output]";

#-------------------------------------------------------------------------------------
# GET ARGUMENTS
	$input        = $ARGV[0] or die "$fileinfo\n";
	$vectorLength = $ARGV[1] or die "$fileinfo\n";
	$output       = $ARGV[2] or die "$fileinfo\n";
#-------------------------------------------------------------------------------------

open (INPUT, "<$input") or die "Cannot open input file $input. $!\n";
#-------------------------------------------------------------------------------------
# VARIABLES
	$center_flag     = 0; # indicating whether the center info is being read, 0: no, 1: yes
	$pop_flag        = 0; # indicates whether the population is being read, 0: no, 1: yes
	%centers         = (); # hash table for storing mean centers information
	%distance2center = (); # hash table storing distance from a data point to its corresponding mean center
	%realCenters     = (); #hash table for storing real centers
#-------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------
# LINE PROCESSING
	while (my $line = <INPUT>){
		chomp($line);
		$originalLine = $line;
		foreach($line) { s/^\s+//;s/\s+$//; s/\s+/ /g; }
		my @items = split(/ /,$line);
#-------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------
# GET MEAN CENTERS INFORMATION
		'If the line "#  group  pop	centers" is read, 
		 the next block of text will be mean center information';
		if (($items[0]eq"#") and 
			($items[1]eq"group") and 
			($items[2]eq"pop") and 
			($items[3]eq"centers")) 
		{ 
			$center_flag = 1;
			print "Reading mean centers information... "; 
			next;
		}

		'If the mean centers block is read, 
		 store info into hash table %centers';
		if (($center_flag==1) and (scalar(@items)>0))
		{
			$centers{"$items[0]"} = [@items];
			$distance2center{"$items[0]"} = ""; # initialize this hash at the same time
		}
		
		'If the end of centers block is reached
		 disable reading info as mean centers info';
		if (($center_flag==1) and (scalar(@items)==0))
		{ 
			$center_flag = 0;
			print "Done!\n"; 
		}
#-------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------
# CALCULATE DISTANCE FROM DATA POINT TO CORRESPONDING CENTER
		'If the line "# Class	dist(1)	dist(2)	<Delta(dist)>" is read, 
		 the next block of text will be data points information';
		if (($items[0]eq"#") and 
			($items[1]eq"Class") and 
			($items[2]eq"dist(1)") and 
			($items[3]eq"dist(2)") and 
			($items[4]eq"<Delta(dist)>")) 
		{ 
			$pop_flag = 1; 
			print "Calculate distance from every data point to its center (might take a while)...";
			next;
		}
		
		'If a data point is being read, calculate squared cartesian distance2center
		 to its corresponding center (no square root is taken to save some time';
		if (($pop_flag==1) and (scalar(@items)>4)){ # >4 to make sure that we're reading in meaningful lines
			# variable to store sum of squared differences 
			# between two vectors' matching dimensions
			$total_squares = 0;

			# loop through the dimensions of the data point vector 
			for (my $i=0; $i<$vectorLength; $i++)
			{
				# Both vectors (mean center vector and data point vector) must have
				# the same number of dimensions. The following substract matching dimension.
				# For a data point (store in array @items), first dimension starts at index 4. 
				# For mean center (store in hash %centers, accessed by cluster numbers), 
				# first dimension starts at index 2.
				$total_squares += ($items[$i+4] - ${$centers{$items[0]}}[$i+2])**2;
			}

			# The hash %distance2center keep track of the smallest distance from a data point
			# of a cluster to the cluster center. When the smallest distance is found, the data point
			# is saved to %realCenters, which will then be written to output.
			if (($distance2center{"$items[0]"}eq"") or ($distance2center{"$items[0]"} > $total_squares)) 
			{ 
				$distance2center{"$items[0]"} = $total_squares;
				$realCenters{"$items[0]"} = $originalLine;
			}
		}
	} # END OF while ($line = <INPUT>)
	print " Done!\n";
#-------------------------------------------------------------------------------------
close INPUT;

# checking if mean centers information is read in properly
# foreach my $center (sort {$a<=>$b} keys %centers){
# 	foreach my $item (@{$centers{$center}}){
# 		print "$item\t";
# 	}
# 	print "\n";
# }

#-------------------------------------------------------------------------------------
# WRITE REAL CENTERS TO OUTPUT FILE
	open (OUTPUT, ">", $output) or die "Cannot write to output $output. $!\n";
	print "Writing to output $output... ";
	foreach my $key (sort {$a <=> $b} keys %realCenters){
		print OUTPUT $realCenters{"$key"}, "\n";
	}
	close OUTPUT;
	print "Done!\n";
#-------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------
# SAMPLE INPUT FILE FORMAT
	$SAMPLE_INPUT_FILE='
	# initial random cluster centers K = 100
	# maximum number of iterations = 200
	# number of consant iterations prior to convergence = 10
	# number of data used = 505869
	# convergence occurred in 143 iterations
	# number of resulting clusters = 30
	# number of iterations = 153

	#  group  pop	centers
	     0  42186	  40.521	  12.796	   1.425	   0.120	   1.192	   0.707	  43.625	
	     5   5323	  46.345	  21.057	  74.075	   0.004	   0.001	   0.546	  11.371	
	    26   2592	  33.150	   9.085	  14.468	  37.839	   0.597	   2.399	  10.651	
	    79  12245	  24.877	   3.422	  35.152	   6.632	   0.003	   0.986	  53.795	
	    87  33168	  41.803	  20.700	  14.605	   0.027	   0.040	   0.301	  47.534	
	    89  16561	  37.017	   9.629	  32.618	   1.206	   0.397	   0.624	  40.953	
	    92  25867	  35.429	  12.728	  19.667	   0.167	   1.251	   1.234	  29.437	
	    94  12205	   6.029	   6.953	  80.547	  76.164	  77.344	  57.953	   0.000	

	# Class	dist(1)	dist(2)	<Delta(dist)>
	    94     8.08    43.62    35.54         5.666         7.496        75.337        72.065        80.952        60.773         0.000 	0.000000	0.000000	0.000000	6000.000000
	    94    12.99    45.48    32.50         5.598         8.090        85.164        66.802        82.540        63.536         0.000 	0.000000	0.000000	0.000000	6100.000000
	    94     8.94    41.81    32.88         6.135         8.228        86.513        73.684        80.952        62.799         0.000 	0.000000	0.000000	0.000000	6200.000000
	    94     7.25    39.02    31.77         5.776         8.776        86.320        78.543        78.836        60.773         0.000 	0.000000	0.000000	0.000000	6300.000000
	    94     9.59    30.36    20.76         5.592         7.597        85.164        77.733        69.841        61.326         0.000 	0.000000	0.000000	0.000000	6400.000000
	    94    10.51    47.20    36.68         5.699         7.782        81.310        68.826        84.656        59.300         0.000 	0.000000	0.000000	0.000000	6500.000000
	    94    11.73    46.82    35.09         5.988         7.669        75.723        67.611        83.069        60.773         0.000 	0.000000	0.000000	0.000000	6600.000000
	    94    17.02    84.78    67.76         6.607         7.500        76.686        67.611        66.667        48.619         0.000 	0.000000	0.000000	0.000000	6700.000000
	    94    21.06    52.22    31.15         6.487         8.317        73.988        59.919        82.011        47.330         0.000 	0.000000	0.000000	0.000000	6800.000000
	    94    18.57    46.36    27.79         7.091         9.487        74.952        62.753        76.190        46.777         0.000 	0.000000	0.000000	0.000000	6900.000000
	    94    11.94   105.55    93.61         7.039         8.624        82.081        79.757        85.714        50.645         0.000 	0.000000	0.000000	0.000000	7000.000000
	    42    25.49    36.52    11.03         6.929         6.360        85.934        86.640        47.619        40.331         0.000 	0.000000	0.000000	1.000000	6700.000000';
#-------------------------------------------------------------------------------------    