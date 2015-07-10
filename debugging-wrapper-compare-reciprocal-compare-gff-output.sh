# EPN, Tue Jul  7 09:47:48 2015
# 
# step9-wrapper-compare-gff.sh
#
#############################
# 
# validate NCBI vs Infernal (and vice versa) reciprocal comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-v-infernal-$dom-$fam.compare-gff infernal-v-ncbi-rRNA-$dom-$fam.compare-gff > ncbi-rRNA-v-infernal-$dom-$fam.reciprocal-validation
        perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-misc-v-infernal-$dom-$fam.compare-gff infernal-v-ncbi-rRNA-misc-$dom-$fam.compare-gff > ncbi-rRNA-misc-v-infernal-$dom-$fam.reciprocal-validation
    done
done
perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-v-infernal-all.compare-gff      infernal-v-ncbi-rRNA-all.compare-gff      > ncbi-rRNA-v-infernal-all.reciprocal-validation
perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-misc-v-infernal-all.compare-gff infernal-v-ncbi-rRNA-misc-all.compare-gff > ncbi-rRNA-misc-v-infernal-all.reciprocal-validation
#

# validate NCBI vs RNAmmer (and vice versa) reciprocal comparisons:
# NCBI vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-v-rnammer-$dom-$fam.compare-gff rnammer-v-ncbi-rRNA-$dom-$fam.compare-gff > ncbi-rRNA-v-rnammer-$dom-$fam.reciprocal-validation
        perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-misc-v-rnammer-$dom-$fam.compare-gff rnammer-v-ncbi-rRNA-misc-$dom-$fam.compare-gff > ncbi-rRNA-misc-v-rnammer-$dom-$fam.reciprocal-validation
    done
done
perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-v-rnammer-all.compare-gff      rnammer-v-ncbi-rRNA-all.compare-gff      > ncbi-rRNA-v-rnammer-all.reciprocal-validation
perl debugging-helper-compare-reciprocal-compare-gff-output.pl ncbi-rRNA-misc-v-rnammer-all.compare-gff rnammer-v-ncbi-rRNA-misc-all.compare-gff > ncbi-rRNA-misc-v-rnammer-all.reciprocal-validation
# 

# Infernal vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl debugging-helper-compare-reciprocal-compare-gff-output.pl infernal-v-rnammer-$dom-$fam.compare-gff rnammer-v-infernal-$dom-$fam.compare-gff > infernal-v-rnammmer-$dom-$fam.reciprocal-validation
    done
done
perl debugging-helper-compare-reciprocal-compare-gff-output.pl infernal-v-rnammer-all.compare-gff      rnammer-v-infernal-all.compare-gff      > infernal-v-rnammer-all.reciprocal-validation
