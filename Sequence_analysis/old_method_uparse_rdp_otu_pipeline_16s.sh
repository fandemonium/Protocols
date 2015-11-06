## BEFORE START 
## update full pathways and parameters from line 7 to line 30. some pathways can be found in macpro_some_pathways.md
## this pipeline is specifically for 16S
## mapping files should be already formatted into RDP format and excel carriage returns removed 
## change java heapspace (-Xmx) to 1/4 or less of your max machine ram.

NAME="rdp"
LOCATION="/home/ubuntu/data/data3/fan/pitfoaming"
#INDEX_FILE="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_I1_001.fastq.gz"
#READ_1="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_R1_001.fastq.gz"
#READ_2="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/Undetermined_S0_L001_R2_001.fastq.gz"
#MAP="/Users/metagenomics/Documents/2014_COBS_Spruce_cdna/0_original/rdp_mapping_file_rev.txt"
#FAN_PY="/Users/metagenomics/Documents/Fan/code"
#UPARSE_PY="/Users/metagenomics/python_scripts"
#REF_16S="/Users/metagenomics/Documents/Databases/RDPClassifier_16S_trainsetNo10_rawtrainingdata/trainset10_082014_rmdup.fasta"
MODEL_16S="/home/ubuntu/data/data3/fan/RDPinfernal1.1Traindata/bacteria_model.cm"

SEQFILTER="/home/ubuntu/RDPTools/SeqFilters.jar"
#PANDASEQ="/Users/metagenomics/RDP_Assembler/pandaseq/pandaseq"
#USEARCH="/Users/metagenomics/usearch70"
#CMALIGN="/Users/metagenomics/infernal1.1.1/bin/cmalign"
ALIGNMENTTOOLS="/home/ubuntu/RDPTools/AlignmentTools.jar"
CLUST="/home/ubuntu/RDPTools/Clustering.jar"
CLASSIFIER="/home/ubuntu/RDPTools/classifier.jar"
#FASTTREE="/Users/metagenomics/FastTree"

READQ="25"
DIST="0.03"
STEP="0.01"
BOOTSTRAP_VALUE="0.5"

cd $LOCATION

