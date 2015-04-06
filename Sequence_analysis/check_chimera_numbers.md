1. In directory `5_uchime_ref/good_otus`:    
    ```
    grep -c ">" *.fa > ../number_good.txt
    ```

2. In directory `5_uchime_ref/chimeras`:    
    ```
    grep -c ">" *.fa > ../number_chimera.txt
    ```

3. In direcotry `4_cluster_otus_0.985/otus`:   
    ```
    grep -c ">" *.fa > ../number_otu_denovo.txt
    ```

4. In directory `5_uchime_ref`:   
    ```
    python ~/Documents/Fan/code/check_chimera_numbers.py number_good_otus.txt number_chimera.txt ../4_cluster_otus_0.985/number_otu_denovo.txt
    ```

5. Output should be `{}`
