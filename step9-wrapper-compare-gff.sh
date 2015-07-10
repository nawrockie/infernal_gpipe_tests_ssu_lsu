# EPN, Tue Jul  7 09:47:48 2015
# 
# step9-wrapper-compare-gff.sh
#
#############################
# 
# NCBI vs Infernal comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam > ncbi-rRNA-v-infernal-$dom-$fam.compare-gff
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam > ncbi-rRNA-misc-v-infernal-$dom-$fam.compare-gff
    done
done
#
# Infernal vs NCBI comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom $fam > infernal-v-ncbi-rRNA-$dom-$fam.compare-gff
        perl step9-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom $fam > infernal-v-ncbi-rRNA-misc-$dom-$fam.compare-gff
    done
done
#
# 
# NCBI vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam > ncbi-rRNA-v-rnammer-$dom-$fam.compare-gff
        perl step9-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam > ncbi-rRNA-misc-v-rnammer-$dom-$fam.compare-gff
    done
done
# 
# RNAmmer vs NCBI comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom $fam > rnammer-v-ncbi-rRNA-$dom-$fam.compare-gff
        perl step9-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom $fam > rnammer-v-ncbi-rRNA-misc-$dom-$fam.compare-gff
    done
done
# 
# Infernal vs RNAmmer comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam > infernal-v-rnammer-$dom-$fam.compare-gff
    done
done

# RNAmmer vs Infernal comparisons:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step9-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam > rnammer-v-infernal-$dom-$fam.compare-gff
    done
done
