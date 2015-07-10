EPN, Fri Jul 10 2015

Goal: Carry out tests to compare 16S SSU ribosomal RNA and 23S LSU
      ribosomal RNA predictions by Infernal, RNAmmer and the current
      NCBI GPIPE BLAST-based annotation procedure.

Related JIRA ticket: GP-12668
GitHub URL*: https://github.com/nawrockie/infernal_gpipe_tests_ssu_lsu.git
* GitHub repo includes: scripts and files necessary to reproduce (must
  be on NCBI computing resources).

***To reproduce the tests discussed here, see 00TOREPRODUCE.txt in this
directory. 

Sections of this file:
- What I did to carry out the tests
- Summary table and discussion of results
- Explanation of the 4 prediction methods
- List of files created for each pairwise comparison of methods
- Idea for extended benchmark

-------------------------------------------------------------------
What I did to carry out the tests:

A. Randomly selected 50 bacterial and 25 archaeal GPIPE-annotated
   genomes from the 2851 genomes in:
   /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/

B. For each genome, I obtained 4 sets of predictions for 16S SSU rRNA
   and 23S LSU rRNA genes in the genome sequences:

   1. ncbi-rRNA      : NCBI 16S or 23S rRNA features
   2. ncbi-rRNA-misc : NCBI 16S or 23S rRNA or region features 
   3. infernal       : infernal 1.1.1 cmsearch and Rfam 12.0
   4. RNAmmer        : RNAmmer 1.2 and included models

   (See the 'Explanation of the 4 prediction methods' section below
   for more information on these methods.)

C. Compared the predictions in GFF format for all pairwise combination
   of prediction methods (except ncbi-rRNA vs ncbi-rRNA-misc) across
   both domains and families, as well as for each domain-family pair
   (e.g. bac-ssu, or arc-lsu).

   (See the 'List of files created for each pairwise comparison of
   methods' section' for more information on output files from the
   comparison.)

D. Summarized all the results into a single tabular file. This step was
   done by the 'step9-wrapper-summarize-all-comparisons.sh' script
   which calls 'step9-helper-summarize-all-comparisons.pl'.

See 00TOREPRODUCE for instructions on how to reproduce.

--------------------------------------
Summary table and discussion of results:

 This is the file 'comparison-summary.txt' created using the command 
 'sh step9-wrapper-summarize-all-comparisons.sh > comparison-summary.txt'

----------------------------------------------------------------------------------------------------------------------------------------------
#domain  family   method           #hit-tot    #nt-tot  avgnt-tot     #ident   #hit-olp    #nt-olp   frct-olp   #hit-unq    #nt-unq  avgnt-unq
#------  -------  --------------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------
arc-bac  ssu-lsu  ncbi-rRNA             327     504156     1541.8         29        293     477072     0.9469          5        307       61.4
arc-bac  ssu-lsu  infernal              363     544009     1498.6         29        293     477072     0.9501         41      41880     1021.5
#
arc-bac  ssu-lsu  ncbi-rRNA             327     504156     1541.8          2        211     448454     0.9858        114      49225      431.8
arc-bac  ssu-lsu  rnammer               219     477463     2180.2          2        211     448454     0.9746          6      17319     2886.5
#
arc-bac  ssu-lsu  infernal              363     544009     1498.6         27        192     423491     0.9000        144      73438      510.0
arc-bac  ssu-lsu  rnammer               219     477463     2180.2         27        192     423486     0.8870          0          0        0.0
#
#
#
#domain  family   method           #hit-tot    #nt-tot  avgnt-tot     #ident   #hit-olp    #nt-olp   frct-olp   #hit-unq    #nt-unq  avgnt-unq
#------  -------  --------------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------  ---------
arc-bac  ssu-lsu  ncbi-rRNA-misc        392     539874     1377.2         29        337     509235     0.9464         26       1802       69.3
arc-bac  ssu-lsu  infernal              363     544009     1498.6         29        334     506402     0.9309          0          0        0.0
#
arc-bac  ssu-lsu  ncbi-rRNA-misc        392     539874     1377.2          2        224     460661     0.9861        166      72718      438.1
arc-bac  ssu-lsu  rnammer               219     477463     2180.2          2        217     457602     0.9584          0          0        0.0
#
#
# Explanation of columns:
#
#   domain:    'arc' or 'bac' or 'arc-bac' for archaea, bacteria or both
#   family:    'ssu' or 'lsu' or 'ssu-lsu' for 16S small subunit rRNA or 23S large subunit rRNA or both
#   method:    'infernal', 'rnammer', 'ncbi-rRNA' (includes only 'rRNA' feature annotations), or
#              'ncbi-rRNA-misc' (includes 'rRNA' feature and 'region' annotations)
#   #hit-tot:  total number of hits/annotations
#   #nt-tot:   total number of nucleotides in all hits/annotations
#   avgnt-tot: average length of a hit/annotation
#   #ident:    number of identical annotations with adjacent row
#   #hit-olp:  number of non-identical but overlapping annotations (at least 1 nt) with adjacent row
#   #nt-olp:   number of nucleotides in this methods annotations that overlap with
#              adjacent row's annotations
#   frct-olp:  fraction of nucleotides in this methods annotations that overlap with
#              adjacent row's annotations
#   #hit-unq:  number of this method's 'unique' annotations, these do not overlap with any of
#              adjacent row's annotations (by >=1 nucleotides)
#   #nt-unq:   number of nucleotides in this method's unique annotations
----------------------------------------------------------------------------------------------------------------------------------------------

