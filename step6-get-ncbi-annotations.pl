#!/usr/bin/env perl
# EPN, Tue Jun 30 11:29:25 2015
# step6-get-ncbi-annotations.pl:
# 
# Given a file that lists of 'genome keys' and corresponding
# fasta files, find the existing GFF annotation of SSU and 
# LSU and create new files for each.
# 
# Input file: multiple lines of two tab-delimited fields:
#  <genome-key> <genome-fasta-file>
#
# Input is generated as output of related script: step2-get-genomes.pl.
# 
use strict;
use warnings;

my $usage = "perl step6-get-ncbi-annotations.pl\n";
$usage .= "\t<genome list output from step1 (either arc.r25.genome.list or bac.r50.genome.list)>\n";
$usage .= "\t<output dir name to put SSU and LSU GFF files in (will be created, must not already exist)\n";

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
  
if(-d $outdir) { die "ERROR directory named $outdir already exists. Remove it and try again, or pick a different output dir name"; }

open(IN, $infile) || die "ERROR unable to open file $infile for reading"; 

RunCommand("mkdir $outdir");

while(my $line = <IN>) { 
  # Example line:
  # Nanoarchaeota_archaeon_SCGC_AAA011-D5	/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Nanoarchaeota_archaeon_SCGC_AAA011-D5/696928-DENOVO-20150227-1757.1483344/output/bacterial_annot/ASMP01.annotation.nucleotide.fa

  chomp $line;
  my ($fakey, $fafile) = split(/\t/, $line);

  my $fafile_dir = $fafile;
  $fafile_dir =~ s/[^\/]*$//;

  # find the GFF file:
  my $gff_file = `ls $fafile_dir/*.annotation.gff`;
  chomp $gff_file;
  if(! -e $gff_file) { die "ERROR $gff_file for key $fakey does not exist"; }

  my $root         = $outdir . $fakey ;
  my $gff_ssu_rRNA = $root . ".ssu.rRNA.gff";
  my $gff_ssu_misc = $root . ".ssu.misc.gff";
  my $gff_lsu_rRNA = $root . ".lsu.rRNA.gff";
  my $gff_lsu_misc = $root . ".lsu.misc.gff";

  open(GFFSR, ">" . $gff_ssu_rRNA) || die "ERROR unable to open $gff_ssu_rRNA for writing";
  open(GFFSM, ">" . $gff_ssu_misc) || die "ERROR unable to open $gff_ssu_misc for writing";
  open(GFFLR, ">" . $gff_lsu_rRNA) || die "ERROR unable to open $gff_lsu_rRNA for writing";
  open(GFFLM, ">" . $gff_lsu_misc) || die "ERROR unable to open $gff_lsu_misc for writing";

  open(GFFIN, $gff_file) || die "ERROR unable to open $gff_file for reading";

  # keep track of the start and end positions so we know when we see a GFF line that has
  # identical boundaries to one we've already saved.
  my @kept_start_A = ();
  my @kept_stop_A  = ();

  printf("parsing GFF file $gff_file\n");
  while($line = <GFFIN>) { 
    if($line !~ m/^\#/) { 
      chomp $line;
      # ASMP01000002.1	Genbank	rRNA	125624	126993	.	+	.	ID=rna23;Parent=gene474;gbkey=rRNA;product=16S ribosomal RNA
      my @elA = split(/\t/, $line);
      my $nel = scalar(@elA);
      # printf("nel: $nel\n"); for(my $z = 0; $z < $nel; $z++) { print "el $z $elA[$z]\n"; }
      if(scalar(@elA) != 9) { die "ERROR, not 8 tokens in line: $line"; }
      my ($accn, $db, $type, $start, $stop, $unknown1, $strand, $unknown2, $extra) = split(/\t/, $line);
      if($line =~ m/rRNA/ || $line =~ m/ribosomal RNA/) { # may want to also add '16S' and '23S'?
        if(($db eq "Genbank" || $db eq "DDBJ" || $db eq "EMBL") && $type eq "rRNA") { 
          # case 1: keeper; print to 'rRNA' file
          # example: 
          # ASMP01000002.1	Genbank	rRNA	125624	126993	.	+	.	ID=rna23;Parent=gene474;gbkey=rRNA;product=16S ribosomal RNA
          if   ($extra =~ m/product=16S ribosomal RNA/) { print GFFSR $line . "\n"; }
          elsif($extra =~ m/product=23S ribosomal RNA/) { print GFFLR $line . "\n"; }
          else { die "ERROR unable to parse rRNA containing GFF line (1): $line"; }
          push(@kept_start_A, $start);
          push(@kept_stop_A,  $stop);
        }
        elsif(($db eq "Genbank" || $db eq "DDBJ" || $db eq "EMBL") && $type eq "region" && $extra =~ m/gbkey=misc_feature/) { 
          # case 2: keeper; print to 'misc' file
          # example:
          # ASMP01000002.1	Genbank	region	130973	131145	.	+	.	ID=id34;Note=possible 23S ribosomal RNA but 16S or 23S rRNA prediction is too short;gbkey=misc_feature
          # example *WITHOUT* 'rRNA' match
          # CP007438.1	Genbank	region	1969925	1971208	.	-	.	ID=id25;Note=16S ribosomal RNA does not have good blast hits on one or both of the ends;gbkey=misc_feature

          my $did_keep = 0;
          if   ($extra =~ m/Note=possible 16S ribosomal RNA but 16S or 23S rRNA prediction is too short/)         { print GFFSM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=possible 23S ribosomal RNA but 16S or 23S rRNA prediction is too short/)         { print GFFLM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=16S ribosomal RNA 16S or 23S rRNA prediction is too short/)                      { print GFFSM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=23S ribosomal RNA 16S or 23S rRNA prediction is too short/)                      { print GFFLM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=16S ribosomal RNA does not have good blast hits on one or both of the ends/)     { print GFFSM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=23S ribosomal RNA does not have good blast hits on one or both of the ends/)     { print GFFLM $line . "\n"; $did_keep = 1; }
          elsif($extra =~ m/Note=possible 23S ribosomal RNA but does not have good blast hits on one or both of the ends/) { print GFFLM $line . "\n"; $did_keep = 1; }

          elsif($extra =~ m/Note=5S ribosomal RNA rRNA prediction is too short/)                                  { ; $did_keep = 0; }
          else { die "ERROR unable to parse rRNA containing GFF line (2): $line"; }
          if($did_keep) { 
            push(@kept_start_A, $start);
            push(@kept_stop_A,  $stop);
          }
        }
        # and types of lines that we don't want to keep, but we'd like to keep track of so we know that 
        # we are accounting for all types of NCBI GFF lines that contain rRNA 
        elsif(($db eq "Genbank" || $db eq "DDBJ" || $db eq "EMBL") && $type eq "exon") { 
          # case 3: NOT a keeper; but make sure we did keep the same coordinates earlier with type 'rRNA'
          # example:
          # ASMP01000002.1	Genbank	exon	125624	126993	.	+	.	ID=id31;Parent=rna23;gbkey=rRNA;product=16S ribosomal RNA
          if((! find_in_array($start, \@kept_start_A)) || (! find_in_array($stop, \@kept_stop_A))) { 
            die "ERROR found 'Genbank exon' rRNA line before a 'Genbank rRNA' rRNA line with same coordinates"; 
          }
        }
        elsif($db eq "Protein Homology" && ($type eq "CDS" || $type eq "gene") && ($extra =~ m/rRNA/ || $extra =~ m/ribosomal RNA/)) { 
          # case 4: NOT a keeper; protein homology that just happens to have rRNA in it's line, possibly a ribosomal protein
          # example: 
          # ASMP01000011.1	Protein Homology	CDS	3152	3275	.	-	1	ID=cds621;Parent=gene656;Name=WGS:ASMP:I749_RS03285;Note=L30 binds domain II of the 23S rRNA and the 5S rRNA%3B similar to eukaryotic protein L7;end_range=3275,.;gbkey=CDS;gene=rpl30p;partial=true;product=50S ribosomal protein L30;protein_id=WGS:ASMP:I749_RS03285;transl_table=11 at step6-get-ncbi-annotations.pl line 107, <GFFIN> line 1386.
          ; # do nothing; protein that has rRNA in it's extra field
        }
        elsif($db eq "cmsearch" && $type eq "rRNA" && $extra =~ m/product=5S ribosomal RNA/) { 
          # case 5: NOT a keeper; 5S cmsearch prediction
          # example: 
          # AVSQ01000002.1	cmsearch	rRNA	35477	35596	.	-	.	ID=rna4;Parent=gene51;gbkey=rRNA;product=5S ribosomal RNA at step6-get-ncbi-annotations.pl line 107, <GFFIN> line 118.
          ; # do nothing, cmsearch 5S annotation
        }
        elsif($db eq "cmsearch" && $type eq "exon" && $extra =~ m/product=5S ribosomal RNA/) { 
          # case 6: NOT a keeper; 5S cmsearch prediction
          # NOTE: same as case 6 but type is "exon" instead of "rRNA"
          # example:
          # AVSQ01000002.1	cmsearch	exon	35477	35596	.	-	.	ID=id8;Parent=rna4;gbkey=rRNA;product=5S ribosomal RNA at step6-get-ncbi-annotations.pl line 114, <GFFIN> line 119.
          ; # do nothing, cmsearch 5S annotation
        }
        elsif(($db eq "Genbank" || $db eq "EMBL") && $type eq "gene" && $extra =~ m/old\_locus\_tag=[^\;]*rRNA/) { 
          # case 7: NOT a keeper; oddball, found one example
          # example:
          # HF922670.1	EMBL	gene	59	1566	.	+	.	ID=gene11;Name=BN179_RS00060;gbkey=Gene;locus_tag=BN179_RS00060;old_locus_tag=BN179_16s_rRNA_1 at step6-get-ncbi-annotations.pl line 140, <GFFIN> line 32.
          ; # do nothing
        }
        else { 
          die "ERROR unable to parse rRNA containing GFF line (3): $line"; 
        }
      }
    } # end of 'if($line !~ m/^\#/)'
  }
  close(GFFIN);
  close(GFFSR);
  close(GFFSM);
  close(GFFLR);
  close(GFFLM);
}
close(IN);
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
#
# Subroutine: find_in_array()
# Args:       $el: element to look for in $AR
#             $AR: reference to array to look in
#
# Returns:    '1' if $el is found in @{$AR} else '0'.

sub find_in_array { 
  if(scalar(@_) != 2) { die "ERROR find_in_array() entered with wrong number of input args"; }

  my ($el, $AR) = @_;

  my $nel = scalar(@{$AR});
  for(my $i = 0; $i < $nel; $i++) { 
    if($AR->[$i] eq $el || $AR->[$i] == $el) { 
      return 1;
    }
  }
  return 0;
}
