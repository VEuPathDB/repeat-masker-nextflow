# Nextflow Conversion of tRNAScanTask.pm

### Get Started
  * Install Nextflow
    
    `curl https://get.nextflow.io | bash`
  
  * Run the script
    
    `nextflow run VEuPathDB/tRNAScan -with-trace -c  <config_file> -r main`

###Decription of nextflow configuration parameters:
1. **inputFilePath**: Path to the input fasta file
2. **trimDangling**: 'true' or 'false', would you like to remove sections of masked repeats or not
3. **dangleMax**: Integer, number of nucleotides required between sections of repeats to stop removal process. 
  **Explained**: The trimDangling process will move through a masked sequence, once from the forward and once from the reverse directions, while looking for sections of 9 or more 'N's. dangleMax specifies the minimum number of nucleotides required to halt this process. Once this is done in the forward direction, it will begin in the reverse.
  **Example**:
          
          If dangleMax was set to 9...
          AAAAAANNNNNNNNNAAANNNNNNNNNAAAAAAAAANNNNNNNNNNNNAAAAAAAAAAAAAAANNNNNNAAAAAAAAANNNNNNNNNAAAAAANNNNNNNNNAAAAAA
            6       9     3     9         9       12            15          6       9       9       6       9      6
          
          After the forward pass ...
          AAAAAAAAANNNNNNNNNNNNAAAAAAAAAAAAAAANNNNNNAAAAAAAAANNNNNNNNNAAAAAANNNNNNNNNAAAAAA    
              9        12           15          6      9         9      6       9      6
          After the reverse pass...
          AAAAAAAAANNNNNNNNNNNNAAAAAAAAAAAAAAANNNNNNAAAAAAAAA
               9        12           15          6      9
4. **outputFileName**: How you would like the output file named
5. **outputDir**: Where you would the the output file to be stored
