# pamlWrapper
starting with an in-frame alignment, this repo has code that will run PAML's codeml (various models) and parse output

git repo is [here](https://github.com/jayoung/pamlWrapper) and on my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`  

Instructions are [here](docs/runPAMLandParse.md)

# to do

add a script that checks alignment and warns if things aren't the same length, or if there's a lot of stop codons or frameshifts

figure out how to run on the cluster using singularity, or just using sbatch if I'm in my usual environment? see older script `pw_makeTreeAndRunPAML_sbatchWrapper.pl` 

don't use CENPA_primates_aln2_NT.fa as a testData file, as it has a crappy marmoset seq. Can just remove marmoset

I want the omega plot files to named differently. Now: `omegaDistributions_initOmega0.4_codonModel2.pdf`. Should be `CENPA_primates_aln2_NT.codonModel2_initOmega0.4_cleandata0.omegaDistributions.pdf`

move more utility scripts should I move to this repo
- annotating the selected sites
- CpG mask, CpG annotate
- check for robustness
- GARD?
- any others??

within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. 

clone repo on rhino/gizmo, add the scripts dir to my PATH, and add the PAML_WRAPPER_HOME env