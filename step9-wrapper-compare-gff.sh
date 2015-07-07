# EPN, Tue Jul  7 09:47:48 2015
# 
# step9-wrapper-compare-gff.sh
#
#############################
# 
# NCBI vs Infernal comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA $dom-infernal-out/all.$fam-$dom.gff.concat inf-$fam-$dom ncbi-r-v-inf-i-$fam-$dom > ncbi-r-v-inf-i-$fam-$dom.compare-gff
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-both $dom-infernal-out/all.$fam-$dom.gff.concat inf-$fam-$dom ncbi-b-v-inf-i-$fam-$dom > ncbi-b-v-inf-i-$fam-$dom.compare-gff
    done
done
#
# 
# NCBI vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA $dom-rnammer-out/all.$fam.gff.concat rmr-$fam-$dom ncbi-r-v-rmr-i-$fam-$dom > ncbi-r-v-rmr-i-$fam-$dom.compare-gff
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-both $dom-rnammer-out/all.$fam.gff.concat rmr-$fam-$dom ncbi-b-v-rmr-i-$fam-$dom > ncbi-b-v-rmr-i-$fam-$dom.compare-gff
    done
done
# 
# Infernal vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat inf-$fam-$dom $dom-rnammer-out/all.$fam.gff.concat rmr-$fam-$dom inf-i-v-rmr-i-$fam-$dom > inf-i-v-rmr-i-$fam-$dom.compare-gff
    done
done
