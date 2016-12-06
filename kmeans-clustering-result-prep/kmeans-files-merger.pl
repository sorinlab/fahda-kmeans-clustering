#!/usr/bin/perl

# Author : Khai Nguyen
# Date   : 06/01/2015
# Purpose: This script reads in two input files
#            - final_LUTEO_kmeans.txt and
#            - luteo-1796-1798-categorized-contacts-rmsd-rg.txt
#          It extracts from cluster numbers from the first file and tack them
#          on to the correct lines in luteo-1796-1798-categorized-contacts-rmsd-rg.txt
#          using project, run, clone, and time to make sure correct merging.


# --------------------------- Inputs -------------------------------------------
	$old_kmeans = "final_LUTEO_kmeans.txt";
	$new_native = "luteo-1796-1798-categorized-contacts-rmsd-rg.txt";
	$output     = "final_LUTEO_kmeans_with_new_native_contacts.txt";


# ------------------- Parse cluster numbers ------------------------------------
	open(OLD_KMEANS, "<", $old_kmeans)
	or die "Cannot open $old_kmeans. $!.\n";
	print STDOUT "Successfully open $old_kmeans. ";
	print STDOUT "Reading & extracting cluster numbers.....";

	%cluster_numbers = (); # holds cluster numbers, each is referenced to by
	                       # "$project-$run-$clone-$time"
	while (my $line = <OLD_KMEANS>) {
		chomp($line);
		foreach ($line) {
			s/^\s+//; # remove all leading whitespaces
			s/\s+$//; # remove all trailing whitespaces
			s/\s+/ /g;# replace any consecutive whitespaces by a single one
		}

		my @items = split(' ', $line);

		my $cluster = int($items[0]);
		my $project = int($items[8]);
		my $run     = int($items[9]);
		my $clone   = int($items[10]);
		my $time    = int($items[11]);

		$cluster_numbers{"$project-$run-$clone-$time"} = $cluster;
	}
	print STDOUT "Done!\n";
	close OLD_KMEANS;


# ------------------- Attach cluster numbers to new file -----------------------
	open(NEW_NATIVE, "<", $new_native)
	or die "Cannot open $new_native. $!.\n";

	open(NEW_KMEANS, ">", $output)
	or die "Cannot write $output. $!.\n";

	print STDOUT "Successfully open $new_native. ";
	print STDOUT "Attaching cluster numbers.....\n";
    print STDOUT "Data points without a cluster number:\n";
	while (my $line = <NEW_NATIVE>) {
		my $original_line = $line;
		chomp($line);
		foreach ($line) {
			s/^\s+//; # remove all leading whitespaces
			s/\s+$//; # remove all trailing whitespaces
			s/\s+/ /g;# replace any consecutive whitespaces by a single one
		}
		my @items = split(' ', $line);

		$project = $items[0];
		$run     = $items[1];
		$clone   = $items[2];
		$time    = $items[3];

		if (exists $cluster_numbers{"$project-$run-$clone-$time"}) {
			print NEW_KMEANS $cluster_numbers{"$project-$run-$clone-$time"}, "\t";
			print NEW_KMEANS $original_line;
		}
		else {
			print STDOUT $cluster_numbers{"$project-$run-$clone-$time"}, ": ";
			print STDOUT $original_line;
		}
	}
    print STDOUT "Attaching cluster numbers.....Done!\n";