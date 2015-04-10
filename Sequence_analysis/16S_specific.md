1. quality filter:
    ```
    for i in *.fastq; do ~/usearch70 -fastq_filter $i -fastq_maxee 0.5 -fastaout ../../uparsed/quality_filtered/"$i"_maxee_0.5.fasta; done
    ```

2. dereplicate for unique sequences                
    ```
    for i in *_0.5.fasta; do ~/usearch70 -derep_fulllength $i -output ../derep/"$i"_unique.fasta -sizeout; done
    ```

    *Note:* you could use `-minsize 2` to get rid of singletons at this step. But you still need to sort clusters by size. Might as well get rid of singletons during next step. 


3. Sort by size to remove singletons (just to put aside for now):
    ```
    for i in *_unique.fasta; do ~/usearch70 -sortbysize $i -output ../sorted/"$i"_sorted.fa -minsize 2; done
    ```

4. Use cluster_otus to get rid of chimeras (de novo).                 
    ```
    for i in *.fa; do ~/usearch70 -cluster_otus $i -otuid 0.985 -fastaout ../4_cluster_otus_0.985/all_headers/"$i"_all_headers.fa -otus ../4_cluster_otus_0.985/otus/"$i"_otus1.fa; done                
    ```

5. get rid of chimeras using reference database (uchime_ref):   
    ```
    for i in *_otus1.fa; do ~/usearch70 -uchime_ref $i -db ~/Documents/Databases/RDPClassifier_16S_trainsetNo10_rawtrainingdata/trainset10_082014_rmdup.fasta -uchimeout ../../5_uchime_ref/stats/"$i".uchime -strand plus -selfid -mindiv 1.5 -mindiffs 5 -chimeras ../../5_uchime_ref/chimeras/"$i"_chimera.fa -nonchimeras ../../5_uchime_ref/good_otus/"$i"_good.fa; done
    ```

6. rename good otu's, in directory `5_uchime_ref`:   
    ```
    mkdir good_otus_renamed
    cd good_otus
    for i in *.fa; do python ~/python_scripts/fasta_number.py $i OTU_ > ../good_otus_renamed/"$i"_otu2.fa; done
    ```

7. Mapping all sequences (including singletons) back to good OTU's. In directory `6_map_reads`:   
    ```
    mkdir uc
    mkdir seqs
    cd ../1_quality_filtered
    for i in *.fasta; do ~/usearch70 -usearch_global $i -db ../5_uchime_ref/good_otus_renamed/"$i"_unique.fasta_sorted.fa_otus1.fa_good.fa_otus.fa -strand plus -id 0.985 -uc ../6_map_reads/uc/"$i"_map.uc -matched ../6_map_reads/seqs/"$i"_matched.fa; done
    ``` 

8. decide which samples should be analyzed together and use `mkdir XXX` to put them into different folders    

9. use RDP fungene pipeline to complete the rest:
    1. make a folderi (outside of `uparse` directory):   
        ```
        mkdir 4_spruce_may312014_16S_ana
        ```

    2. setup option file:
        ```
        cd 4_spruce_may312014_16S_ana
        mkdir workdir
        ~/fungene_pipeline/fgp_wrapper.py ~/fungene_pipeline/examplefiles/16S_options.txt ~/fungene_pipeline/examplefiles/alignment_command.txt /PATH/TO/DIRECTORY/WITH/GOOD/SEQS/*.fa 
        ```
        
        note: the clustering can take a LONG time. 
 







8. link matched sequences to 

        
1. RDP unsupervised analysis: Classifier. group samples into their own groups, ie. cobs for cobs, spruce for spruce.
    ```
    java -Xmx4g -jar ~/RDPTools/classifier.jar classify -g fungalits_warcup -c 0.5 -f fixrank -o Spruce_2013_ITS_classified_0.5.txt -h Spruce_2013_ITS_hier.txt *.fa
    ```

    ```
    java -Xmx4g -jar ~/RDPTools/classifier.jar classify -g fungalits_warcup -c 0.5 -f filterbyconf -o Spruce_2013_ITS_classified_0.5_filtered_rank.txt all_otus.fa 
    ```

Mapping back:
```
for i in *_0.5.fasta; do ~/usearch70 -usearch_global $i -db ../6_consolidate_otus/all_otus.fa -strand plus -id 0.97 -uc ../7_map_uc/"$i"_map.uc; done
```

Add sample name to map.uc
```
for i in *.uc; do python ~/Documents/Fan/code/usearch_map_uc_parser.py $i > ../map_uc_sample/"$i".sample; done
```
When mapping map.uc back to the sequence, I think the singletons are also included when mapping. considering the whole point of removing singletons because they are errorness. Should get rid of the singletons from the very beginning?

For 16S:
```
~/usearch70 -usearch_global ../../16s_test.fasta -db uparse_test_otu_clust_0.97_otusn.fasta -strand plus -id 0.97 -matched 16s_test_matched.fa -uc 16s_test_readmap.uc
```

java -Xmx4g -jar /Users/metagenomics/RDPTools/Clustering.jar derep --unaligned -o /Users/metagenomics/Documents/2013_ITS_fy/uparsed/6_consolidate_otus/rdp_derep/all_seqs_derep.fasta /Users/metagenomics/Documents/2013_ITS_fy/uparsed/6_consolidate_otus/rdp_derep/all_seqs.ids /Users/metagenomics/Documents/2013_ITS_fy/uparsed/6_consolidate_otus/rdp_derep/all_seqs.samples /Users/metagenomics/Documents/2013_ITS_fy/uparsed/6_consolidate_otus/all_maxee_0.5.fa


increase the break number to avoid new false chimeras
~/usearch70 -cluster_otus cat_otu_good_derep_sorted.fa -otuid 0.985 -uparse_break -100.0 -otus all_otus1.fa -fastaout all_header_otus1.fa

for i in *.fasta; do ~/usearch70 -usearch_global $i -db ../6_consolidate_otus/all_otusn.fa -strand plus -id 0.985 -uc ../7_map_uc/map_uc/"$"_map.uc; done

16S:
for i in *.fasta; do ~/usearch70 -usearch_global $i -db ../5_uchime_ref/good_otus_renamed/"$i"_unique.fasta_sorted.fa_otus1.fa_good.fa_otus.fa -strand plus -id 0.985 -uc ../6_map_reads/uc/"$i"_map.uc -matched ../6_map_reads/seqs/"$i"_matched.fa; done
