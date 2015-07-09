use strict;
use warnings;

my $usage = "grep -v ^\# <cmsearch --tblout file> | sort -k16,16g -k15,15rn | perl remove-infernal-overlaps.pl";

my $prv_evalue = undef;
my %hits_HHA = ();
while(my $line = <>) { 
  chomp $line;
  my @elA = split(/\s+/, $line);
#gi|253972022|gb|CP000819.1| -         tRNA                 RF00005    cm        1       71  4189361  4189433      +    no    1 0.64   0.0   59.8   2.1e-12 !   Escherichia coli B str. REL606, complete genome
  my ($target, $start, $stop, $strand, $evalue) = ($elA[0], $elA[7], $elA[8], $elA[9], $elA[15]);
  #printf("target: $target\nstart: $start\nstop: $stop\nstrand: $strand\nevalue: $evalue\n");
  if($strand eq "-") { 
    # swap 
    my $tmp = $start;
    $start = $stop;
    $stop = $tmp;
  }
  if(defined $prv_evalue && $evalue < $prv_evalue) { die "ERROR not sorted by E-value ($evalue < $prv_evalue)"; }
  $prv_evalue = $evalue;
  my $found_overlap = 0;
  if(exists $hits_HHA{$target}) { 
    if(exists $hits_HHA{$target}{$strand}) { 
      foreach my $start_stop (@{$hits_HHA{$target}{$strand}}) { 
        my ($start2, $stop2) = split(":", $start_stop);
        my $overlap_nres = get_nres_overlap($start, $stop, $start2, $stop2);
        if($overlap_nres > 0) { 
          $found_overlap = 1; 
          #printf("FOUND OVERLAP BETWEEN $start..$stop and $start2..$stop2 on strand $strand\n"); 
        }
      }
    }
  }
  if($found_overlap) { 
    ;  # do nothing; 
  }
  else { 
    print $line . "\n";
    if(! exists $hits_HHA{$target}) { 
      %{$hits_HHA{$target}} = ();
    }
    if(! exists $hits_HHA{$target}{$strand}) { 
      @{$hits_HHA{$target}{$strand}} = ();
    }
    push(@{$hits_HHA{$target}{$strand}}, $start . ":" . $stop); 
    #printf("pushed $start:$stop to hits_HHA $target $strand\n");
  }
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

  #printf("in get_nres_overlap $start1..$end1 $start2..$end2\n");

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
