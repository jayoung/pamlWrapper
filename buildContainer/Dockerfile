FROM continuumio/miniconda3:4.10.3

### install R (default version is OLD - 3.5.2), but I don't care. 
# I only use R+ape for some very simple plots.
# install the ape R package (v5.6-2)
RUN apt-get update && \
    apt-get install -y r-base
RUN R -e "install.packages('ape',dependencies=TRUE, repos='http://cran.rstudio.com/')"

### install the other stuff
RUN conda install phyml --channel bioconda
RUN conda install paml --channel bioconda
RUN conda install perl-bioperl --channel bioconda


##### Notes:

# build: "docker build -t paml_wrapper ."
# start a shell: "docker run -v `pwd`:/testData2 -it paml_wrapper"

### From that shell:
# which phyml, which codeml, and playing with R all seem to work.
# "uname -a" output: 
# Linux 67aff675bc0e 5.10.104-linuxkit #1 SMP Thu Mar 17 17:08:06 UTC 2022 x86_64 GNU/Linux


#### things I tried that didn't seem to work:
# I tried installing the ape package using conda: "RUN conda install r-ape" but when I tired to run some basic R stuff e.g. ?par within R I got bad errors: /opt/conda/lib/R/bin/pager: 11: exec: /usr/bin/less: not found

#### things I tried that I don't need any more:
## install wget: "RUN apt-get update && apt-get install wget -y"

###### alternative strategies:

##### 1. use "FROM R-base":  I could base my Docker image on a R base and I would get a newer version of R. Then I would need to install conda: I tried that but didn't finish troubleshooting

## trying to install conda the "bash Miniconda3-4.5.12-Linux-x86_64.sh" step wants a yes/no answer, so I would need to figure out how to run that non-interactively
# RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh'
# RUN bash Miniconda3-4.5.12-Linux-x86_64.sh


###### 2. Rasi's Dockerfiles use conda environments rather than conda install. Don't think I need to do that (?)


###### 3. installing R using conda.  Didn't finish troubleshooting this. One of the ways I tried to isntall R, it seemed like it worked during the build, but then I got errors when I tried to run R ("libreadline.so.6: cannot open shared object file: No such file or directory"). Tried installing readline6 as well, but I got errors about package conflicts (readline / python)
# RUN conda install readline=6.2 --channel conda-forge
# RUN conda install r-base

