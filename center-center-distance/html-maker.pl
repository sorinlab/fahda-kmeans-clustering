#!/usr/bin/perl


# ------------------------------------------------------------------------------
# CONSTANTS & VARIABLES
$html_head = 
"<!DOCTYPE html>
<html lang=\"en\">
<head>
	<meta charset=\"UTF-8\" />
	<link rel=\"stylesheet\" type=\"text/css\" href=\"HTML_resources/css/main.css\">
	<script type=\"text/javascript\" src=\"HTML_resources/sorttable.js\"></script> 
</head>
 
<body>
";

$html_foot = 
"</body>
</html>
";


for ($i = 1; $i <= 110; $i++)
{
	$input = "outputs.txt/pknot.Trial_${i}_clusterDistance.txt";
	$output = "outputs.html/pknot.Trial_${i}_clusterDistance.html";
	open INPUT, "<$input" or die "ERROR: Cannot open $input. $!\n";
	open OUTPUT, ">$output" or die "ERROR: Cannot write to output file $output. $!\n";

	# Write header to html file
	print OUTPUT $html_head;

	# Begin the HTML table
	print OUTPUT "\t<TABLE class=\"sortable\">\n";
	print OUTPUT "\t<THEAD>\n";
	print OUTPUT "\t\t<TH><em>i</em></TH>\n";
	print OUTPUT "\t\t<TH><em>j</em></TH>\n";
	print OUTPUT "\t\t<TH>Distance</TH>\n";
	print OUTPUT "\t</THEAD>\n";
	print OUTPUT "\t<TBODY>\n";

	while (my $line = <INPUT>)
	{
		foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g; }
		my @numbers = split(/ /, $line);

		print OUTPUT "\t\t<TR>\n";
		foreach my $item (@numbers)
		{
			print OUTPUT "\t\t\t<TD>";
			print OUTPUT "$item";
			print OUTPUT "</TD>\n";
		}
		print OUTPUT "\t\t</TR>\n";
	}

	# End the HTML table
	print OUTPUT "\t</TBODY>\n";
	print OUTPUT "\t</TABLE>\n";
	print OUTPUT $html_foot;
	
	close INPUT;
	close OUTPUT;
}