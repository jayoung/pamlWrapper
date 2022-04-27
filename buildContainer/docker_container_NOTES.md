# buildContainer folder

Goal: use Docker to provide a container where all my pamlWrapper scripts can run.

`Dockerfile` contains instructions to install a bunch of stuff using conda. 

xxx

# Notes on making my Dockerfile
```
### this is in my ~/.profile file (needed for the "RUN --mount=type=bind" commands)
# export DOCKER_BUILDKIT=1 

### to remove an existing container (perhaps before I rebuild the docker image)
# docker ps -a ## to figure out container ID
# docker rm -f 793368e0b770 ## replace with appropriate container ID

### to build my docker image: 
# cd /Users/jayoung/gitProjects/pamlWrapper
# docker build -t paml_wrapper -f buildContainer/Dockerfile .

### to run that image as a container, getting a shell, and mounting the current dir as workingDir: 
# cd /Users/jayoung/gitProjects/alignments
# docker run -v `pwd`:/workingDir -it paml_wrapper

### should be able to now run the code within the container, e.g. 
# cd workingDir
# pw_makeTreeAndRunPAML.pl CENPA_primates_aln2_NT.fa 


### From that docker container shell:
# which phyml, which codeml, and playing with R all seem to work.
# "uname -a" output: 
# Linux 67aff675bc0e 5.10.104-linuxkit #1 SMP Thu Mar 17 17:08:06 UTC 2022 x86_64 GNU/Linux
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


## older detailed notes on using Docker

xxx see newer version of this in runPAMLandParse.md

Building my container seems to work fine on my work Mac:
```
cd /Users/jayoung/gitProjects/pamlWrapper/buildContainer
docker build -t paml_wrapper .
```
Test my docker image for vulnerabilities: not sure I really need to do this. It DOES find various problems, I think all with the base debian system. None are labeled 'critical'. See [here](https://docs.docker.com/get-started/09_image_best/). I think I'll just proceed.
```
docker scan paml_wrapper
```

show how the build layers were added:
```
docker image history paml_wrapper
```

Open a shell in that core:
```
docker run -it paml_wrapper
```

That gives me a new command line within the container. From there, I try some stuff, and I think I have it working:
```
which codeml
    /opt/conda/bin/codeml
which phyml
    /opt/conda/bin/phyml
phyml
R
```

Open a shell in that core, mounting a folder as a volume. This does create a folder called testData in the container but it does not pass in the file that's in testData

The local path must be an ABSOLUTE path for this to work right (at least on my mac)
```
docker run -v /Users/jayoung/gitProjects/pamlWrapper/buildContainer/testData:/testData2 -it paml_wrapper
```

or mount the entire current dir:
```
docker run -v `pwd`:/testData2 -it paml_wrapper
```
