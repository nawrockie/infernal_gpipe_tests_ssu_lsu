#!/usr/bin/env perl
# EPN, Fri Jul 10 12:48:45 2015
# step9-helper-summarize-all-comparisons.pl:
# 
# Given two method names from the following list:
# 'infernal'
# 'rnammer'
# 'ncbi-rRNA'
# 'ncbi-rRNA-misc'
# Look at files created by step9-wrapper-compare-gff.pl that compared
# results from the two methods and write one summary of all of them.
# This script relies on specific naming conventions that step9-wrapper-compare-gff.pl
# uses and if those change, this script will need to be changed
# accordingly.
use strict;
use warnings;

my $usage = "perl step9-helper-summarize-all-comparisons.pl <method1> <method2> <directory with files to use>\n";
$usage .= "\tacceptable values for 'method1' and 'method2' are:\n";
$usage .= "\t\t'ncbi-rRNA'\n";
$usage .= "\t\t'ncbi-rRNA-misc'\n";
$usage .= "\t\t'rnammer'\n";
$usage .= "\t\t'infernal'\n";

if(scalar(@ARGV) != 3) { 
  die $usage;
}
my ($method1, $method2, $dir) = (@ARGV);
if($method1 ne "ncbi-rRNA" && $method1 ne "ncbi-rRNA-misc" && $method1 ne "rnammer" && $method1 ne "infernal") { die $usage; }
if($method2 ne "ncbi-rRNA" && $method2 ne "ncbi-rRNA-misc" && $method2 ne "rnammer" && $method2 ne "infernal") { die $usage; }

$dir =~ s/\/$//; # remove trailing / if it exists

# make sure we have all the files we need:
my @dom_fam_A = ("all", "bac-ssu", "arc-ssu", "bac-lsu", "arc-lsu");
my @file_A = ();

# go through each file 
for(my $df = 0; $df < scalar(@dom_fam_A); $df++) { 
  my $dom_fam = $dom_fam_A[$df];
  my $file = $dir . "/" . $method1 . "-v-" . $method2 . "-" . $dom_fam . ".compare-gff";

# DO NOT PRINT THIS PART:
# Domain:                arc-bac
# Family:                ssu-lsu
# GFF file 1:            infernal.arc-bac.ssu-lsu.gff.concat
# GFF file 1 output key: infernal-arc-bac-ssu-lsu
# GFF file 2:            rnammer.arc-bac.ssu-lsu.gff.concat
# GFF file 2 output key: rnammer-arc-bac-ssu-lsu
# Output Key:            infernal-v-rnammer-arc-bac-ssu-lsu
#
# DO PRINT THIS PART OF ONLY FILE 1:
#domain  family   method           #hit-tot    #nt-tot  avgnt-tot     #ident   #hit-olp    #nt-olp   frct-olp   #hit-unq    #nt-unq  avgnt-unq
#------  -------  --------------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------
# 
# DO PRINT THIS PART OF ALL FILES
#arc-bac  ssu-lsu  infernal              363     544009     1498.6         27        192     423491     0.9000        144      73438      510.0
#arc-bac  ssu-lsu  rnammer               219     477463     2180.2         27        192     423486     0.8870          0          0        0.0
#
# DO PRINT THIS PART OF ONLY FINAL FILE:
# Explanation of columns:
#
#   domain:    'arc' or 'bac' or 'arc-bac' for archaea, bacteria or both
#   family:    'ssu' or 'lsu' or 'ssu-lsu' for 16S small subunit rRNA or 23S large subunit rRNA or both
#   method:    'infernal', 'rnammer', 'ncbi-rRNA' (includes only 'gbkey=rRNA' annotations), or
#              'ncbi-rRNA-misc' (includes 'gbkey=rRNA' and 'gbkey=misc_feature' annotations)
#   #hit-tot:  total number of hits/annotations
#   #nt-tot:   total number of nucleotides in all hits/annotations
#   avgnt-tot: average length of a hit/annotation
#   #ident:    number of identical annotations with adjacent row
#   #hit-olp:  number of non-identical but overlapping annotations (at least 1 nt) with adjacent row
#   #nt-olp:   number of nucleotides in this methods annotations that overlap with
#              adjacent row's annotations
#   frct-olp:  fraction of nucleotides in this methods annotations that overlap with
#              adjacent row's annotations
#   #hit-unq:  number of this method's 'unique' annotations, these do not overlap with any of
#              adjacent row's annotations (by >=1 nucleotides)
#   #nt-unq:   number of nucleotides in this method's unique annotations
#   avgnt-unq: average length of this method's unique annotations

  open(IN, $file) || die "ERROR unable to open required file $file"; 
  while(my $line = <IN>) { 
    if($df == 0 && $line =~ m/^\#domain/) { 
      print $line; 
      $line = <IN>;
      print $line;
    }
    if($line !~ m/^\#/) {
      print $line; 
      $line = <IN>;
      print $line;
      print "#\n"; # a separating line
    }
    if($df == (scalar(@dom_fam_A)-1) && $line =~ m/^\# Explanation of columns/) { 
      while($line !~ m/^\#\s+avgnt-unq\:/) { 
        print $line; 
        $line = <IN>;
      }
    }
  }
  close(IN);
}
