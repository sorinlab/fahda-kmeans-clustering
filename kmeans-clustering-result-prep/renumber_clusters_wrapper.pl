#!/usr/bin/perl
use IO::Handle qw( );  # For autoflush
STDOUT->autoflush(1);

for ($i = 1; $i <= 110; $i++)
{
	#./script.pl  -i  input.txt  -n column  -k  out.key  -o  renumber.txt
    print "Trial: $i\n";
	`./renumber_clusters.pl -i ../2.1-TRIALS/pknot.Trial_$i.kmeans.100.txt  -n 2  -k pknot.Trial_$i.old2new_cluster_nums_map.txt  -o pknot.Trial_$i.kmeans.100.by_rmsd.txt`;
}
