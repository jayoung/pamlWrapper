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

### I WAS installing paml using conda 
# this installs paml version 4.9, March 2015
# there is a weird bug in that version, where the BEB algorithm sometimes returns nan values. Ching-Ho and Risa both had alignments where this bug was evident.  
RUN conda install paml --channel bioconda

### install bioperl
# PERL5LIB does not seem to be set by the conda install, so I do that myself
RUN conda install perl-bioperl --channel bioconda
# RUN conda install -c conda-forge -c bioconda -c defaults perl-bioperl=1.7.8
ENV PERL5LIB /opt/conda/pkgs/perl-bioperl-1.6.924-4/lib/perl5/site_perl/5.22.0/

### Install cpanm and some perl modules
RUN apt-get install -y cpanminus
RUN cpanm CPAN::Meta \
  Cwd \ 
  Getopt::Long \ 
  Statistics::Distributions

### but now I want to install paml from the source, a newer version
# paml version 4.9j, February 2020
# RUN mkdir src/paml
# RUN cd src/paml && \
#   wget http://abacus.gene.ucl.ac.uk/software/paml4.9j.tgz && \
#   tar -xf paml4.9j.tgz && \
#   cd paml4.9j/src && \
#   sed 's/CC = cc/CC = gcc/g' -i Makefile && \
#   make
  ## I add paml4.9j/src to PATH at the bottom so I don't need to move the executables
# did not work when I was installing PAML BEFORE perl-bioperl - failed at the conda install perl-bioperl  stage

## Install my scripts and templates and docs from the local drive
RUN mkdir pamlWrapper
RUN --mount=type=bind,target=/src/pamlWrapper,source=. \
  cp -R /src/pamlWrapper /
RUN rmdir /src/pamlWrapper
RUN chmod a+r -R pamlWrapper && \
  chmod a+x pamlWrapper/scripts/*

## if there are any previous output files hanging around (e.g. in the top level of pamlWrapper/testData), remove them.  This keeps the output files I have in pamlWrapper/testData/exampleOutput
RUN find /pamlWrapper -maxdepth 2 -depth -name '*phymlAndPAML' -exec rm -rf {} +
RUN find /pamlWrapper -maxdepth 2 -depth -name 'allAlignments.PAMLsummaries*' -exec rm -rf {} +

### set an ENV to help me track the github repo home. Some of the scripts use this.
ENV PAML_WRAPPER_HOME /pamlWrapper/

### add to PATH
ENV PATH /pamlWrapper/scripts:/src/paml/paml4.9j/src:$PATH

### what to DO in our container
# CMD ["/bin/bash"]

