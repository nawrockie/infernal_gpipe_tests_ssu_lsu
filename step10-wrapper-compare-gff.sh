# EPN, Tue Jul  7 09:47:48 2015
# 
# step9-wrapper-compare-gff.sh
#
#############################
# 
# validate NCBI vs Infernal (and vice versa) reciprocal comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step10-helper-compare-reciprocal-compare-gff-output.pl ncbi-r-v-inf-i-$fam-$dom.compare-gff inf-i-v-ncbi-r-$fam-$dom.compare-gff > ncbi-r-v-inf-i-$fam-$dom.reciprocal-validation
        perl step10-helper-compare-reciprocal-compare-gff-output.pl ncbi-b-v-inf-i-$fam-$dom.compare-gff inf-i-v-ncbi-b-$fam-$dom.compare-gff > ncbi-b-v-inf-i-$fam-$dom.reciprocal-validation
    done
done
#

# validate NCBI vs RNAmmer (and vice versa) reciprocal comparisons:
# NCBI vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step10-helper-compare-reciprocal-compare-gff-output.pl ncbi-r-v-inf-i-$fam-$dom.compare-gff rmr-i-v-ncbi-r-$fam-$dom.compare-gff > ncbi-r-v-rmr-i-$fam-$dom.reciprocal-validation
        perl step10-helper-compare-reciprocal-compare-gff-output.pl ncbi-b-v-inf-i-$fam-$dom.compare-gff rmr-i-v-ncbi-b-$fam-$dom.compare-gff > ncbi-b-v-rmr-i-$fam-$dom.reciprocal-validation
    done
done
# 

# Infernal vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step10-helper-compare-reciprocal-compare-gff-output.pl inf-i-v-rmr-i-$fam-$dom.compare-gff rmr-i-v-inf-i-$fam-$dom.compare.gff > inf-i-v-rmr-i-$fam-$dom.reciprocal-validation
    done
done
