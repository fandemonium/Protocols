## BEFORE START 
## update full pathways and parameters from line 7 to line 30. some pathways can be found in macpro_some_pathways.md
## this pipeline is specifically for 16S
## mapping files should be already formatted into RDP format and excel carriage returns removed 
## change java heapspace (-Xmx) to 1/4 or less of your max machine ram.

NAME="rdp"
LOCATION="/home/ubuntu/data/data3/fan/pitfoaming"
INDEX_FILE="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_I1_001.fastq.gz"
READ_1="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_R1_001.fastq.gz"
READ_2="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_R2_001.fastq.gz"
MAP="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/rdp_mapping_file_rev.txt"
FAN_PY="/Users/metagenomics/Documents/Fan/code"
UPARSE_PY="/Users/metagenomics/python_scripts"
REF_16S="/mnt/data3/fan/RDPinfernal1.1Traindata/RDPClassifier_16S_trainsetNo15_rawtrainingdata/trainset15_092015.fa"
MODEL_16S="/home/ubuntu/data/data3/fan/RDPinfernal1.1Traindata/bacteria_model.cm"

SEQFILTER="/home/ubuntu/RDPTools/SeqFilters.jar"
PANDASEQ="/home/ubuntu/RDP_Assembler/pandaseq/pandaseq"
USEARCH="/home/ubuntu/usearch"
CMALIGN="/usr/local/bin/cmalign"
ALIGNMENTTOOLS="/home/ubuntu/RDPTools/AlignmentTools.jar"
CLUST="/home/ubuntu/RDPTools/Clustering.jar"
CLASSIFIER="/home/ubuntu/RDPTools/classifier.jar"
FASTTREE="/home/ubuntu/FastTree"

READQ="25"
DIST="0.03"
STEP="0.01"
BOOTSTRAP_VALUE="0.5"

cd $LOCATION

echo "assembling pair-ended reads ..."
mkdir 1_"$NAME"_demultiplex 1_"$NAME"_demultiplex/assembled 1_"$NAME"_demultiplex/stats
$PANDASEQ -N -o 10 -e $READQ -F -d rbfkms -l 250 -L 280 -f $READ_1 -r $READ_2 1> 1_"$NAME"_demultiplex/assembled/assembled_reads.fastq 2>  1_"$NAME"_demultiplex/stats/assembled_reads_stats.txt
echo "pairend completed."

