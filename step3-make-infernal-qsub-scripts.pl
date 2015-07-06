#!/usr/bin/env perl
# EPN, Wed Jun 24 16:24:04 2015
# step3-make-infernal-qsub-scripts.pl: 
# 
# Given a file that lists of 'genome keys' and corresponding
# fasta files, create a qsub script that will submit 
# three Infernal 1.1.1 cmsearch commands for each genome.
# Each command will use a different CM file:
# M1) ssu-and-lsu-all.cm
# M2) ssu.arc.cm OR ssu.bac.cm (depending on name of genome list provided on cmdline)
# M3) lsu.arc.cm OR lsu.bac.cm (depending on name of genome list provided on cmdline)
# 
# Input file: multiple lines of two tab-delimited fields:
#  <genome-key> <genome-fasta-file>
#
# Input is generated as output of related script: step2-get-100-random-genomes.pl.
# 
use strict;
use warnings;

my $usage = "perl step3-make-infernal-qsub-scripts.pl\n";
$usage .= "\t<genome list output from step1 (either arc.r25.genome.list or bac.r50.genome.list)>\n";
$usage .= "\t<output dir name (will be created, must not already exist>\n";

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

if(-d $outdir) { die "ERROR directory named $outdir already exists. Remove it and try again, or pick a different output dir name"; }

open(IN, $infile) || die "ERROR unable to open file $infile for reading"; 

RunCommand("mkdir $outdir");

while(my $line = <IN>) { 
  # Example line:
  # Nanoarchaeota_archaeon_SCGC_AAA011-D5	/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Nanoarchaeota_archaeon_SCGC_AAA011-D5/696928-DENOVO-20150227-1757.1483344/output/bacterial_annot/ASMP01.annotation.nucleotide.fa

  chomp $line;
  my ($fakey, $fafile) = split(/\t/, $line);
  if(! -e $fafile) { die "ERROR fasta file $fafile for key $fakey does not exist"; }

  for(my $c = 0; $c < scalar(@cmfileA); $c++) { 
    my $cmfile = $cmfileA[$c];
    my $cmkey  = $cmfile;
    $cmkey =~ s/\.cm$//;

    my $jobname    = "J" . $fakey . "." . $cmkey;
    my $root       = $outdir . "/" . $fakey . "." . $cmkey;
    my $tbloutfile = $root . ".tbl"; 
    my $stdoutfile = $root . ".cmsearch"; 
    my $errfile    = $root . ".err"; 
    my $timefile   = $root . ".time"; 

    # use /usr/bin/time to time the execution time
    # don't save stdout
    # 144000 seconds is 40 hours
    printf("qsub -N $jobname -b y -v SGE_FACILITIES -P unified -S /bin/bash -cwd -V -j n -o /dev/null -e $errfile -l h_rt=144000,mem_free=8G,h_vmem=16G -m n \"/usr/bin/time $idir/cmsearch $cmopts --tblout $tbloutfile $cmfile $fafile > $stdoutfile 2> $timefile\"\n");
  }
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
