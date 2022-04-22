# pamlWrapper
starting with an in-frame alignment, this repo has code that will run PAML's codeml (various models) and parse output

[git repo](https://github.com/jayoung/pamlWrapper)

on my mac: `/Users/jayoung/gitProjects/pamlWrapper`  

# notes
many of the script names start `pw_` (for Paml Wrapper). This is to help distinguish the versions of scripts in this repo from any others I have hanging around in my PATH.

# to run via docker

You need to have docker and git installed on whichever computer you're working on.

Make a folder for your PAML runs. Maybe it's just today's PAML runs, maybe it's a master location for all your PAMLs.  Imagine this folder is called `~/myAlignments`.

Clone the git repo locally, within `~/myAlignments`
```
cd ~/myAlignments
gh repo clone jayoung/pamlWrapper
```

We build a docker image called `paml_wrapper` - I think of this as being like setting up a mini-computer inside the computer we're actually working on. This mini-computer is where we will actually run PAML.
```
cd pamlWrapper/buildContainer
docker build -t paml_wrapper .
```

We start up a docker container using that `paml_wrapper` image, and we mount our whole alignments folder (containing the cloned repo) so that we can see the scripts and the alignments from within the mini-computer. On the mini-computer, the alignments folder will be mounted to `/workingDir`
```
cd ~/myAlignments
docker run -v `pwd`:/workingDir -it paml_wrapper
```

Now we have a new command-line prompt within the mini-computer. You'll be in the root dir (`/`) of this computer when you first log in, and there should be a directory called `workingDir` that contains the entire contents of the directory you were in on your actual computer. If not, something is wrong.  The `workingDir` folder should contain a folder called `pamlWrapper` - that's the cloned git repo containing all my scripts: if not, something is wrong.
```
ls
cd workingDir
ls
ls pamlWrapper
```

# testing
```
cd /workingDir/pamlWrapper/testData

../scripts/pw_fasta2pamlformat.bioperl CENPA_primates_aln2_NT.fa.treeorder.small
phyml -i CENPA_primates_aln2_NT.fa.treeorder.small.phy --datatype nt --sequential 
    ### xxx this command works on exactly this input file on rhino/gizmo, but in my docker container it just hangs
phyml 
    ### works, shows version = PhyML 3.3.20190909     
    ### on rhino I am using PhyML 3.3.20200621  
    ### xxx I wonder if instead of using conda to install phyml I can compile from source?  I don't think it was difficult.  Or, the conda install is not working because I have the wrong FROM in my docker file?  Fundamentally I don't understand what conda installations are doing - is it a pre-compiled binary for a particular OS?                               

```

```
../scripts/pw_fasta2pamlformat.bioperl ACE2_primates_aln1_NT.fa
../scripts/pw_runPHYML.pl ACE2_primates_aln1_NT.fa.phy
```



# the usual git updates:
```
git add --verbose --all .
git commit
git push
```