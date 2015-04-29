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

9. use RDP fungene pipeline to perform dereplication and sequence alignment:
    1. make a folder in (outside of `uparse` directory):   
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
 
10. Calculate sequence distance matrix (in PATH/TO/4_spruce_may312014_rdp/16s_pipeline-job):
    ```
    java -Xmx16g -jar /Users/metagenomics/RDPTools/Clustering/dist/Clustering.jar dmatrix --id-mapping all_seqs.ids --in ./alignment/all_seqs_derep_aligned.fa --outfile ./dist_matrix/all_matrix.bin -m "#=GC_RF" -l 25 --dist-cutoff 0.03
    ``` 

11. from distance matrix to otu's (clustering):
    ```
    java -Xmx16g -jar ~/RDPTools/Clustering/dist/Clustering.jar cluster --method complete --id-mapping ../all_seqs.ids --sample-mapping ../all_seqs.samples --dist-file all_matrix.bin --outfile all_complete.clust --step 0.01
    ```

12. from cluster file to biom format:
    ```
    java -Xmx2g -jar ~/RDPTools/Clustering/dist/Clustering.jar cluster-to-biom dist_matrix/all_complete.clust 0.03 > dist_matrix/all_complete.clust.biom
    ```
    
    Note: a flat otu table that can also be directly used in R using:
        ```
        java -Xmx4g -jar ~/RDPTools/Clustering/dist/Clustering.jar cluster_to_Rformat all_complete.clust . 0.03 0.03
        ```
        
        But one can't use flat otu table directly to work with Phyloseq in R, because it uses "OTU_" instead of "cluster_". Therefore, if you are using RDP tools and phyloseq, use biom format.   

13. get representative sequences per each otu identified (same otu id's like those in your biom file):
    ```
    java -Xmx4g -jar ~/RDPTools/Clustering/dist/Clustering.jar rep-seqs -c --id-mapping all_seqs.ids --one-rep-per-otu dist_matrix/all_complete.clust 0.03 alignment/all_seqs_derep_aligned.fasta
    ```

14. classify the otu representative seqs according to biom file:
    ```
    java -Xmx4g -jar ~/RDPTools/classifier/dist/classifier.jar classify -c 0.5 -f biom -m dist_matrix/all_complete.clust.biom -o dist_matrix/all_complete.clust_classified.biom all_complete.clust_rep_seqs.fasta
    ```

15. Phyloseq can also store representative sequences as part of their database management. But sequence alignments have to be destroyed and the sequence names have to also match to the cluster names.
    ```
    java -Xmx4g -jar ~/RDPTools/Clustering/dist/Clustering.jar to-unaligned-fasta all_complete.clust_rep_seqs.fasta | cut -f1 -d ' ' > all_complete.clust_rep_seqs_unaligned_short_name_phyloseq.fasta
    ```

16. Since you are at it, might as well add the phylogenetic tree to the phyloseq database:
    1. first of all, extract alignment positions from sequences:    
        ```
        java -Xms4g -jar ~/RDPTools/Clustering/dist/Clustering.jar derep -f -o all_complete.clust_rep_seqs_modelonly.fasta rep_seqs.ids rep_seqs.sample all_complete.clust_rep_seqs.fasta
        ```
 
    2. use fasttree to build a phylogenetic tree based on the model postion:
        ```
        ~/FastTree -nt -gtr < all_complete.clust_rep_seqs.fasta > all_complete.clust_rep_seqs_tree.nwk
        ```

17. now you should have all of the files you need for community analysis in R.         
