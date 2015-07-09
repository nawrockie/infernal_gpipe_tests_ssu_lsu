#!/usr/bin/env perl
# EPN, Mon Jul  6 14:54:32 2015
# step8-compare-gff.pl
# 
# Compare two gff files. Create 4 output files:
# 1. <key3>.id:     identical hits found by same model in both GFF files, same coordinates and strand
# 2. <key3>.ol:     overlapping hits found by same model in both GFF files, same strand
# 3. <key3>.unq<key1>: annotation found in gff file 1, for which no annotation in file 2 overlaps 
# 4. <key3>.unq<key2>: annotation found in gff file 2, for which no annotation in file 1 overlaps
#
use strict;
use warnings;
use Getopt::Long;

my $do_reducenames = 1;
my $do_leavenames  = 0;

my $usage  = "perl step8-compare-gff.pl\n"; 
   $usage .= "\t<gff file 1>\n\t<file 1 key for naming output files for file 1>\n";
   $usage .= "\t<gff file 2>\n\t<file 2 key for naming output files for file 2>\n";
   $usage .= "\t<third key for naming all output files>\n\n";
   $usage .= "\tOPTIONS:\n";
   $usage .= "\t -leavenames: do not reduce any sequence names of the form gi|\\d+|\\w+|\\S+\| to \\S+\n";

&GetOptions( "leavenames" => \$do_leavenames);

if($do_leavenames) { $do_reducenames = 0; }

if(scalar(@ARGV) != 5) { die $usage; }
my ($gff1, $key1, $gff2, $key2, $key3) = (@ARGV);

if(! -e $gff1) { die "ERROR no file $gff1 exists"; }
if(! -e $gff2) { die "ERROR no file $gff2 exists"; }

my %hits1_HA = (); # hash of hashes of arrays for gff file 1,  key: target sequence name, value: array of "<start>.<end>.<strand>"
my %hits2_HA = (); # hash of hashes of arrays for gff file 2,  key: target sequence name, value: array of "<start>.<end>.<strand>"
my $nhits1   = 0;  # number of hits in $gff1 file
my $nhits2   = 0;  # number of hits in $gff2 file
my $nnt1     = 0;  # number of nucleotides in all hits in $gff1 file
my $nnt2     = 0;  # number of nucleotides in all hits in $gff2 file

parse_gff($gff1, \$nhits1, \$nnt1, \%hits1_HA, $do_reducenames);
parse_gff($gff2, \$nhits2, \$nnt2, \%hits2_HA, $do_reducenames);

printf("# GFF file 1:            $gff1\n");
printf("# GFF file 1 output key: $key1\n");
printf("# GFF file 2:            $gff2\n");
printf("# GFF file 2 output key: $key2\n");
printf("# Output Key: $key3\n");
printf("#\n");

# open output file handles and print column headers
my ($id_FH, $ol_FH, $unq1_FH, $unq2_FH);
my $id_file   = $key3 . ".id";
my $ol_file   = $key3 . ".ol";
my $unq1_file = $key3 . ".unq1";
my $unq2_file = $key3 . ".unq2";
open($id_FH,   ">" . $id_file)   || die "ERROR unable to open $id_file for writing"; 
open($ol_FH,   ">" . $ol_file)   || die "ERROR unable to open $ol_file for writing"; 
open($unq1_FH, ">" . $unq1_file) || die "ERROR unable to open $unq1_file for writing"; 
open($unq2_FH, ">" . $unq2_file) || die "ERROR unable to open $unq2_file for writing"; 

printf $id_FH   ("# GFF file 1 (key: %10s): $gff1\n", $key1);
printf $ol_FH   ("# GFF file 1 (key: %10s): $gff1\n", $key1);
printf $unq1_FH ("# GFF file 1 (key: %10s): $gff1\n", $key1);
printf $unq2_FH ("# GFF file 1 (key: %10s): $gff1\n", $key1);

printf $id_FH   ("# GFF file 2 (key: %10s): $gff2\n", $key2);
printf $ol_FH   ("# GFF file 2 (key: %10s): $gff2\n", $key2);
printf $unq1_FH ("# GFF file 2 (key: %10s): $gff2\n", $key2);
printf $unq2_FH ("# GFF file 2 (key: %10s): $gff2\n", $key2);