echo "parsing index file ..."
java -jar $SEQFILTER -Q $READQ --seq-file $INDEX_FILE --tag-file $MAP --outdir 1_"$NAME"_demultiplex/parse_index
echo "moving quality trimmed index reads to directory 'trimmed_tags'"
mkdir 1_"$NAME"_demultiplex/parse_index/trimmed_tags
mv 1_"$NAME"_demultiplex/parse_index/result_dir/*/*_trimmed.fasta 1_"$NAME"_demultiplex/parse_index/trimmed_tags/
echo "done."

echo "demultiplexing assembled reads ..."
cd 1_"$NAME"_demultiplex/parse_index/trimmed_tags
mv NoTag_trimmed.fasta $LOCATION/1_"$NAME"_demultiplex/parse_index/result_dir/NoTag
python $FAN_PY/bin_reads.py $LOCATION/1_"$NAME"_demultiplex/assembled/assembled_reads.fastq
cd $LOCATION
mkdir 1_"$NAME"_demultiplex/demultiplexed_assembled_reads
mv 1_"$NAME"_demultiplex/parse_index/trimmed_tags/*_assem.fastq 1_"$NAME"_demultiplex/demultiplexed_assembled_reads
echo "done."

echo "dereplicate reads ..."
mkdir $LOCATION/2_"$NAME"_uchime $LOCATION/2_"$NAME"_uchime/derep
cd 1_"$NAME"_demultiplex/assembled
java -Xmx24g -jar $CLUST derep --unaligned -o $LOCATION/2_"$NAME"_uchime/derep/all_seqs_unique.fasta $LOCATION/2_"$NAME"_uchime/derep/all_seqs.ids $LOCATION/2_"$NAME"_uchime/derep/all_seqs.samples *.fastq
echo "done."

echo "remove extra space in RDPTools dereped reads ..."
cd $LOCATION/2_"$NAME"_uchime/derep
cat all_seqs_unique.fasta | tr -d ' ' > all_seqs_unique_nospace.fasta

echo "sorting by cluster size ..."
cd $LOCATION/2_"$NAME"_uchime
$USEARCH -sortbysize derep/all_seqs_unique_nospace.fasta -fastaout all_seqs_unique_nospace_sorted.fasta -minsize 1 > $LOCATION/log.txt
echo "done."

echo "removing chimeras using de novo ..."
mkdir $LOCATION/2_"$NAME"_uchime/chime_denovo
$USEARCH -uchime_denovo all_seqs_unique_nospace_sorted.fasta -chimeras chime_denovo/all_seqs_unique_nospace_sorted.denovo.chimeras -nonchimeras chime_denovo/all_seqs_unique_nospace_sorted.denovo.good.fasta >> $LOCATION/log.txt
echo "done."

echo "removing chimeras using references ..."
mkdir $LOCATION/2_"$NAME"_uchime/chime_ref
$USEARCH -uchime_ref chime_denovo/all_seqs_unique_nospace_sorted.denovo.good.fasta -db $REF_16S -uchimeout chime_ref/all_seqs_unique_nospace_sorted.ref.uchime -strand plus -chimeras chime_ref/all_seqs_unique_nospace_sorted.ref.chimera -nonchimeras chime_ref/all_seqs_unique_nospace_sorted.ref.good.fasta >> $LOCATION/log.txt
sed -i -e 's/;size/  ;size/g' chime_ref/all_seqs_unique_nospace_sorted.ref.good.fasta
echo "done."

echo "align finalized sequences ..."
mkdir $LOCATION/3_"$NAME"_alignment_and_cluster $LOCATION/3_"$NAME"_alignment_and_cluster/temp
cd $LOCATION/3_"$NAME"_alignment_and_cluster
$CMALIGN -o temp/temp_aln.stk -g --noprob $MODEL_16S $LOCATION/2_"$NAME"_uchime/chime_ref/all_seqs_unique_nospace_sorted.ref.good.fasta
java -Xmx24g -jar $ALIGNMENTTOOLS alignment-merger temp all_seqs_derep_aln.fa >> $LOCATION/log.txt

echo "Calculating distance matrix ..."
mkdir $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/distance_matrix
cd $LOCATION/3_"$NAME"_alignment_and_cluster/
java -Xmx24g -jar $CLUST dmatrix --id-mapping $LOCATION/2_"$NAME"_uchime/derep/all_seqs.ids --in all_seqs_derep_aln.fa --outfile complete_linkage_cluster/distance_matrix/all_seqs_derep_aligned.fasta_matrix.bin --mask "=GC_RF" -l 25 --dist-cutoff $DIST >> $LOCATION/log.txt

echo "Performing complete linkage clustering ..."
java -Xmx24g -jar $CLUST cluster --method complete --id-mapping $LOCATION/2_"$NAME"_uchime/derep/all_seqs.ids --sample-mapping $LOCATION/2_"$NAME"_uchime/derep/all_seqs.samples --dist-file complete_linkage_cluster/distance_matrix/all_seqs_derep_aligned.fasta_matrix.bin --outfile complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust --step $STEP >> $LOCATION/log.txt

echo "mapping all sequences back to good dereped and chimera checked sequences of individual samples ..."
java -Xmx4g -jar $CLUST explode-mappings --out-dir explode-mappings derep/all_seqs.ids derep/all_seqs.samples chime_ref/all_seqs_unique_nospace_sorted.ref.good.fasta

echo "Generating OTU table ..."
mkdir $LOCATION/R
cd $LOCATION
java -Xmx24g -jar $CLUST cluster_to_Rformat 3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust R/ $STEP $DIST >> $LOCATION/log.txt

echo "Get representative sequences and determine their taxanomy ..."
cd $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster
java -Xmx24g -jar $CLUST rep-seqs -c --id-mapping $LOCATION/2_"$NAME"_uchime/derep/all_seqs.ids --one-rep-per-otu all_seqs_derep_aligned.fasta_complete.clust $DIST ../all_seqs_derep_aln.fa >> $LOCATION/log.txt
java -Xmx24g -jar $CLASSIFIER classify -c $BOOTSTRAP_VALUE -f fixrank -o ../../R/otu_taxa_fixrank.txt all_seqs_derep_aligned.fasta_complete.clust_rep_seqs.fasta >> $LOCATION/log.txt
  
echo "Extract representative sequence alignment region ..."
mkdir $LOCATION/3_"$NAME"_alignment_and_cluster/tree
cd $LOCATION/3_"$NAME"_alignment_and_cluster/tree
java -Xmx24g -jar $CLUST derep -f -o all_complete.clust_rep_seqs_modelonly.fasta rep_seqs.ids rep_seqs.sample ../all_seqs_derep_aligned.fasta_complete.clust_rep_seqs.fasta >> $LOCATION/log.txt

echo "Constructing phylogenetic tree ..."
$FASTTREE -nt -gtr < all_complete.clust_rep_seqs_modelonly.fasta > all_complete.clust_rep_seqs.nwk >> $LOCATION/log.txt

