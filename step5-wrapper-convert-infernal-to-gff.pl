#!/usr/bin/env perl
# EPN, Tue Jul  7 09:29:52 2015
#
# step5-wrapper-convert-infernal-to-gff.pl
#
# Formerly: https://github.com/nawrockie/infernal_gpipe_tests_upgrade_to_1p1.git:
# step6-convert-i1p1-to-gff.pl
# 
# Given a list of Infernal 1.1 cmsearch --tblout output files,
# convert each of them to gff files.
# 
# Each of the tblout files must end with .tbl.
#
# Takes one command line argument, or pipe in a list of files
# <file with list of cmsearch v1.1 tblout files>
# should have N lines, each with the name of a single tab file
#
use strict;
use warnings;

# hard-coded paths
my $script_dir = "./";
my $gff_script = $script_dir . "step5-helper-convert-infernal-to-gff.pl";
if(! -s $gff_script) { die "ERROR required script $gff_script does not exist"; }

my $usage = "perl step5-wrapper-convert-infernal-to-gff.pl <file with list of Infernal 1.1 tblout files>";
#if(scalar(@ARGV) != 1) { die $usage; }


my $nfiles = 0;
my $gff_file;

while(my $line = <>) { 
  my $tbl_file = $line;
  chomp $tbl_file;
  #1p1/crenarchaeote_SCGC_AAA261-L22.5S.tbl
  if($tbl_file =~ /(^.+).tbl/) { 
    $gff_file = $1 . ".gff";
  }
  else { 
    die "ERROR $tbl_file does not end in .tbl"; 
  }
  RunCommand("perl $gff_script $tbl_file > $gff_file");
  $nfiles++;
}

printf("GFF files created for $nfiles Infernal 1.1 tblout files\n");
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
