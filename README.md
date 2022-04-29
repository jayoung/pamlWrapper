# pamlWrapper
Janet Young, April 2022

Starting with an in-frame alignment, this repo has code that will run sitewise 
PAML using various evolutionary models and parse the output into tabular format.

This is work in progress. If you find any problems, or don't understand what's going on, talk to me, submit an issue using the github site, or email me.

My git repo is [here](https://github.com/jayoung/pamlWrapper).   

On my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`.  
On gizmo/rhino I'm working in `/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper`

There's an associated [docker image](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper) to help you run this on any computer, and a singularity version of that image stored on rhino/gizmo (see below).

# INSTALL

see below - instructions for using scripts with or without docker image.

# Instructions

Input file(s): in-frame multiple sequence alignment, in fasta format

Script names in this repo start `pw_` (for Paml Wrapper) to help distinguish them from any other similar scripts I have hanging around.

## To run sitewise paml on any fasta format in-frame alignment

Run it on each sequence file, one at a time
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa
```

or to run on several sequence files, one at a time. This can get slow - we'll probably want to use a wrapper script to run this in the cluster using `sbatch`.
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa ACE2_primates_aln1_NT.fa
```

If we're working on a compute cluster (like rhino/gizmo), we can use `sbatch` to start a whole bunch of PAML jobs running in parellel. This script will run the `pw_makeTreeAndRunPAML.pl` pipeline script on a bunch of alignments, sending off one sbatch job per input file.
```
pw_makeTreeAndRunPAML_sbatchWrapper.pl CENPA_primates_aln2a_NT.fa ACE2_primates_aln1_NT.fa
```
Use this command to see if your jobs are still running: `squeue -u $USER`

The `pw_makeTreeAndRunPAML.pl` script performs the following steps on each input file (e.g. if the input file is called `myAln.fa`): 

- makes a subdir called `myAln.fa_phymlAndPAML` 

- reformats the alignment for PHYML/PAML (in the `myAln.fa.phy` file): 
  - replace in-frame stop codons (PAML hates those) with gap codon (---)
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

Output files are called `allAlignments.PAMLsummaries.tsv` or `allAlignments.PAMLsummaries.wide.tsv` - you probably want to rename them to something more informative, so they don't get overwritten next time you run the combining scripts.

## To check for robustness, if we did find evidence for positive selection

If we find evidence for positive selection, we might want to check that finding for robustness by running PAML with some different parameters. 

The default parameters I use for codeml are codon model 2, starting omega 0.4, cleandata 0. If we want to use different parameters we use the `--codon` (codon model) or `--omega` (initial omega) options. E.g.:
```
pw_makeTreeAndRunPAML.pl --codon=3 ACE2_primates_aln1_NT.fa
pw_makeTreeAndRunPAML.pl --codon=3 --omega=3 ACE2_primates_aln1_NT.fa
pw_makeTreeAndRunPAML.pl --codon=2 --omega=3 ACE2_primates_aln1_NT.fa
```

We would then combine the results as before, and see whether we had evidence for positive selection with all parameter choices.


# To run these scripts on rhino/gizmo

Log in to rhino or gizmo (doesn't matter which), navigate to the folder where your alignments are and run this script:
```
cd ~/my/folder/with/alignments
/fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl myAln1.fa myAln2.fa
```
This will start a 'batch' job on the cluster. Monitor whether this job is running using the following command:
```
squeue -u $USER
```
This will list all the jobs you have running on the cluster. Any PAML jobs still running will show up with IDs starting `pw_` in the NAME column.


# To run these scripts with docker

My docker image is [here](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper)

There's a singularity file version of that on rhino/gizmo `/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.3.sif` (check the version number!  README might not list the most recent version).  I use it like this (this is exactly what the `runPAML.pl` script listed above does, except wrapping it for sbatch):
```
module load Singularity/3.5.3
singularity exec --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.3.sif pw_makeTreeAndRunPAML.pl myAln.fa > myAln.fa_runPAMLwrapper.log.txt
module purge
```


## Docker: detailed explanation

A **docker container** is a bit like a mini-computer inside the computer we're actually working on. This mini-computer is where we will actually run PAML.  A **docker image** is a bunch of files stored in a hidden place on our computer that provide the setup for that mini-computer.

You first need to have docker and git installed on whichever computer you're working on. For example, see these [instructions to install on a mac](https://docs.docker.com/desktop/mac/install/). I think you might need to [create a docker account](https://docs.docker.com/docker-id/), too, in order to be able to use it. The free account is fine.

You can use various methods to manage and run your docker containers and images. The mac Docker app has some buttons to click, VScode has other ways, but here I'll describe the command line (Terminal) way to do it.

Once docker is installed and running, you'll download my docker image (called `paml_wrapper`) onto your computer. I do that from a terminal window (update the version tag with the most recent version listed [here](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper)):
```
docker pull jayoungfhcrc/paml_wrapper:version1.0.3
```
After that, the mini-computer is ready to use, and the image should stick around on your computer long-term. That means you will only need to do `docker pull` once, until I make updates, in which case you'll want to pull the docker image again so that you're using the latest version.

Now we're ready to use the mini-computer and run PAML. First, navigate to a folder on your big computer where one or more alignments can be found. E.g. 
```
cd /Users/jayoung/myData/myAlignments
```

To start up the mini-computer, and be able to see all the files in your current folder once you're inside the mini-computer:
```
docker run -v `pwd`:/workingDir -itd paml_wrapper
```
That starts the container (mini-computer) running, and creates a folder called `workingDir`, where you will see the files in your current folder. Any files created inside the mini-computer will also be visible from your main computer, in the folder you started from.  

To work inside the mini-computer, we first have to find its ID:
```
docker ps
```
You'll see something that looks a bit like this:
```
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
163df768287c   paml_wrapper   "/bin/bash"   3 seconds ago   Up 2 seconds             boring_pasteur
```
The container ID is in the first column (`163df768287c`).  Then we can use the following command to start working inside the mini-computer:
```
docker exec -it 163df768287c /bin/bash
```
Notice that the command-line prompt has changed - this helps track whether you're on the mini-computer, or your main computer.

On the mini-computer, the contents of the folder you were in on the big computer will be mounted to `/workingDir`, so the first thing we do is go into that folder and use `ls` to make sure we can see the files we expect:
```
cd workingDir
ls
```

Then we can use the scripts to run PAML, and the output will be shared between the mini-computer and your main computer. E.g. 
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa
```

There are also some example files provided within your mini-computer: 
- example input files: /pamlWrapper/testData 
- example output files: /pamlWrapper/testData/exampleOutput

Once we've finished our work, we can exit the mini-computer:
```
exit
```
We could re-enter the mini-computer if we want, using the same `docker exec` command we used before, but if we're really done, we probably want to tidy up by stopping/removing the container:
```
docker rm -f 163df768287c
```
The image will stick around, so next time you want to run PAML, you'd start from the `docker exec` step again to get a container running.


# To run these scripts WITHOUT docker/singularity

If you don't want to deal with installing software, look further down at the "using docker" instructions.

If you don't want to deal with docker, here are some notes to help you figure out how to get it running.  If you're working on gizmo/rhino, your environment MIGHT already be set up so that this can work. Talk to me to figure it out.

If you want to set it up yourself, you'll need to install some dependencies and make sure they're in your PATH:
```
phyml
codeml
R                 (on gizmo/rhino: module load fhR/4.1.2-foss-2020b)
ape package for R, if it's not already installed (it is installed in the fhR/4.1.2-foss-2020b module)
```
Perl modules (make sure PERL5LIB is set right):
```
Bioperl    (on gizmo/rhino: module load BioPerl/1.7.8-GCCcore-10.2.0)
  CPAN::Meta
  Cwd
  Getopt::Long
  Statistics::Distributions
```

You'll want to get my scripts locally and add `myInstallDir/pamlWrapper/scripts` to your PATH:
```
cd myInstallDir
git clone https://github.com/jayoung/pamlWrapper
```

You'll want to set the environmental variable `PAML_WRAPPER_HOME` to be wherever `myInstallDir/pamlWrapper` is. 

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

within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. 
