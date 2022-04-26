# pamlWrapper
starting with an in-frame alignment, this repo has code that will run PAML's codeml (various models) and parse output

git repo is [here](https://github.com/jayoung/pamlWrapper) and on my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`  

# notes
Script names start `pw_` (for Paml Wrapper) to help distinguish them from any other similar scripts I have hanging around in my PATH.

# to run via docker

You need to have docker and git installed on whichever computer you're working on.

Make a folder for your PAML runs. Maybe it's just today's PAML runs, maybe it's a master location for all your PAMLs. Imagine this folder is called ~/myAlignments.

Copy the git repo (containing all my scripts) locally, within `~/myAlignments`
```
cd ~/myAlignments
gh repo clone jayoung/pamlWrapper
```

We build a docker image called `paml_wrapper` - I think of this as being like setting up a mini-computer inside the computer we're actually working on. This mini-computer is where we will actually run PAML.  The `build` command creates a docker image (sets up the computer's OS and saves that to a reusable file) and can be a bit slow the first time. The `run` command starts up a docker container (a running mini-computer) that will persist until we stop+remove it


In my case, my alignment data is actually in a folder WITHIN the git repo that contains example data, and it's called `/Users/jayoung/gitProjects/pamlWrapper/testData`.  So for me, the directory I'll mount inside the mini-computer is the same as the top-level of the git repo. I'm going to run the container in the background (-d option) so that I can easily come in and out of it.

```
cd pamlWrapper/buildContainer
docker build -t paml_wrapper .
cd /Users/jayoung/gitProjects
docker run -v `pwd`:/workingDir -itd paml_wrapper
## we get the container ID of the running container like this:
docker ps
```

We start up a docker container using that `paml_wrapper` image, and we mount our whole alignments folder (containing the cloned repo) so that we can see the scripts and the alignments from within the mini-computer. On the mini-computer, the alignments folder will be mounted to `/workingDir`
```
docker exec -it 200a5fc9e39e /bin/bash
```

And if we want to stop and remove a running container, we do this (again use `docker ps` to get the container ID):
```
docker rm -f 200a5fc9e39e
```

Now we have a new command-line prompt within the mini-computer. You'll be in the root dir (`/`) of this computer when you first log in, and there should be a directory called `workingDir` that contains the entire contents of the directory you were in on your actual computer. If not, something is wrong.  The `workingDir` folder should contain a folder called `pamlWrapper` - that's the cloned git repo containing all my scripts: if not, something is wrong.
```
ls
cd workingDir
ls
ls pamlWrapper
```

# testing

pw_makeTreeAndRunPAML.pl works!
```
cd /workingDir/pamlWrapper/testData
# run on individual alignments
../scripts/pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa
../scripts/pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa

# run on both alignments (using defaults: codon model 2, starting omega 0.4, cleandata 0)
../scripts/pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa

# run on both alignments, with alternative parameter choices (codon model 3, and/or starting omega 3):
../scripts/pw_makeTreeAndRunPAML.pl --codon=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
../scripts/pw_makeTreeAndRunPAML.pl --codon=3 --omega=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa
../scripts/pw_makeTreeAndRunPAML.pl --codon=2 --omega=3 CENPA_primates_aln2_NT.fa ACE2_primates_aln1_NT.fa

# if we ran it on several alignment files, and want a single long or wide output file for all:
../scripts/pw_combinedParsedOutfilesLong.pl */*PAMLsummary.txt
../scripts/pw_combinedParsedOutfilesWide.pl */*PAMLsummary.wide.txt

```

# to do

push docker image to some repo

figure out how to run on the cluster using singularity

update and complete documentation, including describing starting parameters

what other utility scripts should I move to this repo?
- annotating the selected sites
- CpG mask, CpG annotate
- check for robustness
- GARD?

within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though.

# the usual git updates:
```
git add --verbose --all .
git commit
git push
```