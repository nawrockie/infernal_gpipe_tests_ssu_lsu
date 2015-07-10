# EPN, Tue Jul  7 09:47:48 2015
# 
# step8-wrapper-compare-gff.sh
#
#############################
# make the output dir
mkdir comparison-output-files
# 
# NCBI vs Infernal comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam comparison-output-files >comparison-output-files/ncbi-rRNA-v-infernal-$dom-$fam.compare-gff
        perl step8-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam comparison-output-files >comparison-output-files/ncbi-rRNA-misc-v-infernal-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl ncbi-rRNA.arc-bac.ssu-lsu.gff.concat ncbi-rRNA      infernal.arc-bac.ssu-lsu.gff.concat infernal arc-bac ssu-lsu comparison-output-files >comparison-output-files/ncbi-rRNA-v-infernal-all.compare-gff
perl step8-helper-compare-gff.pl ncbi-both.arc-bac.ssu-lsu.gff.concat ncbi-rRNA-misc infernal.arc-bac.ssu-lsu.gff.concat infernal arc-bac ssu-lsu comparison-output-files >comparison-output-files/ncbi-rRNA-misc-v-infernal-all.compare-gff
#
# Infernal vs NCBI comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom $fam comparison-output-files >comparison-output-files/infernal-v-ncbi-rRNA-$dom-$fam.compare-gff
        perl step8-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom $fam comparison-output-files >comparison-output-files/infernal-v-ncbi-rRNA-misc-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl infernal.arc-bac.ssu-lsu.gff.concat infernal ncbi-rRNA.arc-bac.ssu-lsu.gff.concat      ncbi-rRNA      arc-bac ssu-lsu comparison-output-files >comparison-output-files/infernal-v-ncbi-rRNA-all.compare-gff
perl step8-helper-compare-gff.pl infernal.arc-bac.ssu-lsu.gff.concat infernal ncbi-both.arc-bac.ssu-lsu.gff.concat ncbi-rRNA-misc arc-bac ssu-lsu comparison-output-files >comparison-output-files/infernal-v-ncbi-rRNA-misc-all.compare-gff
#
# 
# NCBI vs RNAmmer comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam comparison-output-files >comparison-output-files/ncbi-rRNA-v-rnammer-$dom-$fam.compare-gff
        perl step8-helper-compare-gff.pl $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam comparison-output-files >comparison-output-files/ncbi-rRNA-misc-v-rnammer-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl ncbi-rRNA.arc-bac.ssu-lsu.gff.concat ncbi-rRNA      rnammer.arc-bac.ssu-lsu.gff.concat rnammer arc-bac ssu-lsu comparison-output-files >comparison-output-files/ncbi-rRNA-v-rnammer-all.compare-gff
perl step8-helper-compare-gff.pl ncbi-both.arc-bac.ssu-lsu.gff.concat ncbi-rRNA-misc rnammer.arc-bac.ssu-lsu.gff.concat rnammer arc-bac ssu-lsu comparison-output-files >comparison-output-files/ncbi-rRNA-misc-v-rnammer-all.compare-gff
# 
# RNAmmer vs NCBI comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-ncbi-annot/all.$fam.rRNA.gff.concat ncbi-rRNA      $dom $fam comparison-output-files >comparison-output-files/rnammer-v-ncbi-rRNA-$dom-$fam.compare-gff
        perl step8-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-ncbi-annot/all.$fam.both.gff.concat ncbi-rRNA-misc $dom $fam comparison-output-files >comparison-output-files/rnammer-v-ncbi-rRNA-misc-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl rnammer.arc-bac.ssu-lsu.gff.concat rnammer ncbi-rRNA.arc-bac.ssu-lsu.gff.concat ncbi-rRNA      arc-bac ssu-lsu comparison-output-files >comparison-output-files/rnammer-v-ncbi-rRNA-all.compare-gff
perl step8-helper-compare-gff.pl rnammer.arc-bac.ssu-lsu.gff.concat rnammer ncbi-both.arc-bac.ssu-lsu.gff.concat ncbi-rRNA-misc arc-bac ssu-lsu comparison-output-files >comparison-output-files/rnammer-v-ncbi-rRNA-misc-all.compare-gff
# 
# Infernal vs RNAmmer comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom-rnammer-out/all.$fam.gff.concat rnammer $dom $fam comparison-output-files >comparison-output-files/infernal-v-rnammer-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl infernal.arc-bac.ssu-lsu.gff.concat infernal rnammer.arc-bac.ssu-lsu.gff.concat rnammer arc-bac ssu-lsu comparison-output-files >comparison-output-files/infernal-v-rnammer-all.compare-gff
# 
# RNAmmer vs Infernal comparisons:
# foreach of the 4 domain/family combos:
for dom in arc bac; do 
    for fam in ssu lsu; do
        perl step8-helper-compare-gff.pl $dom-rnammer-out/all.$fam.gff.concat rnammer $dom-infernal-out/all.$fam-$dom.gff.concat infernal $dom $fam comparison-output-files >comparison-output-files/rnammer-v-infernal-$dom-$fam.compare-gff
    done
done
# both domains and both families together
perl step8-helper-compare-gff.pl rnammer.arc-bac.ssu-lsu.gff.concat rnammer infernal.arc-bac.ssu-lsu.gff.concat infernal arc-bac ssu-lsu comparison-output-files >comparison-output-files/rnammer-v-infernal-all.compare-gff
