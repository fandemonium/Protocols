Use SeqFilters to seperate merged sequences into individual sample files
========

General Rules:
---
1. Check barcode qualities.  
2. Bin good quality barcodes with sequence headers into individual sample folders.  
3. Query assembled amplicon sequences into indivdual sample files based on the sequence headers.  
4. Individual files can then be used in down stream processes. 

Detailed procedures:
----
1. RDPTools: SeqFilters   
    SeqFilters can be used to trim off the tag, primer and linker sequences. But for the sequences I obtained from ANL, I use SeqFilters on the index file alone to split barcodes into folders named as individual samples.    
    
    **Need:**   
    1. mapping file from Argonne
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
        1. The raw sequences (R1.fastq and R2.fastq) from ANL does not contain barcodes or primers! The tag information are stored in the index file (I1.fastq).   
        2. If the mapping file was generated or edited in excel, unwanted invisible characters would be present (you can visualize them in by using `less` or `vi`). To get rid of the characters and make the file recognizable by python, do:    
            ```
            ~/Documents/Fan/code/mac2unix.pl /PATH/TO/MY/MAPPING_FILE.txt > /PATH/TO/MY/fixed_mapping_file.txt
            ```

    2. SeqFilters need tag file to be like this:   
        ```
        TCCCTTGTCTCC    DC1
        ACGAGACTGATT    DC2
        GCTGTACGGATT    DC3
        ATCACCAGGTGT    DC4
        TGGTCAACGATA    DC5
        ```

        1. You can parse the Argonne file into above format by:
            ```
            python ~/Documents/Fan/code/MiSeq_rdptool_map_parser.py ANL_MAPPING_FILE.txt > TAG_FILE.tag
            ```

        2. Due to the sequencing method ANL used, the tag sequences need to be reverse compilmented. And it's much easier to reverse compliment the parsed tag file than the index file (XXX_I1.fastq) 
            ```
            python ~/Documents/Fan/code/revcomp_rdp_format.py 16S_tag.txt > 16S_tag_rev.txt
            ```
        
        3. Then run SeqFilters to parse the I1.fastq to bin seq id into individual sample directories.       
            ```
            java -jar $SeqFilters --seq-file original/Undetermined_S0_L001_I1_001.fastq.gz --tag-file 16S_tag_rev.txt --outdir initial_process_Index_rev
            ```

            **Note:** to make sure tags were binning as expected, 
            1. I usually create a smaller file to test on.  
            2. Binning with the quality of the tag set as 0: `--min-qual 0`  
            3. The number of barcodes binned should add up to what's in the test file.   

    3. Use quality trimmed tag files to query assembled pair-ended sequences:   
        1. first, move *_trimmed.fasta from inidividual folders in result_dir to a new directory. I create a directory in `initial_process_Index`. In directory `initial_process_Index`   
            ```
            mkdir trimmed_tags
            mv result_dir/*/*_trimmed.fasta trimmed_tags/
            mv NoTag_trimmed.fasta ../result_dir/NoTag/  ##move notag file back.
            ```

        2. Now, binning. In direcotry `trimmed_tags`
            ```
            python ~/Documents/Fan/code/bin_reads.py ../../paired_end_assembled/assembled_reads_250-280.fastq
            ```