print $id_FH   ("# Key3: $key3\n");
print $ol_FH   ("# Key3: $key3\n");
print $unq1_FH ("# Key3: $key3\n");
print $unq2_FH ("# Key3: $key3\n");

print $id_FH   ("# Hits in both GFF files with identical coordinates and strand\n");
print $ol_FH   ("# Hits in both GFF files that overlap and are on same strand and overlap but which are not identical coordinates\n");
print $unq1_FH ("# Hits in GFF file 1 ($key1) but not in GFF file 2 ($key2)\n");
print $unq2_FH ("# Hits in GFF file 2 ($key2) but not in GFF file 1 ($key1)\n");

my $header_line = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                          "#sequence-name", "number-nt-overlap", 
                          "1-fract-overlap", "2-fract-overlap",
                          "1-start", "1-end", "1-strand",
                          "2-start", "2-end", "2-strand");
print $id_FH $header_line;
print $ol_FH $header_line;

printf $unq1_FH ("%s\t%s\t%s\t%s\t%s\n",
                 "#sequence-name", "number-nt-overlap", 
                 "1-start", "1-end", "1-strand");
                   
printf $unq2_FH ("%s\t%s\t%s\t%s\t%s\n",
                 "#sequence-name", "number-nt-overlap", 
                 "2-start", "2-end", "2-strand");
                   
# Do the comparison and create the output.
# We do this with a subroutine which we call twice, one with gff1 hits first and gff2
# hits second, and once again with them switched. The subroutine will do:
# For each hit in first set of hits:
#     Compare with all hits in second set of hits.
# 
# In the first call, all identical, overlapping and 1-unique hits will be output.
# In the second call, only the 2-unique hits will be output, because we don't
# want to double-output the identical and overlapping hits.
#
# In the case of multiple overlaps (1 hit in gff1 is overlapped by >1 hit in gff2)
# we count this as 1 overlap, and output information on the 'best overlap', the longest
# overlapping region, to the overlap file $key3.ol.
# 
my $nid     = 0; # number of identical hits
my $nol     = 0; # number of overlapping hits
my $nntol   = 0; # number of overlapping nucleotides
my $nunq1   = 0; # number of hits in GFF1 that have 0 overlaps in GFF2
my $nunq2   = 0; # number of hits in GFF2 that have 0 overlaps in GFF1
my $nntunq1 = 0; # number of nts in GFF1 unique hits
my $nntunq2 = 0; # number of nts in GFF2 unique hits

do_and_print_comparisons(\%hits1_HA, \%hits2_HA, \$nid, 
                         \$nol,   \$nntol, 
                         \$nunq1, \$nntunq1,
                         $id_FH, $ol_FH, $unq1_FH);
do_and_print_comparisons(\%hits2_HA, \%hits1_HA, undef, 
                         undef, undef,
                         \$nunq2, \$nntunq2, 
                         undef,  undef, $unq2_FH); 
# two undefs in second call are so we don't print identical hits and overlapping hits again,
# we already did that in the first call to print_comparisons

close($id_FH);
close($ol_FH);
close($unq1_FH);
close($unq2_FH);

# output tabular summary of comparison
printf("#%4s  %-12s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s\n", 
       "file", "desc", "#hit-tot", "#nt-tot", "avgnt-tot", "#ident", "#hit-olp", "#nt-olp", "frct-olp", "#hit-unq", "#nt-unq", "avgnt-unq");

printf("%5s  %12s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s  %9s\n", 
       "#----", "------------", "---------", "---------", "---------", "---------", "---------", "---------", "---------", "---------", "---------", "---------");
printf("%-5s  %-12s  %9d  %9d  %9.1f  %9d  %9d  %9d  %9.4f  %9d  %9d  %9.1f\n",
       "GFF1", $key1, 
       $nhits1, $nnt1,     ($nhits1 > 0)  ? $nnt1/$nhits1   : 0, 
       $nid, 
       $nol, $nntol, $nntol/($nnt1-$nntunq1),
       $nunq1, $nntunq1,   ($nntunq1 > 0) ? $nntunq1/$nunq1 : 0);
       
