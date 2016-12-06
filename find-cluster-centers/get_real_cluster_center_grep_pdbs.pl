#!/usr/bin/perl

# AUTHOR : KHAI NGUYEN
# DATE   : Fall 2014
# INPUT  : Proj Run Clone Time of real centers from Kmeans clustering trial.
#          These can be extracted from an actual Kmeans clustering trial file.
# OUTPUT : PDB files for real centers.
# PURPOSE: Obtaining PDB files for real centers from Kmeans clustering for 
#          visualization purposes.

$usage = "\$ $0  -i input.txt  -p proj_loc  -d dir";

# ================== SETUP I/O =================================================
	$input     = "";
	$projHome  = "";
	$outputDir = "";

	for (my $i = 0; $i <= $#ARGV; $i++)
	{
		$flag = $ARGV[$i];

		if ($flag eq "-i")  { $i++; $input = $ARGV[$i]; next;      }
		if ($flag eq "-p")  { $i++; $projHome = $ARGV[$i]; next;   }
		#if ($flag eq "-op") { $i++; $outPrefix = $ARGV[$i]; next;  }
		if ($flag eq "-d")  { $i++; $outputDir = $ARGV[$i]; next; }
	}

	# Output to current working directory if there's no argument for '-d'
	if ($outputDir eq "") { $outputDir = "."; }

	# Print help or error message
	if ($ARGV[0] eq "-h") { print "$usage\n"; exit; }
	if (scalar @ARGV == 0) 
	{ 
		print "ERROR: Missing one or more arguments.\n$usage\n";
		exit;
	}

	print "==================== INPUT ARGUMENTS ====================\n";
	print "Input: $input\n";
	print "Project home: $projHome\n";
	print "Output directory: $outputDir\n";

	

# ================== GET FRAME INFO & OPEN .db (?) LOG =========================
	open (INPUT, "<$input") or die "Cannot open input $input. $!\n";

	while (defined($line = <INPUT>)) 
	{
		foreach ($line) 
		{
			s/^\s+//;  # removes leading white spaces
			s/\s+$//;  # removes trailing white spaces
			s/\s+/ /g; # replaces spaces between 2 words by a single space
		}
		@words = split(/ /, $line); # splits line into words
		
		$cluster = $words[0];
		$proj    = $words[0];
		$run     = $words[1];
		$clone   = $words[2];
		$time    = $words[3];
		$frame   = int($time/100); # frames are written every 100 ps

# ================== copy pdb files ==================
	# PDB filename eg: p1798_r0_c100_f22.pdb
 	$pdbfile = "${projHome}/PROJ${proj}/RUN${run}/CLONE${clone}/p${proj}_r${run}_c${clone}_f${frame}.pdb";
	$pdbCopy = "${outputDir}/Clu${cluster}_P${proj}_R${run}_C${clone}_T${time}.pdb";
	if (-e $pdbfile)
	{
		# Copy pdb files to $outputDir;
		system("cp $pdbfile $pdbCopy");
		print STDOUT "Completed: CLUSTER $cluster PROJ $proj RUN $run CLONE $clone TIME $time\n";

	}

} # END OF while READING 'INPUT'
close(INPUT);
