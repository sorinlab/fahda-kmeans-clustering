#!/usr/bin/perl
############################################################################################################
########   Calculating Cluster Center Distances Using an NX15 Matrix and Printing Out a List! ##############
########    Written by:  Amethyst Radcliffe
############################################################################################################
	## Opening up data file and output file ##
$data = $ARGV[0] || die "Didnt catch the centers file\n";
$output = $ARGV[1] || die "Didnt catch the output file\n";
open OUT, ">$output" or die "Unable to print output";
open DATA, $data or die "Unable to open the data file";
        ## Reading the data in line by line
while ($line = <DATA>) {  ### For each line, it will...
        chomp ($line);    ### ..cut off any extra newlines
        
	##... and for each line, it cuts out the spaces and splits the numbers into an array
        foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g;} 
        @num = split(/ /,$line);
        $num = [@num];    ### Then takes each array created in the loop and pushes it into another array
        push @data, $num;
}     
#######################################################################################
$index = scalar(@data); # keeps track of the number of input data
$index2 = scalar(@num);	
## Closing data file
close DATA;  
#######################################################################################
	## Establishing the matrix
######################################################################################
	## Running calculations
for ($i=0; $i<$index; $i++) {
	for ($k=0; $k<$index; $k++){
	for ($j=2; $j<$index2; $j++){	## Sets up variable j
			$distance = (($data[$i][$j]-$data[$k][$j])**2);   ## Shorthand for: Calculating each dimension 	
									  ## vector seperatly, then squaring it.
			push (@dist, $distance);}   ## loads the results into an array @dist
			my $total = 0;		    ## Ok this I pulled from online... It sums the elements in an array
			$total += $_ for @dist;	    ## Adding together the calculations from each of the dimensions
			$sqrt = sqrt($total);	    ## Then squaring the sum to give the magnituide as an output
			push (@mags, $sqrt);  	    ## The magnitudes are then stored in another array and the systems resets
			@dist=0;
			print OUT "C$data[$i][0]   C$data[$k][0]   $sqrt\n";}}
	

print "It worked\n";
#print "@dist\n", "$index\n";
##################################################################################
close OUT;