The table above shows the results of all the pairwise
comparisons across all predictions (both archaea and bacteria, and
both SSU and LSU families, see the individual output files for more
fine-grained single domain/family comparisons).

Here's some key observations from the table:

--
Observation 1: RNAmmer predicts many fewer hits than does Infernal or NCBI.
In the 75 genomes: 
   - NCBI annotates 327 SSU and LSU 'rRNA' features 
   - NCBI annotates 392 SSU and LSU 'rRNA' OR 'region' features that
     include a Note about being a putative 16S or 23S rRNA (see
     category 2 in 'Explanations of the 4 prediction methods for
     details).
   - Infernal predicts 363 SSU and LSU hits
   - RNAmmer predicts 219 SSU and LSU hits

I believe that the number of RNAmmer predictions is fairly low because
it relies on a first step of finding short highly conserved regions of
SSU or LSU first before looking for a full length hit. Many of the
hits missed by RNAmmer are not full length and presumably lack these
conserved regions, and are consequently are not found.

I believe this is reason alone not to use RNAmmer as you'll lose a lot
of annotations of partial SSU/LSU sequences that lack the highly
conserved sequences that RNAmmer relies on for detection.

--
Observation 2: Very few predictions are identical (same start/end
point between any two methods):

Only 29 predictions between Infernal and NCBI are identical (same
start/end position). Only 27 predictions between RNAmmer and NCBI
are identical.

--
Observation 3: Most hits do overlap nearly full-length:

The vast majority of Infernal and RNAmmer hits overlap with NCBI
annotations, as one would hope. Infernal and NCBI annotations overlap
by 95% on average (93-94% for the ncbi-rRNA-misc set that includes the
gbkey=misc_feature annotations). RNAmmer and NCBI overlap more, about
98% on average, but there are significantly fewer overlaps than
between Infernal and NCBI (211 vs 293 for ncbi-rRNA, and 224 vs 3377
for ncbi-rRNA-misc).

Observations 2 and 3 raise the question of: which annotation is
correct? I'd like to construct a more sophisticated benchmark that
relies on gold-standard annotation of SSU and LSU in several
genomes. I have an idea for how to do this, although I'm not sure how
feasible it is. See 'Idea for extended benchmark' section.

--