printf("%-5s  %-12s  %9d  %9d  %9.1f  %9d  %9d  %9d  %9.4f  %9d  %9d  %9.1f\n",
       "GFF2", $key2,
       $nhits2, $nnt2,     ($nhits2 > 0)  ? $nnt2/$nhits2   : 0, 
       $nid, 
       $nol, $nntol, $nntol/($nnt2-$nntunq2),
       $nunq2, $nntunq2,   ($nntunq2 > 0) ? $nntunq2/$nunq2 : 0);

printf("#\n");
printf("# Output file with list of identical hits:                      %-30s\n", $id_file);
printf("# Output file with list of overlapping hits:                    %-30s\n", $ol_file);
printf("# Output file with list of GFF file 1 %-12s unique hits: %-30s\n", $key1, $unq1_file);
printf("# Output file with list of GFF file 2 %-12s unique hits: %-30s\n", $key2, $unq2_file);
exit 0;

#############
# SUBROUTINES
#############

# Subroutine: parse_gff()
# Args:       $gff_file:        GFF file to parse
#             $nhits_R:         ref to scalar: number of hits
#             $nnt_R:           ref to scalar: number of total nucleotides in all hits
#             $hits_HAR:        ref to hash of arrays we will fill with hit info from gff
#             $do_reducenames:  '1' to reduce names of the form gi|\d+|\w+|\S+| to \S+, '0' not to
#
# Returns:    number of hits read from the file
# Dies:       if GFF file is in unexpected format

sub parse_gff {
  if(scalar(@_) != 5) { die "ERROR parse_gff() entered with wrong number of input args"; }

  my ($gff_file, $nhits_R, $nnt_R, $hits_HAR, $do_reducenames) = @_; 

  $$nhits_R = 0;
  open(GFF, $gff_file) || die "ERROR unable to open $gff_file for reading";
  while(my $line = <GFF>) { 
    if($line !~ m/^\#/) { 
      chomp $line;
      #AWOG01000036.1	Genbank	rRNA	531	2002	.	+	.	ID=rna24;Parent=gene1175;gbkey=rRNA;product=16S ribosomal RNA
      my @elA = split(/\t+/, $line);
      if(scalar(@elA) != 9) { die "ERROR unable to parse (1) GFF file $gff_file line $line"; }
      my ($seq, $start, $end, $strand) = ($elA[0], $elA[3], $elA[4], $elA[6]);
      if($do_reducenames) { 
        if($seq =~ /^gi\|\d+\|\S+\|(\S+)\|/) { 
          $seq = $1;
        }
      }
      $$nhits_R++;
      $$nnt_R += abs($start - $end) + 1;
      if(! exists ($hits_HAR->{$seq})) { 
        @{$hits_HAR->{$seq}} = ();
      }
      my $value = $start . ":" . $end . ":" . $strand;

      my $already_exists = 0;
      # make sure we don't already have this same hit, I've seen this happen in RNAmmer, I think it's a bug:
      # the one case I've seen:
      # gi|219672119|gb|ABJV02000001.1| searching for bacterial ssu
      # this is the sequence genome file: /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Borrelia_garinii_PBr/444578-DENOVO-20150207-1527.1456614/output/bacterial_annot/ABJV02.annotation.nucleotide.fa
      for(my $z = 0; $z < scalar(@{$hits_HAR->{$seq}}); $z++) { 
        if($hits_HAR->{$seq}[$z] eq $value) { 
          $already_exists = 1;
        }
      }
      if(! $already_exists) { 
        push(@{$hits_HAR->{$seq}}, $value);
      }
    }
  }
  close(GFF);
  
  return;
}

