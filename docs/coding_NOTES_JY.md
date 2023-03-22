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



# Testing the --verbose=1 option 

added Feb 9, 2023

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testVerboseOutput/verbose0_sbatch
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl Mx1_PAML25.fasta.names Dmel_22_aln.fasta CENPA_primates_aln2a_NT.fa

cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testVerboseOutput/verbose1_sbatch
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verbose=1 Mx1_PAML25.fasta.names Dmel_22_aln.fasta CENPA_primates_aln2a_NT.fa
```


# Actually USING the scripts on my Mac (desktop), without using docker

I installed a few PAML versions (see /Users/jayoung/source_codes/paml/paml_MAC_installNOTES_JY.txt)

1. pull an up-to-date copy of the repo  
```
cd /Users/jayoung/gitProjects/pamlWrapper
git pull
```

2. fix permissions
because I'm not syncing permissions to github
```
pushd /Users/jayoung/gitProjects/pamlWrapper/scripts/
chmod u+x *l
popd
```

3. fix the shebang lines for all perl scripts so I use my Mac's preferred perl installation
```
pushd /Users/jayoung/gitProjects/pamlWrapper/scripts/
# mac needs -e (and makes a backup file called file-e)
sed -i -e 's/\/usr\/bin\/perl/\/usr\/bin\/env perl/' *.pl *.bioperl
rm *-e 
popd
```

It works if I supply the user tree, but I haven't worked through installing phyml, so I won't be able to run the whole thing:
```
cd /Users/jayoung/testPAMLversions/2023_Feb27/test_4.9a_mac

/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
```

