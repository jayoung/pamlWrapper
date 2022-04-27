# Running PAML and parsing results

Input file(s): in-frame multiple sequence alignment, in fasta format

(script names start `pw_` (for Paml Wrapper) to help distinguish them from any other similar scripts I have hanging around)

## To run paml on any fasta format in-frame alignment

Run it on each sequence file, one at a time
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa
```

or to run on several sequence files, one at a time. This can get slow - we'll probably want to use a wrapper script to run this in the cluster using `sbatch`.
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
```

The `pw_makeTreeAndRunPAML.pl` script performs the following steps: 

- makes a subdir called `myAln.fa_phymlAndPAML` 

- reformats the alignment for PHYML/PAML (`myAln.fa.phy`): 
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
    - `*PAMLsummary.txt` 'long format': each model gets a separate row in the file, so each input alignment file gets multiple rows. Easier for a human to read, not so good for downstream parsing, e.g. in R.
    - `*PAMLsummary.wide.txt` 'wide format': each input alignment file gets a single row (actually, one row per set of parameter choices, see below in the 'robustness' section)
  - makes plots showing dN/dS class distributions for each model. Can be useful in understanding the results. `*.omegaDistributions.pdf`
  - makes a reordered alignment file (seqs in same order as tree, useful for inspecting candidate sites of positive selection): `myAln.treeorder.fa`

## Combining results for several alignments:


Maybe we ran PAML on several input alignments, and we want to see the results for all of them in single file, in either the long format or wide:
```
pw_combinedParsedOutfilesLong.pl */*PAMLsummary.txt
pw_combinedParsedOutfilesWide.pl */*PAMLsummary.wide.txt
```

## Checking for robustness

If we find evidence for positive selection, we might want to check that finding for robustness by running PAML with some different parameters. 

The default parameters I use for codeml are codon model 2, starting omega 0.4, cleandata 0. If we want to use different parameters we use the `--codon` (codon model) or `--omega` (initial omega) options. E.g.:
```
pw_makeTreeAndRunPAML.pl --codon=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
pw_makeTreeAndRunPAML.pl --codon=3 --omega=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
pw_makeTreeAndRunPAML.pl --codon=2 --omega=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
```

We would then combine the results as before, and see whether we had evidence for positive selection with all parameter choices.



# Some other utility scripts I haven't yet put into this repo, but I will! 

Some of them could also be added to the pipeline

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





# to run via docker

You first need to have docker and git installed on whichever computer you're working on. For example, [see instructions for a mac](https://docs.docker.com/desktop/mac/install/).

I think you might need to [create a docker account](https://docs.docker.com/docker-id/), too. The free account is fine.

Then you can pull my docker image (called `paml_wrapper`) onto your computer. From a terminal window:
```
docker pull jayoungfhcrc/paml_wrapper
```
A **docker container** is a bit like a mini-computer inside the computer we're actually working on. This mini-computer is where we will actually run PAML.  A **docker image** is a bunch of files stored in a hidden place on our computer that provide the setup for that mini-computer.

Once you've done that, the mini-computer is ready to use, and should stick around on your computer long-term (i.e. you will only need to do `docker pull` once, unless I update the image)

Now we're ready to use the mini-computer and run PAML.

First, navigate to a folder on your big computer where one or more alignments can be found. E.g. 
```
cd /Users/jayoung/myData/myAlignments
```

To start up the mini-computer, and share with it all the files in your current folder:
```
docker run -v `pwd`:/workingDir -itd paml_wrapper
```
That just starts the container (mini-computer) running. To work inside it, we first have to find its ID:
```
docker ps
```
You'll see something that looks a bit like this:
```
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
da1241898697   paml_wrapper   "/bin/bash"   3 seconds ago   Up 2 seconds             boring_pasteur
```
The container ID is in the first column (`da1241898697`).  Then we can use the following command to start working inside the mini-computer:
```
docker exec -it da1241898697 /bin/bash
```
Notice that the command-line prompt has changed - this helps track whether you're on the mini-computer, or your main computer.

On the mini-computer, the contents of the folder you were in on the big computer will be mounted to `/workingDir`, so the first thing we do is go into that folder and use `ls` to make sure we can see the files we expect:
```
cd workingDir
ls
```

Then we can use the scripts to run PAML, and the output will be shared between the mini-computer and your main computer. E.g. 
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa
```

There's also some example files provided within your mini-computer: example input files (/pamlWrapper/testData) and and example output (/pamlWrapper/testData/exampleOutput) 

Once we've finished our work, we can exit the mini-computer:
```
exit
```
We could re-enter the mini-computer if we want, using the same `docker exec` command we used before, but if we're really done, maybe we should tidy up by stopping/removing the container:
```
docker rm -f da1241898697
```