# Subroutine: do_and_print_comparisions()
# Args:       $hits1_HAR:  ref to hash of arrays with hit info from a gff file
#             $hits2_HAR:  ref to hash of arrays with hit info from a gff file
#             $nid_R:      set here (if !undef); ref to scalar:
#                          number of identical hits between hits1_HAR and hits2_HAR
#             $nol_R:      set here (if !undef); ref to scalar:
#                          number of non-identical but overlapping hits between hits1_HAR and hits2_HAR
#             $nntol_R:    set here (if !undef); ref to scalar:
#                          number of nucleotides in hits in hits1_HAR that overlap with a hit in hits2_HAR
#             $nunq_R:     set here; ref to scalar:
#                          number of hits in hits1_HAR with 0 overlapping hits in hits2_HAR
#             $nntunq_R:   set here (if !undef); ref to scalar:
#                          number of nucleotides in unique hits in hits1_HAR
#             $id_FH:      file handle for printing info on identical hits, can be undef
#                          to not print this info 
#             $ol_FH:      file handle for printing info on overlapping non-identical hits, 
#                          can be undef to not print this info (if this is second call of function)
#             $unq_FH:     file handle for printing info on unique hits in hits1_HHAR that 
#                          do not overlap with any hits in hits2_HAR
# Returns:    void
# Dies:       if we find an inconsistency in the gff files

sub do_and_print_comparisons {
  if(scalar(@_) != 10) { die "ERROR do_and_print_comparison() entered with wrong number of input args"; }

  my ($hits1_HAR, $hits2_HAR, $nid_R, $nol_R, $nntol_R, $nunq_R, $nntunq_R, $id_FH, $ol_FH, $unq_FH) = @_;

  my ($start1, $end1, $strand1, $score1, $evalue1); # info for a hit from hits1_HHAR
  my ($start2, $end2, $strand2, $score2, $evalue2); # info for a hit from hits2_HHAR
  my ($nhits1, $nhits2); # number of hits for a specific model to a specific sequence
  my ($i, $j);           # counters
  my $nres_overlap;      # number of residues (nucleotides) of overlap
  my $max_nres_overlap;  # number of residues (nucleotides) of overlap for max overlapping hit
  my $found_id = 0;      # if '1': we've already found an identical hit to the current one
  my $found_ol = 0;      # if '1': we've already found a non-identical overlapping hit to the current one
  my $nid_tot = 0;       # number of hits that are identical
  my $nol_tot = 0;       # number of hits that overlap on same strand but are not identical
  my $nunq_tot = 0;      # number of hits that are unique to $hits1_HHAR (don't overlap on 
                         # same strand with any hits in $hits2_HHAR)
  my $ol_toprint = "";   # string to print to overlap file

  foreach my $seq (keys %{$hits1_HAR}) { 
    $nhits1 = scalar(@{$hits1_HAR->{$seq}});
    if(exists $hits2_HAR->{$seq}) { 
      $nhits2 = scalar(@{$hits2_HAR->{$seq}});
    }
    else { 
      $nhits2 = 0;
    }
    for($i = 0; $i < $nhits1; $i++) { 
      $found_id = 0; 
      $found_ol = 0; 
      $ol_toprint = "";
      $nres_overlap = 0;
      $max_nres_overlap = 0;
      ($start1, $end1, $strand1, $score1, $evalue1) = split(":", $hits1_HAR->{$seq}[$i]);
      if($start1 > $end1) { die "ERROR start1 > end1 $start1 > $end1\n"; }
      for($j = 0; $j < $nhits2; $j++) { 
        ($start2, $end2, $strand2, $score2, $evalue2) = split(":", $hits2_HAR->{$seq}[$j]);
        if($start2 > $end2) { die "ERROR start2 > end2 $start2 > $end2\n"; }
        if($strand1 eq $strand2) { 
          if($start1 == $start2 && $end1 == $end2) { # identical
            $nres_overlap = $end1 - $start1 + 1;
            $nid_tot++;
            if($found_id) { die "ERROR found two identical hits to $hits1_HAR->{$seq}[$i]"; }
            if(defined $id_FH) { 
              printf $id_FH ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                             $seq, $nres_overlap . "-FULL", 
                             $start1, $end1, $strand1,
                             $start2, $end2, $strand2);
            }
            if(defined $nid_R) {
              $$nid_R++;
            }
            $found_id = 1;
          }
          else { # not identical
            $nres_overlap = get_nres_overlap($start1, $end1, $start2, $end2);
            if($nres_overlap > 0) { # overlap, but not identical
              if($found_id) { die "ERROR found an overlapping hit and an identical hit to $hits1_HAR->{$seq}[$i]"; }
              $found_ol = 1;
              # keep track of size of overlap
              if($nres_overlap > $max_nres_overlap) { 
                # we found a 'better' (longer) overlap, rewrite $ol_toprint
                $ol_toprint = sprintf("%s\t%s\t%6.4f\t%6.4f\t%s\t%s\t%s\t%s\t%s\t%s\n",
                                      $seq, $nres_overlap, 
                                      $nres_overlap / ($end1-$start1+1),
                                      $nres_overlap / ($end2-$start2+1),
                                      $start1, $end1, $strand1,
                                      $start2, $end2, $strand2);
                $max_nres_overlap = $nres_overlap;
              }
            }
          }
        } # end of 'if($strand1 eq $strand2)'
      } # end of 'for($j = 0; $j < $nhits2; $j++)'

      if((! $found_id) && (! $found_ol)) { # hit is unique, there are no overlaps
        if(defined $unq_FH) { 
          printf $unq_FH  ("%s\t%s\t%s\t%s\t%s\n",
                           $seq, 0, $start1, $end1, $strand1);
        }
        if(defined $nunq_R) { 
          $$nunq_R++;
        }
        if(defined $nntunq_R) { 
          $$nntunq_R += abs($end1-$start1) + 1;
        }
      }
      elsif($found_ol) { # found an overlap (and not an identity)
        if($found_id) { die "ERROR found an overlapping hit and an identical hit (case 2) to $hits1_HAR->{$seq}[$i]"; } 
        $nol_tot++;
        if(defined $ol_FH) {
          print $ol_FH $ol_toprint;
        }
        if(defined $nol_R) { 
          $$nol_R++;
        }
        if(defined $nntol_R) { 
          $$nntol_R += $max_nres_overlap;
        }
      }
    } # end of 'for($i = 0; $i < $nhits; $i++)'
  } # end of 'foreach my $seq (keys %{$hits1_HHAR->{$accn_name}})'
  return;
}

