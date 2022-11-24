## Issues still to fix


## Fixes since v1.2.1


## paml_wrapper-v1.2.2

Nov 23 2022, commit xxx
- minor changes, mostly cosmetic. 
- continued comparing different PAML versions


## paml_wrapper-v1.2.1

Nov 23 2022, commit 33aa2c4
- added --strict=loose option so that I can parse output of paml v4.10.6, because it does NOT print the 'Time used' message for M2 and M8 (the models where BEB is run)

Nov 23 2022, commit d889f42
- now capturing elapsed time to the parsed output

Nov 23 2022, commit c1a9927
- add --codeml option so that we can specify a different codeml executable. Useful for testing different versions of PAML.  Not applicable when I'm running within singularity/docker: there I only installed a single version of PAML (currently 4.9j).

Nov 22 2022, commit 5f404a0
- now capturing PAML version in parsed output

Nov 22 2022, commit 41b5282
- now capturing tree file name in parsed output

## paml_wrapper-v1.2.0

Nov 22 2022, commit 2354751
- use PAML version 4.9j instead of 4.9a
- total rebuild of the Docker/singularity container using bioperl-Ubuntu-trusty as a base rather than the original miniconda base. Couldn't install bioperl any more using conda.  Wanted to rebuild so I could use PAML version 4.9j instead of 4.9a, and couldn't do that without also fixing the conda-bioperl problem

## paml_wrapper-v1.1.0

Nov 16 2022, commit c0f6507
- when using the `--usertree` option, we now check that the seqnames match up between the alignment and the tree, and offer some hints on what to do if they don't.

## paml_wrapper-v1.0.9   

Nov 15 2022, commit 2c3f9d0
- added `--usertree` option to allow use of a user-specified tree (e.g. known species tree) rather than the default behavior of creating a tree from the alignment.  For now I am not doing any checks on the tree, so there are ways this might break.

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