# pamlWrapper
starting with an in-frame alignment, this repo has code that will run PAML's codeml (various models) and parse output

My git repo is [here](https://github.com/jayoung/pamlWrapper) and on my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`  

Documentation on using my scripts is [here](docs/runPAMLandParse.md)

# to do

add a script to run before doing anything else that checks the input alignment and warns if things aren't the same length, or if there's a lot of stop codons or frameshifts

clone repo on rhino/gizmo, add the scripts dir to my PATH, and add the PAML_WRAPPER_HOME env

figure out how to run on the cluster using singularity, or simply using sbatch if I'm in my usual environment where everything will be in my PATH. see older script `pw_makeTreeAndRunPAML_sbatchWrapper.pl` 

move more utility scripts to this repo from the older repo (janet_pamlPipeline)
- annotating the selected sites
- CpG mask, CpG annotate
- check for robustness
- GARD?
- any others??

within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. 
