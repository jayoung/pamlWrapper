# buildContainer folder

Goal: use Docker to provide a container where all my pamlWrapper scripts can run.

`Dockerfile` contains instructions to install a bunch of stuff using conda. 

I got it working in April 2022, using this base image: continuumio/miniconda3:4.10.3.  I chose that because it was what Rasi was using and it allows installs via conda. conda gets me paml 4.9a, which has a bug in the BEB. See the [issue](https://github.com/bioconda/bioconda-recipes/issues/38109) I filed describing the problem.  The PAML bug is discussed [here](https://groups.google.com/g/pamlsoftware/c/HXxqYBHYbRU/m/lLwe1V4CAwAJ).

In Nov 2022 I decided I wanted a newer version of PAML so I needed to rebuild the docker image. I wanted to install PAML from scratch rather than using conda.   Even without PAML, I now had trouble installing bioperl using conda.  I decided to abandon the miniconda base, and use a Bioperl base image for my docker container ("bioperl/bioperl:release-1-6-924").   I think I have it working.

# Locations and paths

My git repo is [here](https://github.com/jayoung/pamlWrapper).   

On my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`.  
On gizmo/rhino I'm working in `/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper`



# Updating the docker image:

My mac has docker installed, gizmo/rhino do not. But I am keeping the master copy of the repo on gizmo/rhino.  

First, we make sure we're happy with the way the code is running, and make sure the latest code is commited to the git repo, either via VScode, or on the rhino/gizmo command line:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper
git add --verbose --all .
git commit
git push
```

Next, on the mac, we make sure we have the latest version of the pamlWrapper git repo:

The reason I do a fresh clone, rather than a pull, is because if I actually want to use the scripts on my mac I make a bunch of changes, but those are NOT changes I want to sync back to the repo. There's probably a way to get fancy and make a mac branch that merges the changes from main, but I'm not going to deal with that
```
cd /Users/jayoung/gitProjects/
rm -rf pamlWrapper
git clone https://github.com/jayoung/pamlWrapper.git
```

I also make sure the Mac docker app is running, and using the app, I sign in to my account.

Then we re-build the docker image
```
cd /Users/jayoung/gitProjects/pamlWrapper
docker build -t paml_wrapper -f buildContainer/Dockerfile .
```

To get a shell for a quick look:
```
docker run -v `pwd`:/workingDir -it paml_wrapper
```

Perhaps I run some standard tests, something like this:
```
# make sure I have all the necessary perl modules installed:
scripts/pw_testScript.bioperl 

# check other executables installed:
which codeml 
which phyml
which R
```

Perhaps I test running PAML
```
cd workingDir/
/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_only5seqs.fa
```

When I know it's working I add a new tag and push it to [docker hub](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper).  I update the version number each time:
```
docker tag paml_wrapper jayoungfhcrc/paml_wrapper:version1.3.7
docker push jayoungfhcrc/paml_wrapper:version1.3.7
```

I then test my container in a totally different environment using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work. Once I have an instance running there:
```
docker run -it jayoungfhcrc/paml_wrapper:version1.3.7
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```

I noticed (when I run on my Mac) that within the Docker container, the timestamps for files seems to be based on Europe time. That's weird. The timestamps look fine from outside the Docker container though. I probably don't care about that. I'm not going to worry about it.

# Convert docker image to singularity/apptainer

On gizmo/rhino:

I was previously using singularity (v3.5.3) to build the container for rhino/gizmo but now I use Apptainer (a direct replacement for singularity) - use v1.0.1 (Dan found some issues with a newer version of Apptainer)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/buildContainer
module purge
# module load Singularity/3.5.3
# singularity build paml_wrapper-v1.3.7.sif docker://jayoungfhcrc/paml_wrapper:version1.3.7

module load Apptainer/1.0.1
apptainer build paml_wrapper-v1.3.7.sif docker://jayoungfhcrc/paml_wrapper:version1.3.7

# singularity run --cleanenv paml_wrapper-v1.3.7.sif
module purge
```

Now that I use the bioperl base, I do get a bunch of warnings while building the apptainer image. I think I can ignore them. Examples (but there are MANY): 
```
2022/11/22 17:00:44  warn rootless{dev/agpgart} creating empty file in place of device 10:175
2022/11/22 17:00:44  warn rootless{dev/audio} creating empty file in place of device 14:4
2022/11/22 17:00:52  warn rootless{root/.cpanm/work/1468017244.5/Statistics-Descriptive-3.0612/t/pod.t} ignoring (usually) harmless EPERM on setxattr "user.rootlesscontainers"
```

A file called paml_wrapper-v1.3.7.sif appears. I want a copy of the singularity image file, and a script that uses it, in a more central place, for use by others:
```
cp paml_wrapper-v1.3.7.sif /fh/fast/malik_h/grp/malik_lab_shared/singularityImages
```


Perhaps retest the singularity container before I change the version used by others:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/testData

# test tiny alignment, making a tree from the alignment
../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl CENPA_primates_aln2a_only5seqs.fa


# using different codeml versions
mkdir v4.9g
cd v4.9g
cp ../CENPA_primates_aln2a_only5seqs.fa .
../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --version=4.9g CENPA_primates_aln2a_only5seqs.fa
    # paml4.9g gave core dump with M8, although all the outputs look correct except that screenoutput.txt is empty. Not sure what that core dump meant.

mkdir ../v4.9h
cd ../v4.9h
cp ../CENPA_primates_aln2a_only5seqs.fa .
../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --version=4.9h CENPA_primates_aln2a_only5seqs.fa

mkdir ../v4.9j
cd ../v4.9j
cp ../CENPA_primates_aln2a_only5seqs.fa .
../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --version=4.9j CENPA_primates_aln2a_only5seqs.fa

mkdir ../v4.9a
cd ../v4.9a
cp ../CENPA_primates_aln2a_only5seqs.fa .
../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --strict=loose --version=4.9a CENPA_primates_aln2a_only5seqs.fa

# test two real alignments, making trees 
cd ../
../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl  ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa

# test, supplying a tree via --usertree option
mkdir userTree
cd userTree
cp ../CENPA_primates_aln2a_only5seqs.fa.phy.usertree ../CENPA_primates_aln2a_only5seqs.fa .
../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree CENPA_primates_aln2a_only5seqs.fa

# test, supplying a tree with non-matching seqnames (should stop before running PAML) via --usertree option
cd ../
mkdir userTree_badTree
cd userTree_badTree
cp ../CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames ../CENPA_primates_aln2a_only5seqs.fa .

../../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa

```

Then, when I'm sure it's working, update `runPAML.pl` script (that's the one others are using):
```
cp ../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl
```

I can get a shell in the singularity/apptainer container like this:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
module load Apptainer/1.0.1
apptainer shell --cleanenv --bind $(pwd):/mnt -H /mnt /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.7.sif
module purge
```

To seeing which OS a container uses: `uname -a` works in a docker container, but in a singularity container it doesn't (well, it does, but it gives me the name of the host computer, not the container). Instead, from within a singularity container I can do `cat /etc/*-release`.   In paml_wrapper-v1.3.1.sif this gave me:
```
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=14.04
DISTRIB_CODENAME=trusty
DISTRIB_DESCRIPTION="Ubuntu 14.04.4 LTS"
NAME="Ubuntu"
VERSION="14.04.4 LTS, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 14.04.4 LTS"
VERSION_ID="14.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
```

And within the shell, this works:
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
```

Or, I can run some code using the singularity image without entering a shell (this is what the  `runPAML.pl=pw_makeTreeAndRunPAML_singularityWrapper.pl` script does for each alignment):
```
module load Apptainer/1.0.1
apptainer exec --cleanenv --bind $(pwd):/mnt -H /mnt /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.7.sif pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
module purge
```

Test the new container and wrapper, on rhino/gizmo:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
runPAML.pl CENPA_primates_aln2a_NT.fa
runPAML.pl --codon=2 --omega=3 CENPA_primates_aln2a_NT.fa
runPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree CENPA_primates_aln2a_only5seqs.fa
```

# Notes on making my Dockerfile
I export DOCKER_BUILDKIT in my ~/.profile file on my mac (needed for the "RUN --mount=type=bind" commands):
```
export DOCKER_BUILDKIT=1 
```

if I want to remove an existing container (perhaps before I rebuild the docker image):

```
docker ps -a ## to figure out container ID
docker rm -f 793368e0b770 ## replace with appropriate container ID
```

If I want to build my docker image: 
```
cd /Users/jayoung/gitProjects/pamlWrapper
docker build -t paml_wrapper -f buildContainer/Dockerfile .
```

If I want to run that image as a container, getting a shell, and mounting the current dir as workingDir: 
```
cd /Users/jayoung/gitProjects/alignments
docker run -v `pwd`:/workingDir -it paml_wrapper
```

I should then be able to run the code within the container, e.g. 
```
cd workingDir/testData
# one very small alignment
../scripts/pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_only5seqs.fa
# two bigger alignments
../scripts/pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa ACE2_primates_aln1_NT.fa
```

From that docker container shell:
`which phyml`, `which codeml`, and playing with R all seem to work.

`uname -a` output is this when I used the miniconda base:
```
Linux 67aff675bc0e 5.10.104-linuxkit #1 SMP Thu Mar 17 17:08:06 UTC 2022 x86_64 GNU/Linux
```

`uname -a` output is this when I used the bioperl/trusty base:
```
Linux bcd270568437 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

# things I tried when making my Dockerfile that I didn't pursue

Note that Rasi's Dockerfiles install into conda environments rather than the base install I'm doing via `conda install`. Don't think I need to do that (?). Here's one of [Rasi's Dockerfiles](https://github.com/rasilab/bottorff_2022/blob/main/Dockerfile) for reference.

## ape via conda
I tried installing the ape package using conda: 
```
RUN conda install r-ape
```
but when I tired to run some basic R stuff e.g. `?par` within R I got bad errors: 
```
/opt/conda/lib/R/bin/pager: 11: exec: /usr/bin/less: not found
```

## installing R via conda
Didn't finish troubleshooting this. One of the ways I tried to isntall R, it seemed like it worked during the build, but then I got errors when I tried to run R ("libreadline.so.6: cannot open shared object file: No such file or directory"). Tried installing readline6 as well, but I got errors about package conflicts (readline / python)
```
RUN conda install readline=6.2 --channel conda-forge
RUN conda install r-base
```

## use R-base
```
FROM R-base
```
I could base my Docker image on a R base and I would get a newer version of R. Then I would need to install conda: I tried that but didn't finish troubleshooting. Trying to install conda the "bash Miniconda3-4.5.12-Linux-x86_64.sh" step wants a yes/no answer, so I would need to figure out how to run that non-interactively
```
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh'
RUN bash Miniconda3-4.5.12-Linux-x86_64.sh
```

# things I tried that did work, but I don't need any more:
install wget: 
```
RUN apt-get update && apt-get install wget -y
```

# trying to update paml in Dockerfile to v4.9j

need to install from source if I want 4.9j

even if I don't have paml in Dockerfile AT ALL bioperl now fails to build.  I need to troubleshoot building bioperl.  I think it's trying to get some OTHER version of bioperl that I wasn't getting before?

```
 > [ 8/16] RUN conda install perl-bioperl --channel bioconda:                                                                           
#11 0.500 Collecting package metadata (current_repodata.json): ...working... done                                                       
#11 5.298 Solving environment: ...working... failed with initial frozen solve. Retrying with flexible solve.                            
#11 6.633 Solving environment: ...working... failed with repodata from current_repodata.json, will retry with next repodata source.     
#11 8.303 Collecting package metadata (repodata.json): ...working... done                                                               
#11 21.17 Solving environment: ...working... failed with initial frozen solve. Retrying with flexible solve.
                                                                                         
#11 34.21 Found conflicts! Looking for incompatible packages.
#11 34.21 This can take several minutes.  Press CTRL-C to abort.
#11 34.21 failed
#11 34.21 
#11 34.21 UnsatisfiableError: The following specifications were found to be incompatible with each other:
#11 34.21 
#11 34.21 Output in format: Requested package -> Available versions
#11 34.21 
#11 34.21 Package libgcc-ng conflicts for:
#11 34.21 python=3.9 -> zlib[version='>=1.2.11,<1.3.0a0'] -> libgcc-ng[version='>=7.2.0']
#11 34.21 python=3.9 -> libgcc-ng[version='>=11.2.0|>=7.5.0|>=7.3.0']
#11 34.21 perl-bioperl -> perl -> libgcc-ng[version='>=10.3.0|>=11.2.0|>=7.2.0|>=9.4.0']The following specifications were found to be incompatible with your system:
#11 34.21 
#11 34.21   - feature:/linux-64::__glibc==2.28=0
#11 34.21   - feature:|@/linux-64::__glibc==2.28=0
#11 34.21   - python=3.9 -> libgcc-ng[version='>=11.2.0'] -> __glibc[version='>=2.17']
#11 34.21 
#11 34.21 Your installed version is: 2.28
#11 34.21 
#11 34.21 
```


# Nov 21 2022, troubleshooting Docker build issues

can I get bioperl alone to install?  no

on the mac:
```
cd /Volumes/malik_h/user/jayoung/paml_screen/pamlWrapper/buildContainer/onlyBioperl
docker build -t test_bioperl -f ./Dockerfile .
```

# Nov 22, 2022

I switched to a totally different Docker base, and DO NOT use conda for anything

Uses PAML v4.9j
```
FROM bioperl/bioperl:release-1-6-924
```


# Feb 9, 2022

add more PAML versions to the docker image (options: 4.9a, 4.9g, 4.9h, 4.9j, 4.10.6), so that I can use it to run various versions

also added the --version option to pw_makeTreeAndRunPAML_singularityWrapper.pl so that it passes in the correct path to the codeml executable

http://abacus.gene.ucl.ac.uk/software/pamlOld.html

http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9a.tgz
http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9g.tgz
http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9h.tgz
http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9j.tgz


xxx test paml versions - do I get similar results inside and outside the container?
