1. line count on `6_map_reads/uc/*.uc` should be the same as `1_quality_filtered/*.fasta`    
    ```
    grep -c ">" 1_quality_filtered/*.fasta
    wc -l 6_map_reads/uc/*.uc
    ```


