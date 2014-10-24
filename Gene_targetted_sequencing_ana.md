Gene-Targetted Sequence Analysis
====================

This protocol is specifically modified to use with Pat Schloss method of gene targetting sequencing results from which 3 fastq.gz files were yielded:    
+ XXXX_I1_XXX.fastq.gz (index file that stores barcodes)    
+ XXXX_R1_XXX.fastq.gz (forward paired-end sequence, no tag nor linker/primer combo)    
+ XXXX_R2_XXX.fastq.gz (reverse paired-end sequence, no tag nor linker/primer combo)    

General Procedures:   
------------------
1. Use RDP's pandaseq (RDP_Assembler) to construct good quality full length sequences (assem.fastq).   
2. Use RDPTools/SeqFilters to check barcodes quality and split them into different sample directories (ONLY barcodes need to be reverse complimented, sequences are in the correct orientation).   
3. Bin assembled sequences into different sample files.   
4. Check for chimeras.  
5. Use RDPTools/Classifiers to pick taxonomy, use RDPToools/AlignmentTools to align sequences and then cluster using RDPTools/mcCluster.   
6. R for analysis

Detailed Procedures:   
-------------------
1. **RDP_assembler**  
    1. First run with minimal constrants:i   
        ```
        ~/RDP_Assembler/pandaseq/pandaseq -N -o 10 -e 25 -F -d rbfkms -f /PATH/TO/Undetermined_S0_L001_R1_001.fastq.gz -r /PATH/TO/Undetermined_S0_L001_R2_001.fastq.gz 1> IGSB140210-1_assembled.fastq 2> IGSB140210-1_assembled_stats.txt
        ```

        You should look at the stat output. If you are analysing for 16S, pay close attention to sequences that are shorter than 250b and longer than 280b. Majority of sequences outside of the 250-280 range are eukaryotic. Some are bacterial but with high uncertainties. 

    2. You could analyze your assembled read stat file by:
        ```
        python ~/Documents/Fan/code/rdp_assem_stat_parser.py IGSB140210-1_assembled_stats.txt
        ```
 
        You may need to modify the python script for different parameters.

    3. Run assembler again with comfirmed parameters:
        ```
        ~/RDP_Assembler/pandaseq/pandaseq -N -o 22 -e 25 -F -d rbfkms -l 250 -L 280 -f /PATH/TO/Undetermined_S0_L001_R1_001.fastq.gz -r /PATH/TO/Undetermined_S0_L001_R2_001.fastq.gz 1> IGSB140210-1_assembled_250-280.fastq 2> IGSB140210-1_assembled_stats_250-280.txt
        ```

    4. make sure the number of good assembled sequence in assembled.fastq is the same as the OK number in stats.txt file   
        ```
        grep -c "@M0" IGSB140210-1_assembled_250-280.fastq  
        ```

2. **RDPTools: SeqFilters**   
    This step trims off the tag and linker sequences. Final files are splited into folders named by individual samples.    
    
    **Need:**   
    1. map file from Argonne
        ```
        #SampleID       BarcodeSequence LinkerPrimerSequence    Description
        DC1     TCCCTTGTCTCC    CCGGACTACHVGGGTWTCTAAT  DC1
        DC2     ACGAGACTGATT    CCGGACTACHVGGGTWTCTAAT  DC2
        DC3     GCTGTACGGATT    CCGGACTACHVGGGTWTCTAAT  DC3
        DC4     ATCACCAGGTGT    CCGGACTACHVGGGTWTCTAAT  DC4
        DC5     TGGTCAACGATA    CCGGACTACHVGGGTWTCTAAT  DC5
        ```

        Tags example: `TCCCTTGTCTCC`   

        16S V4 Forward primer: 515F `GTGCCAGCMGCCGCGGTAA`
        
        16S V4 Reverse primer: 806R `GGACTACHVGGGTWTCTAAT`

        ITS 1/2 Forward primer: ITS1f `CTTGGTCATTTAGAGGAAGTAA`

        ITS 1/2 Reverse primer: ITS2 `GCTGCGTTCTTCATCGATGC`

        **Note:**  
        1. The sequences (R1.fastq and R2.fastq) from ANL does not contain barcodes or primers! The tag information are stored in the index file (I1.fastq).   
        2. If the mapping file was generated or edited in excel, unwanted invisible characters would be present (you can visualize them in by using `less` or `vi`). To get rid of the characters and make the file recognizable by python, do:
            ```
            ~/Documents/Fan/code/mac2unix.pl MAPPING_FILE.txt > fixed_mapping_file.txt
            ```

    2. SeqFilters need tag file to be like this:   
        ```
        TCCCTTGTCTCC    DC1
        ACGAGACTGATT    DC2
        GCTGTACGGATT    DC3
        ATCACCAGGTGT    DC4
        TGGTCAACGATA    DC5
        ```

        1. You can parse the Argonne file into above format:
            ```
            python ~/Documents/Fan/code/MiSeq_rdptool_map_parser.py ANL_MAPPING_FILE.txt > TAG_FILE.tag
            ```

        2. ANL tag sequences need to be reverse compilmented. It's much easier to reverse compliment the parsed tag file than the index file (XXX_I1.fastq) 
            ```
            python ~/Documents/Fan/code/revcomp_rdp_format.py 16S_tag.txt > 16S_tag_rev.txt
            ```
        
        3. Then run SeqFilters to parse the I1.fastq to bin seq id into individual sample directories.       
            ```
            java -jar $SeqFilters --seq-file original/Undetermined_S0_L001_I1_001.fastq.gz --tag-file 16S_tag_rev.txt --outdir initial_process_Index_rev
            ```

            Note: to make sure tags were binning as expected, the quality of the tag could be set as 0 to begin with `--min-qual 0`   

3. **Chimera check using Usearch with RDP training set as a reference database**       
    1. Why choose Usearch over other?    
        See [here](https://rdp.cme.msu.edu/tutorials/workflows/16S_supervised_flow.html)

    2. Why use RDP training set instead of greengene or silva?   
        See [here](http://www.drive5.com/usearch/manual/uchime_ref.html)

    3. Check [here](http://drive5.com/usearch/) for new version of Usearch. Check [here](http://sourceforge.net/projects/rdp-classifier/files/RDP_Classifier_TrainingData/) for new version of RDP training sets.     

    4. Check for chimeras on each binned fasta file:   
        ```
        for i in *_assem.fasta; do ~/usearch70 -uchime_ref $i -db ~/Documents/Databases/RDPClassifier_16S_trainsetNo10_rawtrainingdata/trainset10_082014_rmdup.fasta -uchimeout $i.uchime -strand plus -selfid -mindiv 1.5 -mindiffs 5 -chimeras "$i"_chimera.fasta -nonchimeras "$i"_good.fasta; done
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
