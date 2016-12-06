#!/usr/bin/perl


# ================== defaults stuff ==================
# if not provided in projXXXX.conf file
	# $def_frame_size  = 100; # time between frames in ps #
	# $def_framesperwu = 10; 
	# $def_md_timestep = 2.0; # in fs
	# $dir             = "/home/server/FAHdata/PKNOT"; # ?? ****
	# $nm2A            = 10.0; # nm to Angstrom conversion


# ================== setup I/O ==================
	# $home_dir = "/home/server/FAHdata/PKNOT/CLUSTER-CENTERS"; # ?? ****
	$bin_dir  = "/usr/local/share/GRO/gromacs-3.3/bin";  # location of trjconv
	$gro_dir  = "/home/server/FAHdata/PKNOT/PROJ_files"; # location of .ndx files
	
	$infile   = @ARGV[0] || die "\n\tRequires List of Cluster Centers...\n\n"; # chomp $infile;
	$pkname   = @ARGV[1] || die "\n\tRequires Name prefix for output pdb/gro files...\n\n"; #chomp $pkname;


# ================== get frame info & open .db (?) logfile ==================
	open(INFILE,"$infile");
	while(defined($line = <INFILE>)) {
		for($line) {  s/^\s+//; s/\s+$//; s/\s+/ /g; }
		@input = split(/ /,$line); 
		$proj    = 1798;
		$run     = int($input[12]); # int function is to remove trailing 0's
		$clone   = int($input[13]);
		$time    = int($input[14]); print "\$time: $time\n";
		$cluster = $input[0];


# ================== output gromacs files ==================
	# first identify frame number and define .xtc file #
	$frame = int($time/1000);
	# fix time to match time in xtc files #
	$newTime = $time - (1000 * $frame);
 	$file1 = "/home/server/FAHdata/PKNOT/PROJ$proj/RUN$run/CLONE$clone/P$proj"."_R$run"."_C$clone".".xtc";
	$file2 = "/home/server/FAHdata/PKNOT/PROJ$proj/RUN$run/CLONE$clone/frame0.tpr";

	if((-e $file1)&&(-e $file2)){
		# copy xtc and tpr files to current working directory
		system("cp $file1 ./current_frame.xtc");
		system("cp $file2 ./current_frame.tpr");

		# define input filenames for trjconv
		$xtcfile = "current_frame.xtc";
		$tprfile = "current_frame.tpr";
		if($proj == 1796){ $ndxfile = "$gro_dir/p1796_2A43_luteo.ndx"; }
		if($proj == 1797){ $ndxfile = "$gro_dir/p1797_2G1W_aquifex.ndx"; }
		if($proj == 1798){ $ndxfile = "$gro_dir/p1798_2A43_luteo.ndx"; }
		if($proj == 1799){ $ndxfile = "$gro_dir/p1799_2G1W_aquifex.ndx"; }

		# define output pdb and gro filenames
		$clusterstr = sprintf("%02s",$cluster);
		$pdbout = "c$clusterstr"."_"."$pkname"."_p$proj"."_r$run"."_c$clone"."_t$time".".pdb";
		$groout = "c$clusterstr"."_"."$pkname"."_p$proj"."_r$run"."_c$clone"."_t$time".".gro";
		
		# generate pdb and gro files
		system("echo 1 | $bin_dir/trjconv -f $xtcfile -s $tprfile -n $ndxfile -dump $newTime -o $pdbout");	
		system("echo 1 | $bin_dir/trjconv -f $xtcfile -s $tprfile -n $ndxfile -dump $newTime -o $groout");

		# these are backup of the above commands
		# system("echo 1 | $bin_dir/trjconv -f $xtcfile -s $tprfile -n $ndxfile -dump $newTime -o $pdbout");	
		# system("echo 1 | $bin_dir/trjconv -f $xtcfile -s $tprfile -n $ndxfile -dump $newTime -o $groout");
		
		print STDOUT "Completed CLUSTER $cluster PROJ $proj  RUN $run  CLONE $clone  TIME $time newTime $newTime  FRAME $frame \n";
		`rm current_frame.xtc current_frame.tpr`;
  	}
}
close(INFILE);