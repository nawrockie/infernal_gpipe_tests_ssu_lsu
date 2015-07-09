#!/usr/bin/env perl
# EPN, Thu Jul  9 14:57:10 2015
# compare-reciprocal-compare-gff-output.pl
# 
# Given two gff-output files that were created by 
# reciprocal calls of: 
# step9-helper-compare-gff.pl <gff file1> <file1 key> <gff file2> <file2 key> <key3>
# (e.g: 'out1' and 'out2' created by: 
#  'step9-helper-compare-gff.pl file1 key1 file2 key2 key3 > out1'
#  'step9-helper-compare-gff.pl file2 key2 file1 key1 key4 > out2')
#
# Make sure all values that should be identical are.
my $usage = "perl compare-reciprocal-compare-gff-output.pl <step9-helper-compare-gff.pl output 1> <step9-helper-compare-gff.pl output 2>\n";
$usage   .= "\t<output1> and <output2> should be 'reciprocal', created from the same GFF files, with order inverted\n";
$usage   .= "\t\te.g.: 'out1' and 'out2' created by:\n";
$usage   .= "\t\t\'step9-helper-compare-gff.pl file1 key1 file2 key2 key3 > out1\'\n";
$usage   .= "\t\t\'step9-helper-compare-gff.pl file2 key2 file1 key1 key4 > out2\'\n";

if(scalar(@ARGV) != 2) { die $usage; }

my ($in1, $in2) = (@ARGV);

my $line11 = undef;
my $line12 = undef;
my $line21 = undef;
my $line22 = undef;

open(IN, $in1) || die "ERROR unable to open $in1 for reading"; 
while(my $line = <IN>) { 
# there are only 2 relevant lines, the 3rd and 4th lines below:
##file  desc           #hit-tot    #nt-tot  avgnt-tot     #ident   #hit-olp    #nt-olp   frct-olp   #hit-unq    #nt-unq  avgnt-unq
##----  ------------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------
#GFF1   inf-ssu-bac         146     165389     1132.8          1         96     142940     0.9867         49      20529      419.0
#GFF2   rmr-ssu-bac          97     145915     1504.3          1         96     142940     0.9796          0          0        0.0
##
  if($line !~ m/^\#/) { 
    $line11 = $line;
    $line12 = <IN>;
  }
}
close(IN);

open(IN, $in2) || die "ERROR unable to open $in2 for reading"; 
while(my $line = <IN>) { 
  if($line !~ m/^\#/) { 
    $line21 = $line;
    $line22 = <IN>;
  }
}
close(IN);

if(! defined $line11) { die "ERROR didn't read first  line from $in1"; }
if(! defined $line12) { die "ERROR didn't read second line from $in1"; }
if(! defined $line21) { die "ERROR didn't read first  line from $in2"; }
if(! defined $line22) { die "ERROR didn't read second line from $in2"; }

my $orig_line11 = $line11;
my $orig_line12 = $line12;
my $orig_line21 = $line21;
my $orig_line22 = $line22;

# examples:
#GFF1   inf-ssu-bac         146     165389     1132.8          1         96     142940     0.9867         49      20529      419.0
#GFF2   rmr-ssu-bac          97     145915     1504.3          1         96     142940     0.9796          0          0        0.0
#GFF1   rmr-ssu-bac          97     145915     1504.3          1         96     142940     0.9796          0          0        0.0
#GFF2   inf-ssu-bac         146     165389     1132.8          1         96     142940     0.9867         49      20529      419.0

# remove the first token:
$line11 =~ s/GFF1\s+//;
$line12 =~ s/GFF2\s+//;
$line21 =~ s/GFF1\s+//;
$line22 =~ s/GFF2\s+//;

if($line11 ne $line22) { die "ERROR first  line of $in1 and second line of $in2 do not match:\n$orig_line11$orig_line22"; }
if($line12 ne $line21) { die "ERROR second line of $in1 and first  line of $in1 do not match:\n$orig_line12$orig_line21"; }

print ("step9-helper-compare-gff.pl files $in1 and $in2 validated as reciprocal, all values that should match do match\n");

#print $orig_line11;
#print "matches\n";
#print $orig_line22;

#print "\n";

#print $orig_line12;
#print "matches\n";
#print $orig_line21;

exit 0;
