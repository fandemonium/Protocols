1. RDP_assembler  
    ```
    ~/RDP_Assembler/pandaseq/pandaseq -N -o 40 -e 25 -F -d rbfkms -l 220 -L 280 -f Undetermined_S0_L001_R1_001.fastq.gz -r Undetermined_S0_L001_R2_001.fastq.gz 1> IGSB140210-1_assembled_o40.fastq 2> IGSB140210-1_assembled_stats_o40.txt
    ```
    
    1. make sure the number of good assembled sequence in assembled.fastq is the same as the OK number in stats.txt file
        ```
        grep -c "@M0" IGSB140210-1_assembled_o40.fastq  
        ```

