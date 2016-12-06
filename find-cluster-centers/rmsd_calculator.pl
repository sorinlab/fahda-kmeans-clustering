#!/usr/bin/perl

# KHAI REMIX
# FALL 2014

$usage = "\$ $0  -s ref.pdb|gro  -n index.ndx  -di structures_dir  -fi pdb|gro  -do xvg_outs_dir";
# ========================= CONSTANT(S) ========================================
$G_RMS = "/usr/local/share/GRO/gromacs-3.3/bin/g_rms";  # location of g_rms

# ======================== OBTAIN ARGUMENTS ====================================
	if (@ARGV)
	{
		for ($i = 0; $i <= $#ARGV; $i++)
		{
			if ($ARGV[$i] eq "-s") { $i++; $ref_structure = $ARGV[$i]; next; }
			elsif ($ARGV[$i] eq "-n") { $i++; $index_file = $ARGV[$i]; next; }
			elsif ($ARGV[$i] eq "-di") { $i++; $structures_dir = $ARGV[$i]; next; }
			elsif ($ARGV[$i] eq "-fi") { $i++; $extension = $ARGV[$i]; next; }
			elsif ($ARGV[$i] eq "-do") { $i++; $xvg_outs_dir = $ARGV[$i]; next; }
		}

		if ($ARGV[0] =~ m/-h|--help/)
		{
			print "$usage\n";
			print "[Exit code: 0]\n";
			exit;
		}
	}
	else
	{
		print "ERROR: Missing argument(s)\n$usage\n";
		print "[Exit code: 1]\n";
		exit;
	}


# ================== get frame info & open .db (?) logfile ==================
	@structures = `ls $structure_dir | grep $extension`;
	foreach my $structure (@structures)
	{
		chomp $structure;
		my $xvg = $structure;

		if ($structures_dir =~ m/\/$/)
		{  $structure = "${structures_dir}${structure}";  }
		else
		{  $structure = "${structures_dir}/${structure}"; }

		$xvg =~ s/$extension$//i; # remove extension
		$xvg =~ s/\.$//; # remove the dot if there's one
		if ($xvg_outs_dir =~ m/\/$/)
		{ $xvg = "${xvg_outs_dir}${xvg}"; }
		else
		{ $xvg = "$xvg_outs_dir/$xvg"; }

		`echo 1 1 | $G_RMS -s $ref_structure -f $structure -n $index_file -o $xvg`;
	}