#echo "assembling pair-ended reads ..."
#mkdir 1_"$NAME"_demultiplex 1_"$NAME"_demultiplex/assembled
#
#$PANDASEQ -N -o 10 -e $READQ -F -d rbfkms -l 250 -L 280 -f $READ_1 -r $READ_2 1> 1_"$NAME"_demultiplex/assembled/assembled_reads.fastq 2>  1_"$NAME"_demultiplex/assembled/assembled_reads_stats.txt
#echo "done."
#
#echo "parsing index file ..."
#java -jar $SEQFILTER -Q $READQ --seq-file $INDEX_FILE --tag-file $MAP --outdir 1_"$NAME"_demultiplex/parse_index
#echo "moving quality trimmed index reads to directory 'trimmed_tags'"
#mkdir 1_"$NAME"_demultiplex/parse_index/trimmed_tags
#mv 1_"$NAME"_demultiplex/parse_index/result_dir/*/*_trimmed.fasta 1_"$NAME"_demultiplex/parse_index/trimmed_tags/
#echo "done."
#
#echo "demultiplexing assembled reads ..."
#cd 1_"$NAME"_demultiplex/parse_index/trimmed_tags
#mv NoTag_trimmed.fasta $LOCATION/1_"$NAME"_demultiplex/parse_index/result_dir/NoTag
#python $FAN_PY/bin_reads.py $LOCATION/1_"$NAME"_demultiplex/assembled/assembled_reads.fastq
#cd $LOCATION
#mkdir 1_"$NAME"_demultiplex/demultiplexed_assembled_reads
#mv 1_"$NAME"_demultiplex/parse_index/trimmed_tags/*_assem.fastq 1_"$NAME"_demultiplex/demultiplexed_assembled_reads
#echo "done."
#
#echo "prune reads to maxee=0.5 ..."
#mkdir 2_"$NAME"_uparse 2_"$NAME"_uparse/quality_filtered
#cd 1_"$NAME"_demultiplex/demultiplexed_assembled_reads
#for i in *.fastq; do $USEARCH -fastq_filter $i -fastq_maxee 0.5 -fastaout $LOCATION/2_"$NAME"_uparse/quality_filtered/"$i"_maxee_0.5.fasta; done
#echo "done."
#
#echo "dereplicate reads ..."
#mkdir $LOCATION/2_"$NAME"_uparse/derep
#cd $LOCATION/2_"$NAME"_uparse/quality_filtered
#for i in *_0.5.fasta; do $USEARCH -derep_fulllength $i -output $LOCATION/2_"$NAME"_uparse/derep/"$i"_unique.fasta -sizeout; done
#echo "done."
#
#echo "sorting by cluster size and removing singltons ..."
#mkdir $LOCATION/2_"$NAME"_uparse/sorted
#cd $LOCATION/2_"$NAME"_uparse/derep
#for i in *_unique.fasta; do $USEARCH -sortbysize $i -output $LOCATION/2_"$NAME"_uparse/sorted/"$i"_sorted.fa -minsize 2; done
#echo "done."
#
#echo "removing chimeras using de novo ..."
#mkdir $LOCATION/2_"$NAME"_uparse/chime_denovo
#cd $LOCATION/2_"$NAME"_uparse/sorted
#for i in *.fa; do $USEARCH -cluster_otus $i -otuid 0.985 -otus $LOCATION/2_"$NAME"_uparse/chime_denovo/"$i"_otu1.fa; done
#echo "done."
#
#echo "removing chimeras using references ..."
#mkdir $LOCATION/2_"$NAME"_uparse/chime_ref $LOCATION/2_"$NAME"_uparse/chime_ref/stats $LOCATION/2_"$NAME"_uparse/chime_ref/chimeras $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus
#cd $LOCATION/2_"$NAME"_uparse/chime_denovo
#for i in *_otu1.fa; do $USEARCH -uchime_ref $i -db $REF_16S -uchimeout $LOCATION/2_"$NAME"_uparse/chime_ref/stats/"$i".uchime -strand plus -selfid -mindiv 1.5 -mindiffs 5 -chimeras $LOCATION/2_"$NAME"_uparse/chime_ref/chimeras/"$i"_chimera.fa -nonchimeras $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus/"$i"_good.fa; done
#echo "done."
#
#echo "renaming otus that are rid of chimeras to 'OTU_XX' ..."
#mkdir $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus_renamed
#cd $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus
#for i in *_good.fa; do python $UPARSE_PY/fasta_number.py $i OTU_ > $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus_renamed/"$i"_otu2.fa; done
#echo "done"
#
#echo "mapping all sequences (including singletons) back to good OTU's of individual samples ..."
#mkdir $LOCATION/2_"$NAME"_uparse/mapped $LOCATION/2_"$NAME"_uparse/mapped/uc $LOCATION/2_"$NAME"_uparse/mapped/seqs
#cd 2_"$NAME"_uparse/quality_filtered
#for i in *.5.fasta; do $USEARCH  -usearch_global $i -db $LOCATION/2_"$NAME"_uparse/chime_ref/good_otus_renamed/"$i"_unique.fasta_sorted.fa_otu1.fa_good.fa_otu2.fa -strand plus -id 0.985 -uc $LOCATION/2_"$NAME"_uparse/mapped/uc/"$i"_map.uc -matched $LOCATION/2_"$NAME"_uparse/mapped/seqs/"$i"_matched.fa; done
#echo "done"
#
#echo "prepare finalized sequences for alignment and clustering ..."
#echo "cancatenate and dereplicate ..."
#mkdir $LOCATION/3_"$NAME"_alignment_and_cluster $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment
#cd $LOCATION/good_seqs
#java -Xmx16g -jar $CLUST derep --unaligned -o $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs_derep.fasta $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs.ids $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs.samples *.fa

