# Locations and paths

My git repo is [here](https://github.com/jayoung/pamlWrapper).   

On my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`.  
On gizmo/rhino I'm working in `/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper`

# The usual git updates:
```
git add --verbose --all .
git commit
git push
```

# Updating the docker image:

My mac has docker installed, gizmo/rhino do not. But I am keeping the master copy of the repo on gizmo/rhino.  

Before starting, make sure the pamlWrapper is synced to github, then:

On the mac, make sure we have the latest version of the pamlWrapper git repo:

```
cd /Users/jayoung/gitProjects/pamlWrapper
git pull
```

I also make sure the Mac docker app is running, and using the app, I sign in to my account.

Then we re-build the docker image
```
docker build -t paml_wrapper -f buildContainer/Dockerfile .
```
To get a shell for a quick look:
```
docker run -v `pwd`:/workingDir -it paml_wrapper
```


When I know it's working I add a new tag and push it to [docker hub](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper).  I update the version number each time:
```
docker tag paml_wrapper jayoungfhcrc/paml_wrapper:version1.1.0
docker push jayoungfhcrc/paml_wrapper:version1.1.0
```

I then test my container in a totally different environment using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work. Once I have an instance running there:
```
docker run -it jayoungfhcrc/paml_wrapper:version1.1.0
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```

I noticed (when I run on my Mac) that within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. I'm not going to worry about it.

# Convert docker image to singularity

On gizmo/rhino:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/buildContainer
module purge
module load Singularity/3.5.3
singularity build paml_wrapper-v1.1.0.sif docker://jayoungfhcrc/paml_wrapper:version1.1.0
module purge
```
A file called paml_wrapper-v1.1.0.sif appears. I want a copy of the singularity image file, and a script that uses it, in a more central place, for use by others:
```
cp paml_wrapper-v1.1.0.sif /fh/fast/malik_h/grp/malik_lab_shared/singularityImages
```
If I want to retest before I change the version used by others
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/testData

# test, making a gene tree
../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl CENPA_primates_aln2a_only5seqs.fa

# test, supplying a tree via --usertree option
../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree CENPA_primates_aln2a_only5seqs.fa

# test, supplying a tree with non-matching seqnames via --usertree option
../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa

```


Then, when I'm sure it's working, update the version used by others:

```
cp ../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl
```

I can get a shell in the singularity container like this:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
module load Singularity/3.5.3
singularity shell --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif
module purge
```

And within the shell, this works:
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
```

Or, I can run some code using the singularity image without entering a shell (the `pw_makeTreeAndRunPAML_singularityWrapper.pl` script (same as `runPAML.pl`) does this for each alignment):
```
module load Singularity/3.5.3
singularity exec --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
module purge
```

Test the new singularity container, on rhino/gizmo:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
runPAML.pl CENPA_primates_aln2a_NT.fa
runPAML.pl --codon=2 --omega=3 CENPA_primates_aln2a_NT.fa
runPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree CENPA_primates_aln2a_only5seqs.fa
```


# Testing a new feature - allow user-supplied tree

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testUserTree

## an example where the seqnames and the tree names DO match up:
pw_makeTreeAndRunPAML.pl --usertree=Dmel22genome_tree.nwk Dmel_22_aln.fasta
    # works

## an example where the seqnames and the tree names DO NOT match up:
pw_makeTreeAndRunPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
    # stops before it gets to running PAML - good.
# via sbatch wrapper:
pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
   # stops before it gets to running PAML - good. (it does go through sbatch to do it - that's OK)
## example of how I would fix up the tree file
# created CENPA_primates_aln2a_only5seqs.userTreeNameTable.txt via minimal edits from the file produced by checkSeqs. Then I fix the names:
../../pamlWrapper/scripts/pw_changenamesinphyliptreefile.pl CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.userTreeNameTable.txt 
# rerun after fixing names in tree - it works
pw_makeTreeAndRunPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames.names CENPA_primates_aln2a_only5seqs.fa 
# via sbatch wrapper:
pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
```


# How to parse PAML after running