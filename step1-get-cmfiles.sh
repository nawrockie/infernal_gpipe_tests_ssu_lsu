# EPN, Mon Mar 30 13:31:51 2015
# 
# step1-get-cmfiles.sh
#
# Obtaining Rfam 12.0 CM files for SSU and LSU rRNA 
# for testing for possible inclusion in the GPIPE 
# NCBI prokaryotic genome annotation pipeline.
#
# CM files are copied/created in the current working directory
# and used by the remainder of the scripts in this directory
# to carry out the tests.
#
#############################
# 1. Download the file Rfam.cm.gz from Rfam 12.0 and gunzip it:
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/12.0/Rfam.cm.gz
gunzip Rfam.cm.gz
#
# 2. Use cmfetch to fetch the SSU and LSU models:
#
#  make single model files for SSU and LSU archaea and bacteria models
/usr/local/infernal/1.1.1/bin/cmfetch Rfam.cm SSU_rRNA_archaea  > ssu-arc.cm 
/usr/local/infernal/1.1.1/bin/cmfetch Rfam.cm SSU_rRNA_bacteria > ssu-bac.cm 
/usr/local/infernal/1.1.1/bin/cmfetch Rfam.cm LSU_rRNA_archaea  > lsu-arc.cm 
/usr/local/infernal/1.1.1/bin/cmfetch Rfam.cm LSU_rRNA_bacteria > lsu-bac.cm 

# If we also wanted one model files with all SSU and LSU models:
#/usr/local/infernal/1.1.1/bin/cmstat Rfam.cm | grep SSU | awk '{ print $2 }' > ssu-and-lsu.list
#/usr/local/infernal/1.1.1/bin/cmstat Rfam.cm | grep LSU | awk '{ print $2 }' >> ssu-and-lsu.list
#/usr/local/infernal/1.1.1/bin/cmfetch -f Rfam.cm ssu-and-lsu.list > ssu-and-lsu-all.cm 
#