#echo "align finalized sequences ..."
#cd $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment
#mkdir temp
##split -l 100 all_seqs_derep.fasta
#cmalign -o temp/temp_aln.stk -g --noprob $MODEL_16S < all_seqs_derep.fasta   
#java -Xmx10g -jar $ALIGNMENTTOOLS alignment-merger temp all_seqs_derep_aln.fa

#echo "Calculating distance matrix ..."
#mkdir $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/distance_matrix
#cd $LOCATION/3_"$NAME"_alignment_and_cluster/
#java -Xmx24g -jar $CLUST dmatrix --id-mapping Derep_alignment/all_seqs.ids --in Derep_alignment/all_seqs_derep_aln.fa --outfile complete_linkage_cluster/distance_matrix/all_seqs_derep_aligned.fasta_matrix.bin --mask "#=GC_RF" -l 25 --dist-cutoff $DIST

#echo "Performing complete linkage clustering ..."
#java -Xmx24g -jar $CLUST cluster --method complete --id-mapping Derep_alignment/all_seqs.ids --sample-mapping Derep_alignment/all_seqs.samples --dist-file complete_linkage_cluster/distance_matrix/all_seqs_derep_aligned.fasta_matrix.bin --outfile complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust --step $STEP

#echo "Generating OTU table ..."
#mkdir $LOCATION/R
#cd $LOCATION
#java -Xmx24g -jar $CLUST cluster_to_Rformat 3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust R/ $STEP $DIST

echo "Classify representative sequences ..."
cd $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster
#java -Xmx4g -jar $CLUST rep-seqs --id-mapping ../Derep_alignment/all_seqs.ids --one-rep-per-otu all_seqs_derep_aligned.fasta_complete.clust $DIST ../Derep_alignment/all_seqs_derep_aln.fa
#java -Xmx4g -jar $CLASSIFIER classify -c $BOOTSTRAP_VALUE -f fixrank -o ../../R/otu_taxa_fixrank.txt all_seqs_derep_aligned.fasta_complete.clust_rep_seqs.fasta 
echo "Classify each otu ..."
java -Xmx4g -jar $CLUST rep-seqs -c --id-mapping $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs.ids --one-rep-per-otu $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust $DIST $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs_derep_aligned.fasta
  
### biom format ####
#echo "Generating biom format file for R ..."
#echo "Converting otu table to biom ..."
#mkdir $LOCATION/3_"$NAME"_alignment_and_cluster/R
#cd $LOCATION/3_"$NAME"_alignment_and_cluster/R
#java -Xmx2g -jar $CLUST cluster-to-biom $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust $DIST > $LOCATION/3_"$NAME"_alignment_and_cluster/R/all_complete.clust.biom

#echo "Classify each otu ..."
#java -Xmx4g -jar $CLUST rep-seqs -c --id-mapping $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs.ids --one-rep-per-otu $LOCATION/3_"$NAME"_alignment_and_cluster/complete_linkage_cluster/all_seqs_derep_aligned.fasta_complete.clust $DIST $LOCATION/3_"$NAME"_alignment_and_cluster/Derep_alignment/all_seqs_derep_aligned.fasta

#java -Xmx4g -jar $CLASSIFIER classify -c $BOOTSTRAP_VALUE -f biom -m $LOCATION/3_"$NAME"_alignment_and_cluster/R/all_complete.clust.biom

#echo "Constructing phylogenetic tree ..."
#cd $LOCATION/3_"$NAME"_alignment_and_cluster/R
#java -Xms4g -jar $CLUST derep -f -o all_complete.clust_rep_seqs_modelonly.fasta rep_seqs.ids rep_seqs.sample all_complete.clust_rep_seqs.fasta

#$FASTTREE -nt -gtr < all_complete.clust_rep_seqs.fasta > all_complete.clust_rep_seqs.nwk

