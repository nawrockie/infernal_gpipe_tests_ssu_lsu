perl step10-summarize-all-comparisons.pl ncbi-rRNA infernal      > ncbi-rRNA-v-infernal.summary.txt
perl step10-summarize-all-comparisons.pl ncbi-rRNA rnammer       > ncbi-rRNA-v-rnammer.summary.txt
perl step10-summarize-all-comparisons.pl infernal rnammer        > infernal-v-rnammer.summary.txt
perl step10-summarize-all-comparisons.pl ncbi-rRNA-misc infernal > ncbi-rRNA-misc-v-infernal.summary.txt
perl step10-summarize-all-comparisons.pl ncbi-rRNA-misc rnammer  > ncbi-rRNA-misc-v-rnammer.summary.txt

head -n5 ncbi-rRNA-v-infernal.summary.txt                >  all-comparisons.summary.txt
head -n5 ncbi-rRNA-v-rnammer.summary.txt | tail -n3      >> all-comparisons.summary.txt
head -n5 infernal-v-rnammer.summary.txt  | tail -n3      >> all-comparisons.summary.txt
echo "#" >> all-comparisons.summary.txt
echo "#" >> all-comparisons.summary.txt
head -n5 ncbi-rRNA-misc-v-infernal.summary.txt           >> all-comparisons.summary.txt
head -n5 ncbi-rRNA-misc-v-rnammer.summary.txt | tail -n3 >> all-comparisons.summary.txt
tail -n19 ncbi-rRNA-misc-v-rnammer.summary.txt >> all-comparisons.summary.txt

cat all-comparisons.summary.txt

