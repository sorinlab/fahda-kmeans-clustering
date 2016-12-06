#!/usr/bin/perl

$usage = "\$ ./script.pl  -i  input.txt  -n column  -k  out.key  -o  renumber.txt
    -i       input.txt      K-means clustering trial file (input, required)
    -n             int      The column of info (rmsd, pop, etc.) to be renumberred
    -k         out.map      Center-to-center mapping key (output, required)
    -o    renumber.txt      K-means clustering trial file with renumbered 
                             clusters (output, required)
";

#================== GET INPUT FROM COMMAND LINE ================================
	for (my $i = 0; $i < $#ARGV; $i++)
	{
		if    ($ARGV[$i] eq "-i") { $i++;  $input  = $ARGV[$i]; } # input
		elsif ($ARGV[$i] eq "-n") { $i++;  $column = $ARGV[$i]; }
		elsif ($ARGV[$i] eq "-k") { $i++;  $key    = $ARGV[$i]; } # output
		elsif ($ARGV[$i] eq "-o") { $i++;  $output = $ARGV[$i]; } # output
	}

	if ($ARGV[0] eq "-h") { print "\n\t$usage\n"; exit; }
	if (scalar @ARGV < 8) { print "ERROR: Incorrect parameters.\n\t$usage\n"; exit; }

	print "\tInput file         : $input\n";
	print "\tColumn to renumber : $column\n";
	print "\tOutput file        : $key\n";
	print "\tOutput file        : $output\n";


#================== GET DATA ==================================================
#------------------ PROCESS LINE -----------------------------------------------
	open (INPUT, "<$input")   or die "Cannot open $input. $!.\n";
	@RMSD_ID  = (); # 2D array to store RMSD (column 0) and cluster ID (column 1)

	# "true" if the centers are being read 
	# "false" otherwise
	my $reachCentersData = "false";
	
	while (my $line = <INPUT>)
	{
		chomp ($line); # remove last new-line character
		my $original_line = $line;

		foreach($line) 
		{ 
			s/^\s+//;  # removes leading white spaces
			s/\s+$//;  # removes trailing white spaces
			s/\s+/ /g; # repalces spaces between two words by a single space
		}
		my @words = split(' ', $line);

#----------- GET DATA FOR EACH CENTER ------------------------------------------
		if ($original_line eq "#  group  pop	centers")
		{ $reachCentersData = "true"; }

		if (($reachCentersData eq "true") && ($line ne "") && ($words[0] ne "#"))
		# First word: Cluster ID
		{ 
            print "$words[$column], $words[0]\n";
            my @temp = ($words[$column], $words[0]);
            push @RMSD_ID, [@temp];
        }

		# When finish reading centers information
		if (($reachCentersData eq "true") && ($line eq ""))
		{
			# Turn off the "centers" flag
			# $reachCentersData = "false";
			last; # Stop reading the file aka break while loop
		}
	}
	close INPUT;


#================== GENERATE NEW CLUSTER NUMBERS/ID's ==========================
	# Output old-cluster-id's --> new-cluster-id's mapping keys
	open (KEY, ">$key") or die "Cannot open $key. $!.\n";
	
    # Get the RMSDs & sort them in ascending order
	my @sorted_RMSD_ID = sort {$a->[0] <=> $b->[0]} @RMSD_ID;

    print "\n";
    for (my $i = 0; $i <= $#sorted_RMSD_ID; $i++)
    {
        print ${$sorted_RMSD_ID[$i]}[0], "\t", ${$sorted_RMSD_ID[$i]}[1], "\n";
    }

	%newIDs = (); # store new cluster IDs: "Original cluster ID" => "New ID"
	for (my $i = 0; $i <= $#sorted_RMSD_ID; $i++)
	{
        my $rmsd  = ${$sorted_RMSD_ID[$i]}[0];
        my $oldID = ${$sorted_RMSD_ID[$i]}[1];
		$newIDs{$oldID} = $i;
		
        # Print out old IDs, populations, and new IDs to file
		print KEY "$oldID\t";
		print KEY "$rmsd\t";
		print KEY "$newIDs{$oldID}\n";
	}
	close KEY;
    #`cat $key | sort -n -k 3 > key_to_be_del.txt`;
    #`cat key_to_be_del.txt > $key`;
    #`/bin/rm key_to_be_del.txt`;

# -------------------- RENUMBER CLUSTER ID'S ------------------------
	open (INPUT, "<$input")   or die "Cannot open $input. $!.\n";
	open (OUTPUT, ">$output") or die "Cannot open $output. $!.\n";

	while (my $line = <INPUT>)
	{
		chomp($line); # Removes the last new-line character

		# Print line from INPUT to OUTPUT without 
		# changing if the line is a comment
		if ($line =~ m/^#/)
		{ print OUTPUT "$line\n"; next; }

		else
		{
			foreach ($line) 
			{
				s/^\s+//;  # Removes leading white spaces
				s/\s+$//;  # Removes trailing white spaces
				s/\s+/ /g; # Replaces spaces between 2 words by a single space
			}
			my @words = split(' ', $line);

			# Copy empty line from INTPUT to OUTPUT and skip to next iteration
			if (scalar @words == 0)
			{ print OUTPUT "\n"; next; }

			# If the first number in current line 
			# has a new ID's stored in %newIDs
			if ($newIDs{$words[0]} =~ m/\d/)
			{
				# replace old cluster number by new one 
				$words[0] = $newIDs{$words[0]}; 
			}	

			for (my $i = 0; $i <= $#words; $i++)
			{
				print OUTPUT "\t$words[$i]";
			}
			print OUTPUT "\n";
		}
	}
	close INPUT;
	close OUTPUT;