# Subroutine: get_nres_overlap()
# Args:       $start1: start position of hit 1 (must be <= $end1)
#             $end1:   end   position of hit 1 (must be >= $end1)
#             $start2: start position of hit 2 (must be <= $end2)
#             $end2:   end   position of hit 2 (must be >= $end2)
#
# Returns:    Number of residues of overlap between hit1 and hit2,
#             0 if none
# Dies:       if $end1 < $start1 or $end2 < $start2.

sub get_nres_overlap {
  if(scalar(@_) != 4) { die "ERROR get_nres_overlap() entered with wrong number of input args"; }

  my ($start1, $end1, $start2, $end2) = @_; 

  if($start1 > $end1) { die "ERROR start1 > end1 ($start1 > $end1) in get_nres_overlap()"; }
  if($start2 > $end2) { die "ERROR start2 > end2 ($start2 > $end2) in get_nres_overlap()"; }

  # Given: $start1 <= $end1 and $start2 <= $end2.
  
  # Swap if nec so that $start1 <= $start2.
  if($start1 > $start2) { 
    my $tmp;
    $tmp   = $start1; $start1 = $start2; $start2 = $tmp;
    $tmp   =   $end1;   $end1 =   $end2;   $end2 = $tmp;
  }
  
  # 3 possible cases:
  # Case 1. $start1 <=   $end1 <  $start2 <=   $end2  Overlap is 0
  # Case 2. $start1 <= $start2 <=   $end1 <    $end2  
  # Case 3. $start1 <= $start2 <=   $end2 <=   $end1
  if($end1 < $start2) { return 0; }                      # case 1
  if($end1 <   $end2) { return ($end1 - $start2 + 1); }  # case 2
  if($end2 <=  $end1) { return ($end2 - $start2 + 1); }  # case 3
  die "Unforeseen case in get_nres_overlap $start1..$end1 and $start2..$end2";

  return; # NOT REACHED
}
