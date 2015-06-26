#!/usr/bin/env perl
# EPN, Fri Jun 26 15:34:24 2015
# step5-remove-infernal-overlaps.pl:
# 
# Given a file that lists of 'genome keys' and corresponding
# fasta files, remove overlaps from infernal output files.
# 
# Input file: multiple lines of two tab-delimited fields:
#  <genome-key> <genome-fasta-file>
#
# Input is generated as output of related script: step2-get-100-random-genomes.pl.
# 
use strict;
use warnings;

my $usage = "perl step5-remove-infernal-overlaps.pl\n";
$usage .= "\t<genome list output from step1 (either arc.r25.genome.list or bac.r50.genome.list)>\n";
$usage .= "\t<output dir name with infernal output files\n";

if(scalar(@ARGV) != 2) { 
  die $usage;
}
my ($infile, $outdir) = (@ARGV);
my $do_arc = 0;
my $do_bac = 0;

# make sure our input file begins with 'arc.' or 'bac.'
if   ($infile =~ m/^arc\./) { $do_arc = 1; $do_bac = 0; }
elsif($infile =~ m/^bac\./) { $do_arc = 0; $do_bac = 1; }
else { die "ERROR input genome list file must begin with 'arc.' or 'bac.', $infile does not."; }
  
# hard-coded paths
my $idir    = "/usr/local/infernal/1.1.1/bin";
my @cmfileA = ("ssu-and-lsu-all.cm");
if($do_arc) { 
  push(@cmfileA, "ssu-arc.cm"); 
  push(@cmfileA, "lsu-arc.cm"); 
}
elsif($do_bac) { 
  push(@cmfileA, "ssu-bac.cm"); 
  push(@cmfileA, "lsu-bac.cm"); 
}

my $cmopts = "--cut_ga --rfam --cpu 0 --nohmmonly";

# ensure our CM files exist
foreach my $cmfile (@cmfileA) { 
  if(! -s $cmfile) { die "ERROR $cmfile does not exist"; }
}

if(! -d $outdir) { die "ERROR directory named $outdir does not exist"; }

open(IN, $infile) || die "ERROR unable to open file $infile for reading"; 

while(my $line = <IN>) { 
  # Example line:
  # Nanoarchaeota_archaeon_SCGC_AAA011-D5	/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Nanoarchaeota_archaeon_SCGC_AAA011-D5/696928-DENOVO-20150227-1757.1483344/output/bacterial_annot/ASMP01.annotation.nucleotide.fa

  chomp $line;
  my ($fakey, $fafile) = split(/\t/, $line);
  if(! -e $fafile) { die "ERROR fasta file $fafile for key $fakey does not exist"; }

  my $cmkey = "ssu-and-lsu-all";
  
  my $root       = $outdir . "/" . $fakey . "." . $cmkey;
  my $tbloutfile = $root . ".tbl"; 
  my $deoverlapped_tbloutfile = $root . ".deoverlapped.tbl"; 

  
  if(! -e $tbloutfile) { die "ERROR $tbloutfile does not exist"; }
  my $cmd = "grep -v \\# $tbloutfile | sort -k16,16g -k15,15rn | perl remove-overlaps.pl > $deoverlapped_tbloutfile";
  # print("Running $cmd ... ");
  printf("Removing overlaps from %-85s with remove-overlaps.pl ... ", $tbloutfile);
  RunCommand($cmd);
  print("done.\n");
}
exit 0;

#############
# SUBROUTINES
#############
#
# Subroutine: RunCommand()
# Args:       $cmd:            command to run, with a "system" command;
#
# Returns:    void
# Dies:       if $cmd fails

sub RunCommand {
  if(scalar(@_) != 1) { die "ERROR RunCommand() entered with wrong number of input args"; }

  my ($cmd) = @_;

  system($cmd);
  if($? != 0) { die "ERROR command failed:\n$cmd\n"; }

  return;
}
