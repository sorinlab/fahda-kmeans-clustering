#!/usr/bin/perl

# AUTHOR : KHAI NGUYEN
# DATE   : Fall 2014
# INPUT  : Proj Run Clone Time of real centers from Kmeans clustering trial.
#          These can be extracted from an actual Kmeans clustering trial file.
# OUTPUT : GRO files for real centers.
# PURPOSE: Obtaining GRO files for real centers from Kmeans clustering for 
#          visualization purposes.

$usage = '$ perl  script.pl  -i input.txt  -p proj_loc  -op output_prefix -d dir';

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
	#print "Prefix for output filenames: $outPrefix\n";
	print "Output directory: $outputDir\n";

	
# ====================== CONSTANTS =============================================
	$bin_dir  = "/usr/local/share/GRO/gromacs-3.3/bin";  # location of trjconv
	$ndx_dir  = "/home/fahdata/PKNOT/PKnot-FAH-Files"; # location of *.ndx


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
		
		$proj    = $words[14];
		$run     = $words[11]; # int function is to remove trailing 0's
		$clone   = $words[12];
		$time    = $words[13]; print "\$time: $time\n";
		# store cluster number in 2 digit format
		$cluster = sprintf("%02s", $words[0]);


# ================== output gromacs files ==================
	# first identify frame number and define .xtc file
	# $frame = int($time/1000);
	# fix time to match time in xtc files
	# $newTime = $time - (1000 * $frame);
 	
 	$xtcfile = "${projHome}/PROJ${proj}/RUN${run}/CLONE${clone}/P${proj}_R${run}_C${clone}.xtc";
	$tprfile = "${projHome}/PROJ${proj}/RUN${run}/CLONE${clone}/frame0.tpr";

	if ((-e $xtcfile) && (-e $tprfile))
	{
		# Copy xtc and tpr files to current working directory;
		# This is being careful not to mingle with original data;
		# better be safe than sorry.
		system("cp $xtcfile ./current_frame.xtc");
		system("cp $tprfile ./current_frame.tpr");

		# define input filenames for trjconv
		$xtcfile = "current_frame.xtc";
		$tprfile = "current_frame.tpr";

		if ($proj == 1796) { $ndxfile = "$ndx_dir/p1796_2A43_luteo.ndx";   }
		if ($proj == 1797) { $ndxfile = "$ndx_dir/p1797_2G1W_aquifex.ndx"; }
		if ($proj == 1798) { $ndxfile = "$ndx_dir/p1798_2A43_luteo.ndx";   }
		if ($proj == 1799) { $ndxfile = "$ndx_dir/p1799_2G1W_aquifex.ndx"; }

		# define gro output filename
		$groOut = "${outputDir}/Clu${cluster}_P${proj}_R${run}_C${clone}_T${time}.gro";
		
		# generate and gro file (for protein group only, aka selecting option 1 [echo 1])
		system("echo 1 | $bin_dir/trjconv -f $xtcfile -s $tprfile -n $ndxfile -dump $time -o $groOut");
		# remove temporary files
		system("trash $xtcfile $tprfile");
		
		print STDOUT "Completed: CLUSTER $cluster PROJ $proj RUN $run CLONE $clone TIME $time\n";

  		}
	} # END OF while READING 'INPUT'

	close(INPUT);
