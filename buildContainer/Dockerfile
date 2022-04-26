FROM continuumio/miniconda3:4.10.3

### the slower things will go near the beginning, quicker things near the end (to make rebuilds quicker after any changes I make)

#### install build-essential (for gcc compiler) and autoconf (for autoreconf), both needed to compile phyml. I think build-essential includes wget
RUN apt-get update && apt-get install build-essential autoconf -y

### install R (default version is OLD - 3.5.2), but I don't care. 
# I only use R+ape for some very simple plots.
# install the ape R package (v5.6-2)
RUN apt-get update && \
    apt-get install -y r-base
RUN R -e "install.packages('ape',dependencies=TRUE, repos='http://cran.rstudio.com/')"

## install phyml from the tarball - current release. 
# We install phyml WITHOUT mpi support (we won't be bootstrapping, so don't need it). 
# I don't use the conda-bioconda version, because the current release of phyml seems to have conflicts with the base I am using for the docker image. An older release installed through bioconda seemed to install OK, but then it wouldn't run (just hung, with no error message)
RUN mkdir src
RUN mkdir src/phyml
RUN cd src/phyml && \
  wget https://github.com/stephaneguindon/phyml/archive/refs/tags/v3.3.20220408.tar.gz && \
  tar -xf v3.3.20220408.tar.gz && \
  cd phyml-3.3.20220408 && \
  sh ./autogen.sh && \
  autoreconf -i && \  
  ./configure --enable-mpi && \ 
  make && \ 
  make install

### install paml using conda
RUN conda install paml --channel bioconda

### install bioperl
# PERL5LIB does not seem to be set by the conda install, so I do that myself
RUN conda install perl-bioperl --channel bioconda
ENV PERL5LIB /opt/conda/pkgs/perl-bioperl-1.6.924-4/lib/perl5/site_perl/5.22.0/

### Install cpanm and some perl modules
RUN apt-get install -y cpanminus
RUN cpanm CPAN::Meta \
  Cwd \ 
  Getopt::Long \ 
  Statistics::Distributions

## Install my scripts and templates and docs from the local drive
RUN mkdir pamlWrapper
RUN --mount=type=bind,target=/src/pamlWrapper,source=. \
  cp -R /src/pamlWrapper /
RUN rmdir /src/pamlWrapper

## if there are any previous output files hanging around (e.g. in the top level of pamlWrapper/testData), remove them.  This keeps the output files I have in pamlWrapper/testData/exampleOutput
RUN find /pamlWrapper -maxdepth 2 -depth -name '*phymlAndPAML' -exec rm -rf {} +
RUN find /pamlWrapper -maxdepth 2 -depth -name 'allAlignments.PAMLsummaries*' -exec rm -rf {} +

### set an ENV to help me track the github repo home. Some of the scripts use this.
ENV PAML_WRAPPER_HOME /pamlWrapper/

### add to PATH
ENV PATH /pamlWrapper/scripts:$PATH

### what to DO in our container
CMD ["/bin/bash"]


##### Notes:

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

