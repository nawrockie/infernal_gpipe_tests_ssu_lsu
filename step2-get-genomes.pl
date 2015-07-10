#!/usr/bin/env perl
# EPN, Thu Mar 19 08:46:06 2015
#
# step2-get-genomes.pl: make a list of 25 randomly selected 
# archaeal genomes and 50 randomly selected bacterial genomes 
# from /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/.
# 

use strict;
use warnings;

# hard-coded paths
my $datadir = "/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/";
my $selectn = "/usr/local/infernal/1.1.1/bin/esl-selectn";

my $noutput = 0;

# list all the directories to a file which we'll randomly choose 100 from
RunCommand("ls $datadir > data19.2851.list");

# partition the set into bacteria and archaea using keywords
open(ARC, ">arc.all-genomes.list") || die "ERROR unable to open arc.all-genomes.list for writing";
open(BAC, ">bac.all-genomes.list") || die "ERROR unable to open bac.all-genomes.list for writing";

my %arc_key_H = (); # will hold as keys strings that indicate a genome is archaea, not bacteria
$arc_key_H{"archae"} = 1;
# from https://en.wikipedia.org/wiki/Category:Archaea_species
$arc_key_H{"aeropynum"} = 1;
$arc_key_H{"cenarchaeum"} = 1;
$arc_key_H{"halobacterium"} = 1;
$arc_key_H{"halobiforma"} = 1;
$arc_key_H{"haloferax"} = 1;
$arc_key_H{"haloquadratum"} = 1;
$arc_key_H{"halorubrum"} = 1;
$arc_key_H{"methanobrevibacter"} = 1;
$arc_key_H{"methanocella"} = 1;
$arc_key_H{"methanococcoides"} = 1;
$arc_key_H{"methanogenium"} = 1;
$arc_key_H{"methanosarcina"} = 1;
$arc_key_H{"methanosphaera"} = 1;
$arc_key_H{"methanothrix"} = 1;
$arc_key_H{"methylosphaera"} = 1;
$arc_key_H{"nanoarchaeum"} = 1;
$arc_key_H{"palaeococcus"} = 1;
$arc_key_H{"picrophilus"} = 1;
$arc_key_H{"pyrococcus"} = 1;
$arc_key_H{"pyrodictium"} = 1;
$arc_key_H{"pyrolobus"} = 1;
$arc_key_H{"thermococcus"} = 1;
# ones I added after manually looking up results of script
$arc_key_H{"natrinema"} = 1;
$arc_key_H{"methanocorpusculum"} = 1;
$arc_key_H{"methanomicrobium"} = 1;

open(IN, "data19.2851.list") || die "ERROR unable to open data19.2851.list for reading";
while(my $line = <IN>) { 
  my $orig_line = $line;
  chomp $line;
  $line =~ tr/A-Z/a-z/;   # convert to lowercase
  my $narc_match = 0;
  foreach my $key (keys %arc_key_H) { 
    if($line =~ m/$key/) { 
      $narc_match++; 
    }
  }
  if($narc_match > 0) { print ARC $orig_line; }
  else                { print BAC $orig_line; }
}
close(IN);
close(ARC);
close(BAC);
# arc.all-genomes.list will have 46 genomes listed in it
# bac.all-genomes.list will have 2805 genomes listed in it

# randomly select 30 archaeal and 60 bacterial genomes, we only need
# 25 archaea and 50 bacteria but we choose a few more here because not
# all directories listed in 2851.list will have annotation (a few
# percent do not)
RunCommand("$selectn --seed 34 30 arc.all-genomes.list > arc.r30.list");
RunCommand("$selectn --seed 35 60 bac.all-genomes.list > bac.r60.list");

# for each genome directory $gdir listed in arc.r30.list and
# bac.r60.list, look for a *.nucleotide.fa file in the most recently
# modified directory in $datadir/$gdir/output/bacterial_annot/
for(my $pass = 0; $pass < 2; $pass++) { 
  my $ntarget; # defined as 25 or 50 depending on whether we are outputting archaeal or bacterial genomes.
  if   ($pass == 0) { 
    open(IN,  "arc.r30.list")         || die "ERROR unable to open arc.r30.list for reading"; 
    open(OUT, ">arc.r25.genome.list") || die "ERROR unable to open arc.r25.genome.list for writing"; 
    $ntarget = 25;
  }
  elsif($pass == 1) { 
    open(IN,  "bac.r60.list")         || die "ERROR unable to open bac.r60.list"; 
    open(OUT, ">bac.r50.genome.list") || die "ERROR unable to open bac.r50.genome.list for writing"; 
    $ntarget = 50;
  }

  my $success = 0; # set to '1' when we have output $ntarget genomes
  my $noutput = 0;
  while(! $success) { 
    my $key = <IN>;
    if(! defined $key) { die "ERROR, only output $noutput lines, didn't get to $ntarget"; }
    chomp $key;
    my $dir = $datadir . $key;
    # example $dir: /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976/Actinobacillus_ureae_ATCC_25976  
    
    my @subdirA = split(/\n/, `ls -ltr $dir | grep ^d | awk '{ print \$9 }'`);
    # example of 'ls -ltr' output:
    # > ls -ltr /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976
    # total 128
    # drwxrwsr-x 3 gpipe contig 4096 Feb 27 15:54 244828-DENOVO-20150227-1402.1474874
    # drwxrwsr-x 6 gpipe contig 4096 Mar  1 16:33 244828-DENOVO-20150227-1622.1478424
    #
    # will give @subdirA = ("244828-DENOVO-20150227-1402.1474874", "244828-DENOVO-20150227-1622.1478424");
    
    # we are only interested in the most recent subdir, which will be $subdirA[(scalar(@subdirA)-1)]
    # determine if there's a *.annotation.nucleotide.fa file in the '/output/bacterial_annot' subdirectory in there.
    my $fafile_dir = $dir. "/" . $subdirA[(scalar(@subdirA)-1)] . "/output/bacterial_annot";
    my $fafile     = `ls $fafile_dir/*.annotation.nucleotide.fa`;
    # example $fafile:
    # /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976/244828-DENOVO-20150227-1622.1478424/output/bacterial_annot/AEVG01.annotation.nucleotide.fa
    
    if(defined $fafile && $fafile ne "") { 
      # there is a fasta file, make sure there's only 1
      if($fafile =~ m/\w+\n\w+/) { die "ERROR more than one *.annotation.nucleotide.fa file in $fafile_dir"; }
      
      # if we get here, there's only 1 fasta file, output it
      print OUT $key . "\t" . $fafile;
      $noutput++;
      if($noutput == $ntarget) { # success
        $success = 1; # breaks loop above
      }
    }
  } # end of while(! $success) 
  close(IN);
  close(OUT);
} # end of 'for(my $pass = 0; $pass < 2; $pass++)' 

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
