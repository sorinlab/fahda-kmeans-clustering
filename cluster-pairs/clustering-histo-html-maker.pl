#!/usr/bin/perl

$usage           = "\$  ./script.pl  <histos_location>  <vector length>  <output html>";
$histos_location = $ARGV[0] or die "$usage\n";
$vectorLength    = $ARGV[1] or die "$usage\n";
$output          = $ARGV[2] or die "$usage\n";

# ------------------------------------------------------------------------------
# CONSTANTS & VARIABLES
$html_head = 
"<!DOCTYPE html>
<html lang=\"en\">
<head>
	<meta charset=\"UTF-8\" />
	<link rel=\"stylesheet\" type=\"text/css\" href=\"../../css/histo.css\">
</head>
 
<body>
";

$html_table_head =
"\t<TABLE>
\t\t<THEAD><TR>
\t\t\t<TH>Cluster Pair</TH>
\t\t\t<TH>RMSD</TH>
\t\t\t<TH>R<sub>g</sub></TH>
\t\t\t<TH>S1</TH>
\t\t\t<TH>S2</TH>
\t\t\t<TH>L2</TH>
\t\t\t<TH>T</TH>
\t\t\t<TH>NNC</TH>
\t\t</TR></THEAD>
\t\t<TBODY>
";

$html_table_tail = 
"\t\t</TBODY>
\t</TABLE>
";

$html_foot = 
"</body>
</html>
";

# ------------------------------------------------------------------------------
# WRITE TO OUTPUT 
	open (OUTPUT, ">$output") or die "Cannot write to output file $output. $!\n";

	

	# sort the files in correct order
	@PNGs = `ls $histos_location`;
	open (TEMP, ">temp.txt") or die "Cannot write to temp.txt. $!\n";
	foreach my $filename (@PNGs) { 
		chomp($filename);
		$original_filename = $filename;
		$filename =~ s/\.png$//;
		@numbers = split("-", $filename);
		foreach my $number (@numbers) {
			print TEMP "$number\t";
		}
		print TEMP "$original_filename\n";
	}
	close(TEMP);
	`sort -n -k 1,1 -k 2,2 temp.txt > temp1.txt`;
	`mv temp1.txt temp.txt`;

	# Print HTML head and TABLE head
	print OUTPUT $html_head;
	print OUTPUT $html_table_head;

	open (TEMP, "<temp.txt") or die "Cannot read from temp.txt. $!\n";
	while (my $line = <TEMP>) {
		chomp($line);
		foreach($line) { s/^\s+//; s/\s+$//; s/\s+/ /g; }
		@items = split(/ /, $line);

		# Starting a row with cluster-cluster pair
		if ( ($. % $vectorLength) == 1) {
			print OUTPUT "\t\t\t<TR>\n";
			print OUTPUT "\t\t\t\t<TD>$items[0]-$items[1]</TD>\n";
		}

		# print a row of images
		print OUTPUT "\t\t\t\t<TD>";
		print OUTPUT "<a href=\"$histos_location/$items[3]\">";
		print OUTPUT "<img src=\"$histos_location/$items[3]\" width=200px height=200px/>"; 
		print OUTPUT "</a> ";
		print OUTPUT "</TD>\n";

		# end the row if $vectorLength images have been printed
		if ( ($. % $vectorLength) == 0) {
			print OUTPUT "\t\t\t</TR>\n";
		}
	}

	# Print TABLE tail and HTML tail
	print OUTPUT $html_table_tail;
	print OUTPUT $html_foot;

	`trash temp.txt`;
	
	close(TEMP);
	close(OUTPUT);
