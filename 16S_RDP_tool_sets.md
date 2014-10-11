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
 
        Forward primer: `GGACTACHVGGGTWTCTAAT`

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

        2. Then run SeqFilters   
            ```
            java -jar $SeqFilters --forward-primers GGACTACHVGGGTWTCTAAT --max-forward 2 --keep-primer true --seq-file test.fastq --min-length 200 --tag-file test.tag --outdir initial_process
            ```
