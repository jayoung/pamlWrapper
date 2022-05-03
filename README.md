# pamlWrapper
Janet Young, April 2022

Starting with an in-frame alignment in fasta format, this repo has code that will run sitewise PAML using various evolutionary models and parse the output into tabular format.

This is work in progress. If you find any problems, or don't understand what's going on, talk to me, submit an issue using the github site, or email me.

My git repo is [here](https://github.com/jayoung/pamlWrapper).   

On my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`.  
On gizmo/rhino I'm working in `/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper`

There's an associated [docker image](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper) to help you run this on any computer, and a singularity version of that image stored on rhino/gizmo (see below).

Individual script names in this repo start `pw_` (for Paml Wrapper) to help distinguish them from any other similar scripts I have hanging around.

# Instructions

Input file(s): in-frame multiple sequence alignment, in fasta format

## To run these scripts on rhino/gizmo

Log in to rhino or gizmo (doesn't matter which), navigate to the folder where your alignment(s) are and run this script, specifying your alignment(s) as input files:
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

Whichever way you do it, that command will start one 'batch' job on the cluster for each input file. Monitor whether your PAML job(s) are still running using the following command:
```
squeue -u $USER
```
This will list all the jobs you have running on the cluster. Any PAML jobs still running will show up with IDs starting `pw_` in the NAME column.

Once they've finished, you can look in the output folders (called `myAln1.fa_phymlAndPAML`, etc) for the results.  Details of all the output files are given below, as well as what happens when this script runs.

If anything went wrong, there should be useful error messages in the `myAln1.fa_runPAML.log.txt` file.  If it seems like it's not working, send me your alignment and this `log.txt` file and I'll try to troubleshoot.

## To run these scripts in other ways

Maybe you don't want to run on gizmo/rhino. Maybe you want to use individual scripts and modify them. Maybe you want to use Docker. See [here](docs/running_in_other_ways.md) for notes on how you might run it in other ways.


# What happens when it runs? 

The pipeline performs the following steps on each input file (e.g. if the input file is called `myAln.fa`): 

- makes a subdir called `myAln.fa_phymlAndPAML` 

- reformats the alignment for PHYML/PAML (the `myAln.fa.phy` file): 
  - replace in-frame stop codons with gap codon (---) because PAML hates those
  - truncates long sequence names to 30 characters (long names caused trouble somewhere - I think in PHYML). Name translations are saved in `myAln.fa.aliases.txt`
  - converts from fasta format to a [format suitable for phyml and PAML](http://abacus.gene.ucl.ac.uk/software/pamlDOC.pdf)

- runs phyml to make a phylogenetic tree (details: we use the GTR nucleotide substitution model, we estimate the proportion of invariable sites, we estimate the shape of the gamma distribution, we estimate nucleotide freqs, we do not do any bootstrapping). See contents of the `myAln.fa_PHYMLtree` directory:
  - PHYML's output tree is `myAln.fa.phy_phyml_tree`
  - sometimes I want to see how those trees look, so I restore any seqnames I changed to their original names: `myAln.fa.phy_phyml_tree.names` 
  - and I use an R script to draw that tree: `myAln.fa.phy_phyml_tree.names.pdf` 
  - I also remove the branch lengths from that tree, to use in PAML: `myAln.fa.phy_phyml_tree.nolen` (I also have restore seqnames and draw that tree)
  - we copy `myAln.fa.phy_phyml_tree.nolen` to the main dir `myAln.fa_phymlAndPAML` to use in PAML

- runs sitewise PAML using that tree and alignment:
  - we run several models (0,0fixNeutral,1,2,7,8,8a). 
  - we use a single set of parameters (defaults are codon model=2, starting omega=0.4, cleandata=0, but these can be changed if desired)
  - each model gets run in a separate folder (e.g. `M8_initOmega0.4_codonModel2`). You'll see all PAML's output files there.

- parses the output for all models into some tab-delimited tables:
  - makes two tab-delimited text files summarizing paml results (same results, different table format):
    - `*PAMLsummary.tsv` 'long format': each model gets a separate row in the file, so each input alignment file gets multiple rows. Easier for a human to read, not so good for downstream parsing, e.g. in R.
    - `*PAMLsummary.wide.tsv` 'wide format': each input alignment file gets a single row (actually, one row per set of parameter choices, see below in the 'robustness' section)
  - for M8, we also parse the `rst` output file to extract a tab-delimited table of the BEB results for each site (`rst.BEB.tsv` in the M8 subdirs)

- makes plots showing dN/dS class distributions for each model. Can be useful in understanding the results. `*.omegaDistributions.pdf`

- makes a reordered alignment file (seqs in same order as tree, useful for inspecting candidate sites of positive selection): `myAln.treeorder.fa`

- if there was evidence for positive selection in the M8vsM7 or M8vsM8a comparison, we make an annotated version of the alignment:`myAln.treeorder.annotBEBover0.9.fa`. This is the alignment with an additional line at the bottom, mostly gaps, but any codon with evidence for positive selection (with BEB>0.9) gets "BEB".   Some multiple alignment viewers will have a hard time reading this file - neither DNA or amino acid sequences should contain Bs, but my favorite alignment view can handle it - that's [seaview for Mac](http://doua.prabi.fr/software/seaview)

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

The default parameters I use for codeml are codon model 2, starting omega 0.4, cleandata 0. If we want to use different parameters we use the `--codon` (codon model) or `--omega` (initial omega) options. E.g.:
```
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=3 ACE2_primates_aln1_NT.fa
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=3 --omega=3 ACE2_primates_aln1_NT.fa
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl --codon=2 --omega=3 ACE2_primates_aln1_NT.fa
```

If you are running the `pw_makeTreeAndRunPAML.pl` or `pw_makeTreeAndRunPAML_sbatchWrapper.pl` scripts instead, you can specify the same arguments to that script.

We would then combine the results as before, and see whether we had evidence for positive selection with all parameter choices.


# Some other utility scripts I haven't yet put into this repo, but I will! 

Some of them could also be added to the pw_makeTreeAndRunPAML.pl pipeline - annotating selected sites, and parsing the rst file


## pw_annotateAlignmentWithSelectedSites.pl 
A utility script to add annotation for positively selected sites (has various command-line options)
```
scripts/pw_annotateAlignmentWithSelectedSites.pl *NT.fa_phymlAndPAML/*treeorder.annotateCpG.fa
```

## pw_parse_rst_getBEBandNEBresults.pl
A utility script to parse the rst file to get full BEB (and maybe NEB) results, and make annotation fasta files I can add to the alignment if I choose.  I also have R code to do this, in a [separate repo](https://github.com/jayoung/pamlApps)
```
scripts/pw_parse_rst_getBEBandNEBresults.pl *NT.fa_phymlAndPAML/M8_*/rst
```


## pw_maskCpGsitesInAlignment.bioperl
A utility script to mask CpGs in alignment:
```
scripts/pw_maskCpGsitesInAlignment.bioperl geneList1.txt_output/runPAML/*.fa  
```
I then run PHYML+PAML on the masked AND unmasked alignments - ideally I want to see signs of selection with BOTH.  For an input file called `SMARCB1_primates_aln2_NT.fa`  there will be two output files called  
- `SMARCB1_primates_aln2_NT.removeCpGinframe.fa`  
- `SMARCB1_primates_aln2_NT.maskCpGreport.txt`  

## pw_annotateCpGsitesInAlignment.bioperl
A utility script to make an annotated alignment, where we add a sequence line that shows where the CpG dinucleotides are. I will most likely want to run this on the alignments that are in tree order:  
```
scripts/pw_annotateCpGsitesInAlignment.bioperl *NT.fa_phymlAndPAML/*treeorder.fa
```

# To do list

add a script that runs before doing anything else to check the input alignment and warns if things aren't the same length, or if there's a lot of stop codons or frameshifts

move more utility scripts to this repo from the older repo (janet_pamlPipeline)
- the rst parse script - include that in the main pipeline too
- CpG mask, CpG annotate
- GARD?
- any others??

do I want to include the --add option and check in the runPAML.pl/pw_makeTreeAndRunPAML_singularityWrapper.pl script?  It should probably be consistent with the pw_makeTreeAndRunPAML_sbatchWrapper.pl script

within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. 
