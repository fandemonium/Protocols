Use Usearch (UPARSE pipeline) to analyze fungal ITS sequneces
======
The previous binning process is important for using usearch.
 The freely distributed usearch is 32 bit. 
It CANNOT handle 1 million sequences. In addition, since chimera is an artifactfrom PCR, individual sample should be treated seperatedly 
(Edgar has a [different opinion](http://www.drive5.com/usearch/manual/uchime_pool.html), which I think would introduce more computational artifacts). 

General Rules:
----
1. Use usearch to further ensure sequence quality.   
2. Use usearch to perform de novo followed by reference based chimera removal.    
3. Use usearch to cluster ITS sequences and pick OTUs. 
4. Use RDP classifier to generate taxonomy for each OTU.

Detailed Procedures:
----
1. Reensure sequence quality using usearch using per base stats. See [here](http://www.drive5.com/usearch/manual/avgq.html) for explaination on why choose per base stats over average Q score.       
        ```
        for i in *.fastq; do ~/usearch70 -fastq_stats $i -log "$i"_stats.log; done
        ```

3. **Chimera removal**       
    1. Why choose Usearch over other?    
        See [here](https://rdp.cme.msu.edu/tutorials/workflows/16S_supervised_flow.html)

    2. For reference mode, why use RDP training sets instead of greengene or silva?   
        See [here](http://www.drive5.com/usearch/manual/uchime_ref.html)

    3. Check [here](http://drive5.com/usearch/) for new version of Usearch. Check [here](http://sourceforge.net/projects/rdp-classifier/files/RDP_Classifier_TrainingData/) for new version of RDP training sets.     

    4. Chimera removal:
        1. Check for chimeras de novo first:
            1. Why?   
                Any chimera generated from unknown organisms that are not in databases would not be eliminated via reference mode.   
  
            2. Use usearch/uparse to quality filter the binned pair-ended (full-coverage) fastq files. For filter parameter and trimming variations and details, see [here](http://drive5.com/usearch/manual/fastq_choose_filter.html)
                ```
                for i in *.fastq; do ~/usearch70 -fastq_filter $i -fastq_maxee 0.5 -fastaout ../../uparsed/quality_filtered/"$i"_maxee_0.5.fasta; done
                ```

            3. Dereplicate reads, determine cluster sizes:
                ```
                for i in *_0.5.fasta; do ~/usearch70 -derep_fulllength $i -output ../derep/"$i"_unique.fasta -sizeout; done
                ```

                *Note:* you could use `-minsize 2` to get rid of singletons at this step. But you still need to sort clusters by size. Might as well get rid of singletons during next step. 


            4. Sort by size to remove singletons:
                ```
                for i in *_unique.fasta; do ~/usearch70 -sortbysize $i -output ../sorted/"$i"_sorted.fa -minsize 2; done
                ```

            4. Use cluster_otus to get rid of chimeras. So I don't like to cluster before I can confirm all of the chimeras are removed... so i clustered my ITS at 0. Also, don't use `-otus`.  
                ```
                for i in *.fa; do ~/usearch70 -cluster_otus $i -otuid 0.985 -fastaout ../4_cluster_otus_0.985/all_headers/"$i"_all_headers.fa -otus ../4_cluster_otus_0.985/otus/"$i"_otus.fa; done                
                ```

            5. get rid of chimera clusters
                ```
                for i in *_header.fasta; do python ~/Documents/Fan/code/usearch_denovo_chim_remover.py $i ../chimera_removed/"$i"_good.fa; done
                ```

    4. Check for chimeras on each binned fasta file with reference dataset:   
        ```
        for i in *_otus1.fa; do ~/usearch70 -uchime_ref $i -db ~/Documents/Databases/RDPClassifier_16S_trainsetNo10_rawtrainingdata/trainset10_082014_rmdup.fasta -uchimeout ../../5_uchime_ref/stats/"$i".uchime -strand plus -selfid -mindiv 1.5 -mindiffs 5 -chimeras ../../5_uchime_ref/chimeras/"$i"_chimera.fa -nonchimeras ../../5_uchime_ref/good_otus/"$i"_good.fa; done
        ```
        
        ```
        for i in *_good.fa; do ~/usearch70 -uchime_ref $i -db ~/Documents/Databases/fungalits_warcup_trainingdata1/Warcup.fungalITS.fasta -uchimeout ../uchime_ref/stats/$i.uchime -strand plus -selfid -mindiv 1.5 -mindiffs 5 -chimeras ../uchime_ref/chimeras/"$i"_chimera.fa -nonchimeras ../uchime_ref/good/"$i"_ref_good.fa; done
        ```
 
        1. Why not check chimeras on the assembled paired-end file?    
            Free Usearch is 32-bit. The big assembled file will cause Usearch to crash for out of memory. The NoTag.fasta may be too large for Usearch as well. Don't be surprised if there is nothing in NoTag uchime outputs. Since, the NoTag files is only used early on to quantify sequence outputs, I usually don't brother to process it any more at this step. 

        2. -mindiv, -mindiffs    
            These parameters are adapted from the old [Uchime](http://www.drive5.com/usearch/manual/UCHIME_score.html). 

        3. The number of chimera sequences and good sequences don't add up?    
            Check your XXX.uchime output. Use:    
            ```
            grep -cw "?" XXX.uchime
            ```
          
            **Note:** The number of chimera, good sequence, and "?" should add up. "?" are sequences that Usearch couldn't classify it as either chimera or good sequence. This usually happens with default parameter. But it shouldn't be happening with `-mindiv 1.5 -mindiffs 5`. 

        4. To check if all files chimera number and good sequence number summs up, do:   
            ```
            python ~/Documents/Fan/code/check_chimera_numbers.py good_reads/number_good_reads.txt chimeras/number_chimera.txt ../binned_assem/number_16S_assem.txt 
            ```

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
