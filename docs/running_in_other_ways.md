# General notes

Individual script names in this repo start `pw_` (for Paml Wrapper) to help distinguish them from any other similar scripts I have hanging around.

# To run these scripts WITHOUT docker/singularity

If you've installed the pipeline and dependencies yourself, or if you're running within the docker container, you do NOT need to use the `runPAML.pl` script (that's designed to use the singularity container and sbatch). 

Instead, you can call the script `pw_makeTreeAndRunPAML.pl` directly on several sequence files, and it will run on one file at a time. 
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa ACE2_primates_aln1_NT.fa
```
This can get slow, so we can run this on a compute cluster (like rhino/gizmo) using a wrapper script that calls `sbatch`. This script will run the `pw_makeTreeAndRunPAML.pl` pipeline script on a bunch of alignments, sending off one sbatch job per input file:
```
pw_makeTreeAndRunPAML_sbatchWrapper.pl CENPA_primates_aln2a_NT.fa ACE2_primates_aln1_NT.fa
```
Use this command to see if your jobs are still running: `squeue -u $USER`.  But on rhino/gizmo, usually I have people use the `runPAML.pl` script so that they use the singularity container, rather than running it in their own compute environment where the dependencies may or may not be installed (see the main [README.md doc](../README.md) for details).

# Installing the whole pipeline on your local machine WITHOUT docker/singularity
If you don't want to deal with installing software/perl modules, look further down at the "using docker" instructions.

If you don't want to deal with docker, here are some notes to help you figure out how to get it running. You'll need to install some dependencies and make sure they're in your PATH:
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

You'll want to get my scripts locally
```
cd myInstallDir
git clone https://github.com/jayoung/pamlWrapper
```
You'll also want to:
- add `myInstallDir/pamlWrapper/scripts` to your PATH
- set the environmental variable `PAML_WRAPPER_HOME` to wherever `myInstallDir/pamlWrapper` is. 

# To run these scripts using docker

My docker image is [here](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper)

There's a singularity file version of that on rhino/gizmo `/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.4.sif` (check the version number!  README might not list the most recent version).  I use it like this:
```
module load Singularity/3.5.3
singularity exec --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.4.sif pw_makeTreeAndRunPAML.pl myAln.fa > myAln.fa_runPAMLwrapper.log.txt
module purge
```
This is exactly what the `runPAML.pl` script listed above does, except we make a shell script for each input file and run that using sbatch.



## Docker: detailed explanation

A **docker container** is a bit like a mini-computer inside the computer we're actually working on. This mini-computer is where we will actually run PAML.  A **docker image** is a bunch of files stored in a hidden place on our computer that provide the setup for that mini-computer.

You first need to have docker and git installed on whichever computer you're working on. For example, see these [instructions to install on a mac](https://docs.docker.com/desktop/mac/install/). I think you might need to [create a docker account](https://docs.docker.com/docker-id/), too, in order to be able to use it. The free account is fine.

You can use various methods to manage and run your docker containers and images. The mac Docker app has some buttons to click, VScode has other ways, but here I'll describe the command line (Terminal) way to do it.

Once docker is installed and running, you'll download my docker image (called `paml_wrapper`) onto your computer. I do that from a terminal window (update the version tag with the most recent version listed [here](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper)):
```
docker pull jayoungfhcrc/paml_wrapper:version1.0.4
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



# Some individual scripts

These ARE run as part of the pipeline, but maybe sometimes you want to run them on their own.

## pw_annotateAlignmentWithSelectedSites.pl 
A utility script to add annotation for positively selected sites (has various command-line options)
```
pw_annotateAlignmentWithSelectedSites.pl *NT.fa_phymlAndPAML/*treeorder.annotateCpG.fa
```

## pw_parse_rst_getBEBtable.pl
A utility script to parse the rst file to get full BEB (and maybe NEB) results, and make annotation fasta files I can add to the alignment if I choose.  I also have R code to do this, in a [separate repo](https://github.com/jayoung/pamlApps)
```
pw_parse_rst_getBEBtable.pl *NT.fa_phymlAndPAML/M8_*/rst
```

