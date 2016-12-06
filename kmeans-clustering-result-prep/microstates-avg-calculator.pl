#!/usr/bin/env perl
use lib '/home/fahdata/perl5';
use Statistics::Descriptive;

# Author: Khai Nguyen
# Date:   06/01/2015
# Purpose: This scripts calculate the average and standard deviation of the 
#          following metrics: RMSD, Rg, number of native contacts, and number
#          of non-native contacts for each of the clusters identified by
#          k-means clustering algorithm.


# ---------------- i/o ---------------------------------------------------------
	$input        = "final_LUTEO_kmeans_with_new_native_contacts.txt";
	$output       = "cluster_statistics.txt";
	$num_clusters = 27;
	
	# max values will be used for calculating percentage
	$maxNC    = 1441; 
	$maxNNC   = 1930;

	# hold Statistics::Descriptive objects for each of the metrics	
	@statRMSD = ();
	@statRg   = ();
	@statNC   = ();
	@statNNC  = ();

	# Instantialize each of the statistics object
	for ($i = 0; $i < $num_clusters ; $i++) {
		@statRMSD[$i] = Statistics::Descriptive::Full->new();
		@statRg[$i]   = Statistics::Descriptive::Full->new();
		@statNC[$i]   = Statistics::Descriptive::Full->new();
		@statNNC[$i]  = Statistics::Descriptive::Full->new();	
	}
	

# -------- parsing data --------------------------------------------------------
	open (INPUT, "<", $input)
	or die "Cannot open $input. $!.\n";

	while (my $line = <INPUT>) {
		chomp($line);
		my $original_line = $line;

		foreach ($line) {
			s/^\s+//;
			s/\s+$//;
			s/\s+/ /g;
		}

		my @items   = split(' ', $line);
		
		my $cluster = $items[0];  # Cluster number
		my $rmsd    = $items[5];  # RMSD
		my $rg      = $items[6];  # Rg
		my $nc      = $items[12]; # Native contacts
		my $nnc     = $items[13]; # Non-native contacts

		$statRMSD[$cluster]->add_data($rmsd);
		$statRg[$cluster]->add_data($rg);
		$statNC[$cluster]->add_data($nc/$maxNC);
		$statNNC[$cluster]->add_data($nnc/$maxNNC);
	}
	close INPUT;

# -------------- statistics calculations ---------------------------------------
	open (OUTPUT, ">", $output)
	or die "Cannot open $output. $!.\n";

	for ($i = 0; $i < $num_clusters; $i++) {
		my $meanRMSD   = $statRMSD[$i]->mean();
		my $stdDevRMSD = $statRMSD[$i]->standard_deviation();
		
		my $meanRg     = $statRg[$i]->mean();
		my $stdDevRg   = $statRg[$i]->standard_deviation();
		
		my $meanNC     = $statNC[$i]->mean();
		my $stdDevNC   = $statNC[$i]->standard_deviation();
		
		my $meanNNC    = $statNNC[$i]->mean();
		my $stdDevNNC  = $statNNC[$i]->standard_deviation();

		printf OUTPUT "%2s\t%6.3f+/-%5.3f\t%6.3f+/-%5.3f\t",
		$i, $meanRMSD, $stdDevRMSD, $meanRg, $stdDevRg;
		
		printf OUTPUT "%5.3f+/-%5.3f\t%5.3f+/-%5.3f\n",
		$meanNC, $stdDevNC, $meanNNC, $stdDevNNC;
	}

	close OUTPUT;