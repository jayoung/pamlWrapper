# buildContainer folder

Goal: use Docker to provide a container where all my pamlWrapper scripts can run.

`Dockerfile` contains instructions to install a bunch of stuff using conda. 

I got it working in April 2022, using this base image: continuumio/miniconda3:4.10.3.  I chose that because it was what Rasi was using and it allows installs via conda. conda gets me paml 4.9a, which has a bug in the BEB. See the [issue](https://github.com/bioconda/bioconda-recipes/issues/38109) I filed describing the problem.  The PAML bug is discussed [here](https://groups.google.com/g/pamlsoftware/c/HXxqYBHYbRU/m/lLwe1V4CAwAJ).

In Nov 2022 I decided I wanted a newer version of PAML so I needed to rebuild the docker image. I wanted to install PAML from scratch rather than using conda.   Even without PAML, I now had trouble installing bioperl using conda.  I decided to abandon the miniconda base, and use a Bioperl base image for my docker container ("bioperl/bioperl:release-1-6-924").   I think I have it working.

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