Observation 4: While all Infernal hits overlap with at an NCBI
annotation (ncbi-rRNA-misc vs infernal row, 0 #hit-unq), not all NCBI
annotation overlap with an Infernal hit. These tend to be short
(average length 69 nt) and I've investigated a few cases. For all the
cases I've looked at, Infernal is missing the hit because it scores
below the Rfam bit score cutoff of 50 bits. If the bit score threshold
were lowered to 30 bits all the cases I've looked at would have been
reported. Note that I've only looked at a handful of cases though, not
all 26.

The fact that all Infernal predictions overlap with an NCBI annotation
means that Infernal is not over-predicting relative to NCBI's current
annotation procedure, at least when both the feature='rRNA' and
feature='region' rRNA annotations are considered. Infernal hits could
easily be filtered to differentiate between high confidence (analog of
feature='rRNA') and low confidence (analog of feature='region') using
length or bit score.

--------------------------------------
Explanations of the 4 prediction methods:

   1. ncbi-rRNA
      NCBI annotations presumably from GPIPE that existed in 
      the genome annotation with GFF 'feature' of 'rRNA'
      that include 'product=16S ribosomal RNA' or 'product=23S
      ribosomal RNA' in the 'attribute' field.

      An example GFF line:
      ASMP01000002.1	Genbank	rRNA	125624	126993	.	+	.	ID=rna23;Parent=gene474;gbkey=rRNA;product=16S ribosomal RNA   

      These annotations are extracted from the complete GFF 
      files for each genome using the step6-get-ncbi-annotation.pl
      script.

   2. ncbi-rRNA-misc:
      Same as 1 but with additional NCBI annotations. Specifically
      any annotation with GFF 'feature' of 'region' that includes
      'gbkey=misc_feature' in the 'attribute' field. And also includes
      'Note=<s>' in the 'attribute' field where '<s> is one of the
      following:
        'Note=possible 16S ribosomal RNA but 16S or 23S rRNA prediction is too short'
        'Note=possible 23S ribosomal RNA but 16S or 23S rRNA prediction is too short'
        'Note=16S ribosomal RNA 16S or 23S rRNA prediction is too short'
        'Note=23S ribosomal RNA 16S or 23S rRNA prediction is too short'
        'Note=16S ribosomal RNA does not have good blast hits on one or both of the ends'
        'Note=23S ribosomal RNA does not have good blast hits on one or both of the ends'
        'Note=possible 23S ribosomal RNA but does not have good blast hits on one or both of the ends'

      An example GFF line:
      CP007242.1	Genbank	region	672952	673110	.	+	.	ID=id23;Note=16S ribosomal RNA 16S or 23S rRNA prediction is too short;gbkey=misc_feature        

      These annotations are extracted from the complete GFF 
      files for each genome using the step6-get-ncbi-annotation.pl
      script.

   3. infernal:
      Predictions using infernal 1.1.1's cmsearch program and Rfam
      12.0 models. The following 2 models were used to search against
      the 50 bacterial genomes:
      RF00177 (SSU_rRNA_bacteria)
      RF02541 (SSU_rRNA_bacteria)

      And the following 2 models were used to search against the 25
      archaeal genomes:
      RF01959 (SSU_rRNA_archaea)
      RF02541 (SSU_rRNA_archaea)

      The following options were used for cmsearch:
      --cut_ga --rfam --cpu 0 --nohmmonly --tblout <tbloutfile>

      The step3-make-infernal-qsub-scripts.pl script was used to
      create a file that submits cmsearch jobs to the NCBI cluster
      using qsub.

      The step5-wrapper-convert-infernal-to-gff.pl and
      step5-helper-convert-infernal-to-gff.pl scripts convert the
      cmsearch --tblout output to GFF format for comparison with the
      other prediction methods.

   4. RNAmmer: 
      Predictions using RNAmmer version 1.2.
      The following two searches were performed against the bacterial
      genomes: 
      rnammer -S bac -m ssu -gff <gffoutfile>
      rnammer -S bac -m lsu -gff <gffoutfile>

      The following two searches were performed against the archaeal
      genomes: 
      rnammer -S arc -m ssu -gff <gffoutfile>
      rnammer -S arc -m lsu -gff <gffoutfile>

      The step4-make-rnammer-qsub-scripts.pl qs used to 
      create a file that submits RNAmmer jobs to the NCBI cluster
      using qsub.


--------------------------------
List of files created for each pairwise comparison of methods:

   For each pairwise comparison of methods between <method1> and
   <method2>, all hits/annotations from both domains and families were
   compared to create files with the prefix:

   <method1>-v-<method2>-all
      (e.g. 'ncbi-rRNA-v-infernal-all')

   Also, annotations for each domain ('arc' or 'bac') and family
   ('ssu' or 'lsu') were independently compared to create files
   with the prefix: 

   <method1>-v-<method2>-<domain>-<family>
      (e.g. 'ncbi-rRNA-v-infernal-bac-ssu')

   The following files were created for each comparison. These 
   are in the comparison-output-files/ dir.

   '.id' file:
     list of identical annotations (same sequence and same boundaries)

   '.ol1' file:
     list of non-identical but overlapping annotations (overlap >= 1 
     nt), each <method1> hit can overlap with at most 1 <method2> hit.

   'ol2' file:
     list of non-identical but overlapping annotations (overlap >= 1 
     nt), each <method2> hit can overlap with at most 1 <method1> hit.

   'unq1' file:
     unique hits predicted by <method1> with 0 overlapping hits 
     predicted by <method2>

   'unq2' file:
     unique hits predicted by <method2> with 0 overlapping hits 
     predicted by <method1>

   '.compare-gff' file:
     summary of number of identical hits, overlapping hits and unique
     hits for the comparison of the two methods 

   These files were created using the scripts
   'step8-wrapper-compare-gff.sh', which calls
   'step8-helper-compare-gff.pl'. 

------------------------------------
Idea for extended benchmark:

The three prediction methods differ significantly in the assignment of
5' and 3' boundaries for SSU and LSU. It's difficult to know which is
correct in each individual case and more commonly correct overall. I
want to try to collect a 'gold standard' dataset with trusted sequence
boundaries for 16S and 23S in archaeal and bacterial genomes and see
which prediction method most closely agrees with this 'gold standard'

From my Ph.D. thesis work, I found that the Comparative RNA Website
(CRW) (http://www.rna.icmb.utexas.edu/) has very reliable data on 16S
and 23S that has undergone manual curation. In particular they have
individual secondary structure predictions for some 16S and 23S genes
which were manually curated. The structure prediction process involved
definition of the 5' and 3' boundaries. I propose to collect those
sequences for which individual structures were predicted, look for
identical or nearly identical sequences in sequence datasets (the
16S/23S embedded in a larger sequence), and create a dataset based on
these sequences and their implied start and end points. I can then see
how well each prediction method does on these sequences.

If all goes well and a reasonably sized dataset can be constructed, I
also propose to work towards writing up this benchmark/comparison as a
publication to be submitted for peer review. 

-----------------------------------------
