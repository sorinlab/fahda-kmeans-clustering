#!/usr/bin/perl 

# KHAI NGUYEN
# FALL 2014

for ($i = 1; $i <= 110; $i++)
{
	`mkdir $i`;
	chdir($i);

	my $input = "../../2.2-TRIALS-RENUMBERRED/pknot.Trial_$i.kmeans.100.by_rmsd.txt";
	print "Working on $input...";

	open FILE, "<$input" or die "Cannot read from input $file. $!\n";
	
	$start = 0;
	while (my $line = <FILE>)
	{
		$printLine = $line;
		foreach($line) 
		{ 
			s/^\s+//;
			s/\s+$//;
			s/\s+/ /g;
		}
		@useful = split(/ /,$line); 
		
		if ($useful[0] eq "#" && $useful[1] eq "Class")
		{
			$start = 1;
			next;
		}

		if ($start == 1 && $#useful >= 3)
		{
			$cluster = shift @useful;
			$clustFile = "${cluster}.cluster";
			open CLUST, ">>", $clustFile;
			
			foreach my $item (@useful)
			{
				printf CLUST "% 12s\t", $item;
			}
			print CLUST "\n";
			
			close CLUST;
		}
	}
	close FILE;

	print " DONE!\n";

	chdir("..");
}
