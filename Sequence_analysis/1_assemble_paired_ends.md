Use RDP_assembler to assemble pair-ended sequences
=================

General rule:
----
1. Run assembler without restriction  
2. Look at your assembler stats (i.e., check the coverage length, sequence length, average  Q scores, etc.)
3. Rerun assembler for specific genes with specific parameters

Detailed procedures: 
----
1. First run with minimal constrants:   
    ```
    ~/RDP_Assembler/pandaseq/pandaseq -N -o 10 -e 25 -F -d rbfkms -f /PATH/TO/XXXXX_R1_001.fastq.gz -r /PATH/TO/XXXXX_R2_001.fastq.gz 1> assembled_reads.fastq 2> assembled_stats.txt
    ```

2. GO THROUGH assembled_stats.txt! When looking at the stat output: 
    1. Assemblage input paramenters are at the beginning of the file   
    2. Detailed assemblage stats are at the end of the file   
    3. The stat table headers starting from the 4th columns are:    

        | Seq ID | Seq length | Min Assembled Qscore | Errorsum / Length | Read Qscore (avg) | Bestoverlap Length | NATS (overlap goodness) | Overlap Start Position |   
        | ----- |:---:|:---:|:---:|:---:|:---:|:---:|:---:|    
        |MISEQ08:58:000000000-A6BH3:1:1101:17335:1742:AACAGGTTCGC | 299 | 27 | 0.0001785 | 37 |197 | 392.4 | 54|    

    4. You could analyze your assembled read stat file by:
        ```
        python ~/Documents/Fan/code/rdp_assem_stat_parser.py IGSB140210-1_assembled_stats.txt
        ```
 
        **NOTE:** You wil need to modify the python script for different parameters.

3. WHAT GENES ARE YOU WORKING WITH?    
    1. Metagenomes?    
        I would go with something slightly less than what the average overlap the stat file is calling for (e.g., avg overlap = 45, I would re-assemble everything with `-o 40`, and probably with no restriction to assembled read length).     

    2. 16S?    
        1. Which region?      
            As for **November, 2104**, ANL sequencing facility uses 515F-806R, which targets V4 region.      
        2. Which parameter is more important? Overlap or length? Or both?    
            16S SSU V4 region does not have much of a length variation. I would pay close attention to sequences that are shorter than 250b and longer than 280b. BLAST is a good tool for a quick check. Majority of sequences outside of the 250-280 range are eukaryotic. Some are bacterial but with high uncertainties. So in the case of V4, I would go with length over overlap. 

    3. ITS?    
        1. Which region?     
            As for **November, 2104**, ANL sequencing facility uses ITS1F-ITS2 for targetting fungal ITS1/2 region.     
        2. Which parameter is more important? Overlap or length? Or both?     
            Fungal ITS has a lot of variabilities in length. Very frequently, one would also find that some amplicons are shorter than the single end read (i.e., the average assembled reads are shorter than read length from either R1 or R2). Again, pay close attention to assembled sequences that are either really short or really long. Use BLAST and take your time. In my case, I used a minimal overlap of 80 and minimal merged length of 122. The large variations in fungal ITS regions requires a larger range to cover the broad taxonomy distribution.

3. Run assembler again with comfirmed parameters:   
    1. 16S   
        ```
        ~/RDP_Assembler/pandaseq/pandaseq -N -o 10 -e 25 -F -d rbfkms -l 250 -L 280 -f /PATH/TO/XXXXX_R1_001.fastq.gz -r /PATH/TO/XXXXX_R2_001.fastq.gz 1> assembled_reads_250-280.fastq 2> assembled_reads_stats_250-280.txt
        ```

    2. ITS    
        ```
        ~/RDP_Assembler/pandaseq/pandaseq -N -o 80 -e 25 -F -d rbfkms -l 122 -f /PATH/TO/XXXXX_R1_001.fastq.gz -r /PATH/TO/XXXXX_R2_001.fastq.gz 1> assembled_reads_o80_min122.fastq 2> assembled_reads_o80_min122_stats.txt
        ``` 

4. CHECK THE NUMBERS!   
    Make sure the number of good assembled sequence in assembled.fastq is the same as the OK number in stats.txt file   
        ```
        grep -c "@M0" IGSB140210-1_assembled_250-280.fastq  
        ```

