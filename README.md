# pamlWrapper
Janet Young, Fred Hutchinson Cancer Center, April 2022

Starting with an in-frame alignment in fasta format, this repository has code that will run sitewise PAML using various evolutionary models and parse the output into tabular format.

This should work well, but if you find any problems, don't understand what's going on, or have suggestions for improvements, please talk to me, submit an issue using the github site, or email me.

There's an associated [docker image](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper) to help you run this on any computer, and a singularity version of that image stored on rhino/gizmo (see below).

I'm making these scripts public. Use them as you like, but please acknowledge me in any publication arising from their use, and it would make me happy if you let me know they were useful.

Default behaviour is to generate a tree from the alignment (using PHYML), but starting Nov 15, 2022, there is a `--usertree` option, allowing a user-specified tree as input for PAML.

If you find bugs/problems or see room for improvement, you can submit an issue via [github](https://github.com/jayoung/pamlWrapper) or you can just email me.

# Instructions

Input file(s): in-frame multiple sequence alignment(s), in fasta format

## To run these scripts on rhino/gizmo

Log in to rhino or gizmo (doesn't matter which), navigate to the folder where your alignment(s) are, and run this script, specifying your alignment(s) as input files:
```
cd ~/my/folder/with/alignments
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl myAln1.fa myAln2.fa
```

Depending on how your rhino/gizmo account is set up, you might even be able to run it using a simpler form of the command:
```
cd ~/my/folder/with/alignments
runPAML.pl myAln1.fa myAln2.fa
```
If you want to set up your account so you can use this simpler form, and don't know how to do it, talk to me.

Whichever way you do it, that command will start 'batch' jobs on the cluster, one for each input file. You can monitor whether your PAML job(s) are still running using the following command:
```
squeue -u $USER
```
This will list all the jobs you have running on the cluster. Any PAML jobs still running will show up with IDs starting `pw_` in the NAME column. The JOBID column shows a numerical job ID that can be useful: for example, if the JOBID is `55134218` you could cancel your job using this command: `scancel 55134218`. 

Once they've finished, they disappear from the output of the `squeue` command, and you can look in the output folders (called `myAln1.fa_phymlAndPAML`, etc) for the results.  Details of all the output files are given below, as well as what happens when this script runs. 

If anything went wrong, there should be useful error messages in the `myAln1.fa_runPAML.log.txt` file.  If it seems like it's not working, send me your alignment and this `log.txt` file and I'll try to troubleshoot.

There'll also be a second log file for each job, called something like `slurm-55131024.out` (the numerical JOBID is in the filename). Once in a while errors will show up in here. You can ignore warnings that look something like this:
```
WARNING: Bind mount '/home/jayoung => /home/jayoung' overlaps container CWD /home/jayoung/FH_fast_storage/paml_screen/pamlWrapperTestAlignments, may not be available
```
but please don't ignore any other warnings/errors you see in the `slurm-JOBID.out` file.  Email me with the input file and copy-paste the error you got.

## Script options

If you don't specify any additional options, the pipeline generates a tree to use as PAML input (using PHYML), and uses these options in PAML: codon model 2, starting omega 0.4, cleandata 0. 

To change the PAML options, use these options when calling runPAML.pl:
  - `--codon` (codon model) 
  - `--omega` (initial omega) 
  - `--clean` (cleandata)  

Example:
```
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=3 --omega=3 --clean=1 ACE2_primates_aln1_NT.fa
```

To **supply your own tree file** use the `--usertree=myTree.nwk` option (default is to generate a tree from the input alignment using PHYML). Treefile should be in newick format. The script expects that the sequence names match exactly between the alignment and the tree, and won't run PAML unless they do. If they don't match, it will provide a few hints on how to make a tree where names match.

Example:
```
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --usertree=primateTree.nwk ACE2_primates_aln1_NT.fa
```

## To run these scripts in other ways

The `runPAML.pl` script will only work on gizmo/rhino. Behind the scenes, it uses a singularity image file to run a pipeline of scripts inside a container using the Fred Hutch compute cluster via sbatch. 

Maybe you don't want to use the Fred Hutch computers (gizmo/rhino). Maybe you want to use individual scripts and modify them. Maybe you want to use Docker. See [here](docs/running_in_other_ways.md) for notes on how you might run it in other ways.


# What does runPAML.pl actually do? 

The pipeline performs the following steps on each input file (e.g. if the input file is called `myAln.fa`): 

- performs some basic checks on the alignment to make sure it's suitable for PAML (using script `pw_checkAlignmentBasics.pl`)
  - checks sequences are all the same length as each other - if not, we stop here and do not run PAML
  - checks alignment length is divisible by 3 - if not, we stop here and do not run PAML
  - checks the alignment does not include duplicate sequence names - if not, we stop here and do not run PAML

- performs another check, looking in each sequence for internal stop codons or frameshifting gaps. We issue warnings if we find any, but still proceed to PAML (using script `pw_checkAlignmentFrameshiftsStops.pl`)

- makes a subdir called `myAln.fa_phymlAndPAML` where we'll do all the work

- reformats the alignment for PHYML/PAML (the `myAln.fa.phy` file): 
  - converts from fasta format to a [format suitable for phyml and PAML](http://abacus.gene.ucl.ac.uk/software/pamlDOC.pdf)
  - replaces in-frame stop codons with gap codon (---) because PAML hates those
  - truncates long sequence names to 30 characters (long names caused trouble somewhere - I think in PHYML). Name translations are saved in `myAln.fa.aliases.txt`
  - removes odd characters from seqnames (e.g. `' : ( )`) - these can cause trouble

- if the user supplies a tree via the `--usertree` option, we use that (after checking that seqnames match up between the alignment and the tree). Otherwise we run PHYML to make a phylogenetic tree (details: we use the GTR nucleotide substitution model, we estimate the proportion of invariable sites, we estimate the shape of the gamma distribution, we estimate nucleotide freqs, we do not do any bootstrapping). See contents of the `myAln.fa_PHYMLtree` directory:
  - PHYML's output tree is `myAln.fa.phy_phyml_tree`
  - sometimes I want to see how those trees look, so I restore any seqnames I changed to their original names: `myAln.fa.phy_phyml_tree.names` 
  - and I use an R script to draw that tree: `myAln.fa.phy_phyml_tree.names.pdf` 
  - I also remove the branch lengths from that tree, to use in PAML: `myAln.fa.phy_phyml_tree.nolen` (I also have restore seqnames and draw that tree)
  - we copy `myAln.fa.phy_phyml_tree.nolen` to the main dir `myAln.fa_phymlAndPAML` to use in PAML

- runs sitewise PAML using that tree and alignment:
  - we run several models (0,0fixNeutral,1,2,7,8,8a). 
  - we use a single set of parameters (defaults are codon model=2, starting omega=0.4, cleandata=0, but these can be changed if desired)
  - each model gets run in a separate folder (e.g. `M8_initOmega0.4_codonModel2`). You'll see all PAML's output files there.

- uses script `pw_parsePAMLoutput.pl` to parse the output for all models into some tab-delimited tables:
  - makes two tab-delimited text files summarizing paml results (same results, different table format):
    - `*PAMLsummary.tsv` 'long format': each model gets a separate row in the file, so each input alignment file gets multiple rows. Easier for a human to read, not so good for downstream parsing, e.g. in R.
    - `*PAMLsummary.wide.tsv` 'wide format': each input alignment file gets a single row (actually, one row per set of parameter choices, see below in the 'robustness' section)
  - for M8, we also parse the `rst` output file to extract a tab-delimited table of the BEB results for each site (`rst.BEB.tsv` in the M8 subdirs)

- makes plots showing dN/dS class distributions for each model. Can be useful in understanding the results. `*.omegaDistributions.pdf`

- makes a reordered alignment file (seqs in same order as tree, useful for inspecting candidate sites of positive selection): `myAln.treeorder.fa`

- if there was evidence for positive selection in the M8vsM7 or M8vsM8a comparison, we make an annotated version of the alignment:`myAln.treeorder.annotBEBover0.9.fa`. This is the alignment with an additional line at the bottom, mostly gaps, but any codon with evidence for positive selection (with BEB>0.9) gets "BEB".   Some multiple alignment viewers will have a hard time reading this file - neither DNA or amino acid sequences should contain Bs, but my favorite alignment view can handle it - that's [seaview for Mac](http://doua.prabi.fr/software/seaview)

# Using the results

## To combine results for several alignments

Maybe we ran PAML on several input alignments, and we want to see the results for all of them in single file, in either the long format or wide:
```
pw_combinedParsedOutfilesLong.pl */*PAMLsummary.tsv
pw_combinedParsedOutfilesWide.pl */*PAMLsummary.wide.tsv
```
(if you get a 'command not found' error, put this in front of the script names above: `/fh/fast/malik_h/grp/malik_lab_shared/bin/`)

Output files are called `allAlignments.PAMLsummaries.tsv` or `allAlignments.PAMLsummaries.wide.tsv` - you probably want to rename them to something more informative, so they don't get overwritten next time you run the combining scripts.

## To check for robustness, if we did find evidence for positive selection

If we find evidence for positive selection, we might want to check that finding for robustness by running PAML with some different parameters. 

The default parameters I use for codeml are codon model 2, starting omega 0.4, cleandata 0. If we want to use different parameters we use the `--codon` (codon model) or `--omega` (initial omega) or `--clean` (cleandata) options. E.g.:
```
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=3 ACE2_primates_aln1_NT.fa
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=3 --omega=3 ACE2_primates_aln1_NT.fa
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=2 --omega=3 ACE2_primates_aln1_NT.fa
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --clean=1 --codon=3 ACE2_primates_aln1_NT.fa
```

If you are running the `pw_makeTreeAndRunPAML.pl` or `pw_makeTreeAndRunPAML_sbatchWrapper.pl` scripts instead, you can specify the same arguments to that script.

We would then combine the results as before, and see whether we had evidence for positive selection with all parameter choices.


# Some utility scripts

## pw_maskCpGsitesInAlignment.bioperl

CpG dinucleotides are hyper-mutagenic, via deamination of methylated cytosines. CpGs are often methylated in mammals (for example) but not Drosophila (for example).  PAML's evolutionary models do not account for this, and I fear that sometimes, weaker signals of positive selection are due to high rate of change at CpG-containing codons, rather than true positive selection.

An ad hoc and much too conservative way to address this is to remove from the alignment any codon that overlaps a CpG dinucleotide in any of the extant species. Often this results in a much shorter alignment. I run PAML on that alignment too: if I still see positive selection, I have additional confidence in the result.

Known problems with this script/approach:  
- I am not checking for CpG dinucleotides that are split by in-frame alignment gaps, and I really should be removing these, too.
- I am not checking for ancestral CpG dinucleotides that have mutated away in ALL extant sequences in the alignment

`pw_maskCpGsitesInAlignment.bioperl` is a utility script to mask CpGs in alignment:
```
pw_maskCpGsitesInAlignment.bioperl ACE2_primates_aln1_NT.fa  
```

## pw_annotateCpGsitesInAlignment.bioperl

Sometimes, rather than removing codons that overlap CpG dinucleotides, I simply want to see where they are in my alignment. This script annotates them. For a fasta format alignment, we add a fake sequence at the end that mostly comprises gaps, but uses NN to show where any of the extant sequences contain CpG.  

I will most often want to run this on the alignments where I've already annotated positively selected sites:  
```
pw_annotateCpGsitesInAlignment.pl ACE2_primates_aln1_NT.fa_phymlAndPAML/ACE2_primates_aln1_NT.treeorder.annotBEBover0.9.fa
```

## Shiny app

I also created a shiny app to help visualize sitewise (and branchwise) PAML results. The apps can be run [here](https://jyoungfhcrc.shinyapps.io/pamlApps/) and the underlying code is [here](https://github.com/jayoung/pamlApps) (R functions can also be used in a standalone way)

# PAML versions

[Here](docs/compare_PAML_versions.md) are some notes on how different the results from different PAML versions, e.g. paml4.9j / 4.9a / 4.8

# To do 

Add the ability to run only model 0 and model 0fixed on an alignment containing only 2 seqs.  Tree is meaningless, and PHYML fails when there's only two seqs. But I can make a fake tree `(seq1,seq2);` and PAML will work.

Troubleshooting the 'nan' problem in the BEB output:
- it seems to be happening with the conda-paml install (4.9a), but not the equivalent version of PAML I installed myself, or any other version of paml
- Ching-Ho's alignment that shows the problem is CG31882_sim.fa

## Maybe

Add the ability to run and parse:
- GARD
- FEL
- MEME

Docker container: could I use a newer version of R? Then I could make the plots look nicer. I would probably need to starting from a newer ubuntu base for that, and therefore I would need to install bioperl myself rather than using bioperl base. Or does another bioperl base exist that has a newer ubuntu starting point?

There are MORE RECENT versions of PAML on [github](https://github.com/abacus-gene/paml/releases). Update to 4.10.6?  (latest as of Nov 23 2022 - source code was posted Sept 24, 2021, executables were posted Nov 10, 2022)
