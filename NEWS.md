## Issues still to fix

## Fixes since v1.0.8


## paml_wrapper-v1.0.8   

Nov 1 2022, commit 974bf91

- fixed a bug in `pw_plottree.R` that messed up taxon names when making pdf plots of the trees (does not affect PAML output, only the tree plots)
- make the omega plots look a tiny bit nicer, and added clear indication on the plot that we're not showing the full range of omega in some cases
- changed a column header in the tsv outputs:  was 'seqToWhichSiteCoordsRefer', now 'seqToWhichAminoAcidsRefer'
- running via singularity wrapper now records container version number in the log.txt file

## paml_wrapper-v1.0.7    

May 31 2022, commit f9e4bad

has known bug in `pw_plottree.R` that messed up taxon names when making pdf plots of the trees. don't use tree pdf files!


## paml_wrapper-v1.0.6    

May 5 2022

## paml_wrapper-v1.0.5    

May 4 2022

## paml_wrapper-v1.0.4    

May 3 2022

## paml_wrapper-v1.0.3    

April 28 2022

## paml_wrapper-v1.0.2    

April 28 2022