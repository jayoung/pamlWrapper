FROM bioperl/bioperl:release-1-6-924

# https://hub.docker.com/r/bioperl/bioperl
# At present, the base OS image is Ubuntu 14.04 (a.k.a. 'trusty'). This may change in the future, in particular if there is user demand, so please post on the issue tracker if you'd like to see other base OS images as well.
# R is NOT installed in the base image


### for testing:
# docker build -t paml_wrapper -f ./Dockerfile .
# docker run -it paml_wrapper /bin/bash  


#### install build-essential (for gcc compiler) and autoconf (for autoreconf), both needed to compile phyml. I think build-essential includes wget
RUN apt-get update && apt-get install build-essential autoconf wget -y


#### install R : this gets me v3.4.4 (OLD, but I don't care.)
# I suspect it's hard to install R 4.x on this base image
# I only use R+ape for some very simple plots.
# https://www.digitalocean.com/community/tutorials/how-to-set-up-r-on-ubuntu-14-04
RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add -
RUN apt-get update && apt-get install r-base -y
# install the ape R package (5.6-2)
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


### Install some perl modules (cpanm is already in this base)
RUN cpanm CPAN::Meta \
  Cwd \
  Getopt::Long \
  Statistics::Distributions


### install paml from the source, version 4.9j, February 2020
RUN mkdir src/paml
RUN cd src/paml && \
  wget http://abacus.gene.ucl.ac.uk/software/paml4.9j.tgz && \
  tar -xf paml4.9j.tgz && \
  cd paml4.9j/src && \
  sed 's/CC = cc/CC = gcc/g' -i Makefile && \
  make
## I add paml4.9j/src to PATH at the bottom so I don't need to move the executables

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

