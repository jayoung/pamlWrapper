### trying to just build phyml from scratch
FROM continuumio/miniconda3

#### install build-essential (for gcc compiler) and autoconf (for autoreconf). I think build-essential includes wget
RUN apt-get update && apt-get install build-essential autoconf -y

## install phyml from the tarball - current release. We install phyml WITHOUT mpi support (we won't be bootstrapping, so don't need it)
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

### what to DO in our container
CMD ["/bin/bash"]


### trying to force the correct version of libgcc-ng to be there. Didn't seem to work
# FROM continuumio/miniconda3
# RUN conda install libgcc-ng=9.3.0
# RUN conda install phyml=3.3.20200621 --channel bioconda

# ### install phyml - try not specifying the version of the miniconda3 base - maybe that was older/newer than it should have been
# FROM continuumio/miniconda3
# RUN conda install phyml=3.3.20200621 --channel bioconda


### install phyml - a more recent phyml has conflicts with the base we started off with, so we cannot install it
# FROM continuumio/miniconda3:4.10.3
# RUN conda install phyml=3.3.20200621 --channel bioconda


### install phyml - this combo gives us PhyML 3.3.20190909. Installs fine but doesn't run
# FROM continuumio/miniconda3:4.10.3
# RUN conda install phyml --channel bioconda


# build: "docker build -t just_phyml ."
# start a shell: "docker run -v `pwd`:/workingDir -it just_phyml"


###### the conflicts:
#6 28.02 Found conflicts! Looking for incompatible packages.
#6 28.02 This can take several minutes.  Press CTRL-C to abort.
#6 28.02 failed
#6 28.02 
#6 28.02 UnsatisfiableError: The following specifications were found to be incompatible with each other:
#6 28.02 
#6 28.02 Output in format: Requested package -> Available versions
#6 28.02 
#6 28.02 Package _libgcc_mutex conflicts for:
#6 28.02 phyml=3.3.20200621 -> libgcc-ng[version='>=9.3.0'] -> _libgcc_mutex[version='*|0.1',build=main]
#6 28.02 python=3.9 -> libgcc-ng[version='>=7.5.0'] -> _libgcc_mutex[version='*|0.1',build=main]
#6 28.02 
#6 28.02 Package libgcc-ng conflicts for:
#6 28.02 python=3.9 -> libgcc-ng[version='>=7.3.0|>=7.5.0']
#6 28.02 python=3.9 -> zlib[version='>=1.2.11,<1.3.0a0'] -> libgcc-ng[version='>=7.2.0']The following specifications were found to be incompatible with your system:
#6 28.02 
#6 28.02   - feature:/linux-64::__glibc==2.31=0
#6 28.02   - feature:|@/linux-64::__glibc==2.31=0
#6 28.02   - phyml=3.3.20200621 -> libgcc-ng[version='>=9.3.0'] -> __glibc[version='>=2.17']
#6 28.02 
#6 28.02 Your installed version is: 2.31