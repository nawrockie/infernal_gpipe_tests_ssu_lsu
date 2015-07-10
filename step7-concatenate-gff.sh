# EPN, Tue Jul  7 09:14:35 2015
# 
# step8-concatenate-gff.sh
#
#############################
# 
# 1. concatenate infernal gff files:
# 
# ssu:
cat arc-infernal-out/*ssu-arc.gff > arc-infernal-out/all.ssu-arc.gff.concat
cat bac-infernal-out/*ssu-bac.gff > bac-infernal-out/all.ssu-bac.gff.concat
# lsu:
cat arc-infernal-out/*lsu-arc.gff > arc-infernal-out/all.lsu-arc.gff.concat
cat bac-infernal-out/*lsu-bac.gff > bac-infernal-out/all.lsu-bac.gff.concat
#
# and putting all together:
#
cat arc-infernal-out/all.ssu-arc.gff.concat bac-infernal-out/all.ssu-bac.gff.concat > infernal.arc-bac.ssu.gff.concat
cat arc-infernal-out/all.lsu-arc.gff.concat bac-infernal-out/all.lsu-bac.gff.concat > infernal.arc-bac.lsu.gff.concat
cat infernal.arc-bac.ssu.gff.concat infernal.arc-bac.lsu.gff.concat > infernal.arc-bac.ssu-lsu.gff.concat
#
# 2. concatenate rnammer gff files:
#
# ssu:
cat arc-rnammer-out/*ssu.gff > arc-rnammer-out/all.ssu.gff.concat
cat bac-rnammer-out/*ssu.gff > bac-rnammer-out/all.ssu.gff.concat
# 
# lsu:
cat arc-rnammer-out/*lsu.gff > arc-rnammer-out/all.lsu.gff.concat
cat bac-rnammer-out/*lsu.gff > bac-rnammer-out/all.lsu.gff.concat
#
# and putting all together:
#
cat arc-rnammer-out/all.ssu.gff.concat bac-rnammer-out/all.ssu.gff.concat > rnammer.arc-bac.ssu.gff.concat
cat arc-rnammer-out/all.lsu.gff.concat bac-rnammer-out/all.lsu.gff.concat > rnammer.arc-bac.lsu.gff.concat
cat rnammer.arc-bac.ssu.gff.concat rnammer.arc-bac.lsu.gff.concat > rnammer.arc-bac.ssu-lsu.gff.concat

# 3. concatenate ncbi gff files:
#
# ssu rRNA only: 
cat arc-ncbi-annot/*ssu.rRNA.gff > arc-ncbi-annot/all.ssu.rRNA.gff.concat
cat bac-ncbi-annot/*ssu.rRNA.gff > bac-ncbi-annot/all.ssu.rRNA.gff.concat
cat arc-ncbi-annot/all.ssu.rRNA.gff.concat bac-ncbi-annot/all.ssu.rRNA.gff.concat > ncbi-rRNA.arc-bac.ssu.gff.concat
# ssu misc only: 
cat arc-ncbi-annot/*ssu.misc.gff > arc-ncbi-annot/all.ssu.misc.gff.concat
cat bac-ncbi-annot/*ssu.misc.gff > bac-ncbi-annot/all.ssu.misc.gff.concat
cat arc-ncbi-annot/all.ssu.misc.gff.concat bac-ncbi-annot/all.ssu.misc.gff.concat > ncbi-misc.arc-bac.ssu.gff.concat
# ssu both (rRNA + misc):
cat arc-ncbi-annot/*ssu.rRNA.gff arc-ncbi-annot/*ssu.misc.gff > arc-ncbi-annot/all.ssu.both.gff.concat
cat bac-ncbi-annot/*ssu.rRNA.gff bac-ncbi-annot/*ssu.misc.gff > bac-ncbi-annot/all.ssu.both.gff.concat
cat arc-ncbi-annot/all.ssu.both.gff.concat bac-ncbi-annot/all.ssu.both.gff.concat > ncbi-both.arc-bac.ssu.gff.concat
#
# 
# lsu rRNA only: 
cat arc-ncbi-annot/*lsu.rRNA.gff > arc-ncbi-annot/all.lsu.rRNA.gff.concat
cat bac-ncbi-annot/*lsu.rRNA.gff > bac-ncbi-annot/all.lsu.rRNA.gff.concat
cat arc-ncbi-annot/all.lsu.rRNA.gff.concat bac-ncbi-annot/all.lsu.rRNA.gff.concat > ncbi-rRNA.arc-bac.lsu.gff.concat
# lsu misc only: 
cat arc-ncbi-annot/*lsu.misc.gff > arc-ncbi-annot/all.lsu.misc.gff.concat
cat bac-ncbi-annot/*lsu.misc.gff > bac-ncbi-annot/all.lsu.misc.gff.concat
cat arc-ncbi-annot/all.lsu.misc.gff.concat bac-ncbi-annot/all.lsu.misc.gff.concat > ncbi-misc.arc-bac.lsu.gff.concat
# lsu both (rRNA + misc):
cat arc-ncbi-annot/*lsu.rRNA.gff arc-ncbi-annot/*lsu.misc.gff > arc-ncbi-annot/all.lsu.both.gff.concat
cat bac-ncbi-annot/*lsu.rRNA.gff bac-ncbi-annot/*lsu.misc.gff > bac-ncbi-annot/all.lsu.both.gff.concat
cat arc-ncbi-annot/all.lsu.both.gff.concat bac-ncbi-annot/all.lsu.both.gff.concat > ncbi-both.arc-bac.lsu.gff.concat

# combining ssu and lsu:
cat ncbi-rRNA.arc-bac.ssu.gff.concat ncbi-rRNA.arc-bac.lsu.gff.concat > ncbi-rRNA.arc-bac.ssu-lsu.gff.concat
cat ncbi-misc.arc-bac.ssu.gff.concat ncbi-misc.arc-bac.lsu.gff.concat > ncbi-misc.arc-bac.ssu-lsu.gff.concat
cat ncbi-both.arc-bac.ssu.gff.concat ncbi-both.arc-bac.lsu.gff.concat > ncbi-both.arc-bac.ssu-lsu.gff.concat
