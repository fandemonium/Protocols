Gene-Targetted Sequence Analysis
====================

This protocol is specifically modified to use with Pat Schloss method of gene targetting sequencing results from which 3 fastq.gz files were yielded:
+ XXXX_I1_XXX.fastq.gz (index file that stores barcodes)
+ XXXX_R1_XXX.fastq.gz (forward paired-end sequence, no tag nor linker/primer combo)
+ XXXX_R2_XXX.fastq.gz (reverse paired-end sequence, no tag nor linker/primer combo)

*General Procedures:
1. Use pandaseq to construct good quality full length sequences (assem.fastq)  
2. Fix sequence names in I.fastq.gz to match assem.fastq (I_fixed.fastq)
3. Subset I_fixed.fastq to the same sequences as assem.fastq
4. Use qiime: split_library_fastq.py to parse sequences to individual samples (minimize quality trim at this step)
5. 

1. RDP_assembler  
    ```
    ~/RDP_Assembler/pandaseq/pandaseq -N -o 40 -e 25 -F -d rbfkms -l 220 -L 280 -f Undetermined_S0_L001_R1_001.fastq.gz -r Undetermined_S0_L001_R2_001.fastq.gz 1> IGSB140210-1_assembled_o40.fastq 2> IGSB140210-1_assembled_stats_o40.txt
    ```
    
    1. make sure the number of good assembled sequence in assembled.fastq is the same as the OK number in stats.txt file   
        ```
        grep -c "@M0" IGSB140210-1_assembled_o40.fastq  
        ```
2. RDPTools: SeqFilters   
    This step trims off the tag and linker sequences. Final files are splited into folders named by individual samples.    
    Need:   
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

        Linker: `CC`
 
        Forward primer: 515F `GTGCCAGCMGCCGCGGTAA`
        
        Reverse primer: 806R `GGACTACHVGGGTWTCTAAT`

        **Note:**  
        The sequences (R1.fastq and R2.fastq) from ANL does not contain barcodes or primers! The tag information are stored in the index file (I1.fastq).   

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
            python ~/Documents/Fan/Smita/micro_code_23/MiSeq_rdptool_map_parser.py ANL_MAPPING_FILE.txt > TAG_FILE.tag
            ```

        2. ANL sequences were sequenced from reverse primer end. The tag sequences need to be reverse compilmented (even though SeqFilter should automatically reverse compilment sequence if 16S genes are analyzed): 
            ```
            python revcomp.py 16S_tag.txt > 16S_tag_rev.txt
            ```
        
        3. Then run SeqFilters to parse the I1.fastq to bin seq id into individual sample directories.       
            ```
            java -jar $SeqFilters --seq-file original/Undetermined_S0_L001_I1_001.fastq.gz --tag-file 16S_tag_rev.txt --outdir initial_process_Index_rev
            ```

            Note: to make sure tags were binning as expected, the quality of the tag could be set as 0 to begin with `--min-qual 0`   

