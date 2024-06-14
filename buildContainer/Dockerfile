FROM bioperl/bioperl:release-1-6-924

# https://hub.docker.com/r/bioperl/bioperl
# At present, the base OS image is Ubuntu 14.04 (a.k.a. 'trusty'). This may change in the future, in particular if there is user demand, so please post on the issue tracker if you'd like to see other base OS images as well.
# R is NOT installed in the base image

# xx maybe try a new base: docker pull bioperl/bioperl:release-1-7-2
# xx not sure why I used 1-6-924

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
  make install && \
  rm ../v3.3.20220408.tar.gz

### Install some perl modules (cpanm is already in this base)
RUN cpanm CPAN::Meta \
  Cwd \
  Getopt::Long \
  Statistics::Distributions

### install paml from the source, version 4.9a, March 2015 (but don't add it to PATH)
RUN mkdir src/paml
RUN cd src/paml && \
  wget http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9a.tgz && \
  tar -xf paml4.9a.tgz && \
  cd paml4.9a/src && \
  sed 's/CC = cc/CC = gcc/g' -i Makefile && \
  make

### install paml from the source, version 4.9a, March 2015, use cc this time (but don't add it to PATH)
RUN mkdir src/paml_ccCompiled
RUN cd src/paml_ccCompiled && \
  cp /src/paml/paml4.9a.tgz . && \
  tar -xf paml4.9a.tgz && \
  cd paml4.9a/src && \
  sed 's/version 4.9/version 4.9a_cc/g' -i paml.h && \
  make && \
  rm ../../paml4.9a.tgz && \
  rm /src/paml/paml4.9a.tgz

### install paml from the source, version 4.9g, October 2017 (but don't add it to PATH)
# paml.h has the wrong version number
RUN cd src/paml && \
  wget http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9g.tgz && \
  tar -xf paml4.9g.tgz && \
  cd paml4.9g/src && \
  sed 's/CC = cc/CC = gcc/g' -i Makefile && \
  sed 's/version 4.9f/version 4.9g/g' -i paml.h && \
  make && \
  rm ../../paml4.9g.tgz

### install paml from the source, version 4.9h, March 2018 (but don't add it to PATH)
RUN cd src/paml && \
  wget http://abacus.gene.ucl.ac.uk/software/SoftOld/paml4.9h.tgz && \
  tar -xf paml4.9h.tgz && \
  cd paml4.9h/src && \
  sed 's/CC = cc/CC = gcc/g' -i Makefile && \
  make && \
  rm ../../paml4.9h.tgz

### install paml from the source, version 4.9j, February 2020
RUN cd src/paml && \
  wget http://abacus.gene.ucl.ac.uk/software/paml4.9j.tgz && \
  tar -xf paml4.9j.tgz && \
  cd paml4.9j/src && \
  sed 's/CC = cc/CC = gcc/g' -i Makefile && \
  make && \
  rm ../../paml4.9j.tgz
## I add paml4.9j/src to PATH at the bottom so I don't need to move the executables

### install paml v4.10.6 from the github repo, using the Dec 1 2022 commit. I do NOT want to use the tarball found here https://github.com/abacus-gene/paml/archive/refs/tags/v4.10.6.tar.gz because it IS NOT really v4.10.6 - it is something older
# in order to get it to compile in this version of linux, I have to remove the  -Wmemset-elt-size flag from the CFLAGS given in the Makefile. If I understand right it won't make any difference to the compiled executable - just controls how many warnings are emitted during the complication
# If I don't remove that flag, the error I get is this: 
# cc: error: unrecognized command line option '-Wmemset-elt-size'
RUN cd src/paml && \
  wget https://github.com/abacus-gene/paml/archive/af30c375c35fe3bbb48464e5056f9fcf879d6b08.zip && \
  unzip af30c375c35fe3bbb48464e5056f9fcf879d6b08.zip && \
  mv paml-af30c375c35fe3bbb48464e5056f9fcf879d6b08 paml-github20221201 && \
  cd paml-github20221201/src && \
  sed 's/ -Wmemset-elt-size//g' -i Makefile && \
  make && \
  rm ../../af30c375c35fe3bbb48464e5056f9fcf879d6b08.zip

## Install my scripts and templates and docs from the local drive
RUN mkdir pamlWrapper
RUN --mount=type=bind,target=/src/pamlWrapper,source=. \
  cp -R /src/pamlWrapper /
## not sure why I had this in - commenting out, as it caused me trouble.
# RUN rmdir /src/pamlWrapper
RUN chmod a+r -R pamlWrapper && \
  chmod a+x pamlWrapper/scripts/*

## if there are any previous output files hanging around (e.g. in the top level of pamlWrapper/testData), remove them.  This keeps the output files I have in pamlWrapper/testData/exampleOutput
RUN find /pamlWrapper -maxdepth 2 -depth -name '*phymlAndPAML' -exec rm -rf {} +
RUN find /pamlWrapper -maxdepth 2 -depth -name 'allAlignments.PAMLsummaries*' -exec rm -rf {} +

### set an ENV to help me track the github repo home. Some of the scripts use this.
ENV PAML_WRAPPER_HOME /pamlWrapper/

### add 4.10.6 to PATH. The other versions will NOT be in the PATH but will be available if I want them
ENV PATH /pamlWrapper/scripts:/src/paml/paml-github20221201/src:$PATH

### what to DO in our container
# CMD ["/bin/bash"]

