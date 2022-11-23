FROM continuumio/miniconda3:4.10.3

### the slower things will go near the beginning, quicker things near the end (to make rebuilds quicker after any changes I make)

#### install build-essential (for gcc compiler) and autoconf (for autoreconf), both needed to compile phyml. I think build-essential includes wget
RUN apt-get update && apt-get install build-essential autoconf -y


# these two lines are to try to help install XML::Parser. From https://superuser.com/questions/667981/error-while-installing-xmlparser-perl-module
# RUN apt-get update && apt-get install expat -y
# RUN apt-get update && apt-get install libexpat1-dev -y

# libssl is needed to install perl module XML::LibXML (which is needed for Bioperl)
# RUN apt-get update && apt-get install libssl-dev -y
#RUN apt-get update && apt-get install libxml2 -y
#RUN apt-get update && apt-get install libxml -y

### install bioperl
RUN conda install perl-bioperl-core --channel bioconda
    # failed. (with or without the "RUN apt-get update" line above)
# RUN conda install -c conda-forge -c bioconda -c defaults perl-bioperl=1.7.8
    # failed. (with or without the "RUN apt-get update" line above)


# ENV PERL5LIB /opt/conda/pkgs/perl-bioperl-1.6.924-4/lib/perl5/site_perl/5.22.0/


## 

### Install cpanm and some perl modules
# to check which perl modules I'm using via a direct load:
# grep -h  '^use ' *l | sort | uniq
# use Bio::AlignIO;
# use Bio::Seq;
# use Bio::SeqIO;
# use Bio::TreeIO;
# use IO::String;
# use POSIX qw/ceil/;
# use POSIX qw/floor/;

### errors with this:
# RUN apt-get install -y cpanminus
# RUN cpanm CPAN::Meta \
#     Bio::Seq
#8 279.4 ! Installing the dependencies failed: Module 'XML::Twig' is not installed, Module 'XML::Parser::PerlSAX' is not installed, Module 'XML::DOM' is not installed, Module 'XML::LibXML' is not installed, Module 'XML::LibXML::Reader' is not installed, Module 'IPC::Run' is not installed
#8 279.4 ! Bailing out the installation for BioPerl-1.7.8.
#8 279.4 60 distributions installed
# ------
# executor failed running [/bin/sh -c cpanm CPAN::Meta     Bio::Seq]: exit code: 1
# bsjanetmacmalik:onlyBioperl jayoung$ 


#### so try installing the XML things first

# # my first attempt to install Bio::Seq failed with errors about XML::Parse, so I figured out that install separately, and I'll keep it separate:
# RUN apt-get install -y cpanminus
# RUN cpanm CPAN::Meta
# RUN cpanm XML::Parser
# RUN cpanm --notest IPC::Run

# RUN cpanm Alien::Build

# RUN cpanm XML::LibXML

# Building and testing Net-SSLeay-1.92 ... FAIL
# ! Installing Net::SSLeay failed. See /root/.cpanm/work/1669075431.10883/build.log for details. Retry with --force to force install it.
# ! Installing the dependencies failed: Module 'Net::SSLeay' is not installed
# ! Bailing out the installation for IO-Socket-SSL-2.077.
# ! Installing the dependencies failed: Module 'IO::Socket::SSL' is not installed, Module 'Net::SSLeay' is not installed
# ! Bailing out the installation for Alien-Libxml2-0.19.
# ! Installing the dependencies failed: Module 'Alien::Libxml2' is not installed
# ! Bailing out the installation for XML-LibXML-2.0208.



## docker build -t test_bioperl -f ./Dockerfile .
## docker run -it test_bioperl /bin/bash

## IPC::Run has a test that fails when you're not building on a windows machine. It shouldn't even try to run it, but it does.  My workaround is to skip the tests for IPC::Run
# No such file or directory: getprotobyname('tcp') at t/win32_compile.t line 109.
# Compilation failed in require at t/win32_compile.t line 109.
# BEGIN failed--compilation aborted at t/win32_compile.t line 109.

# RUN cpanm --notest IPC::Run
    #IPC::Run

#10 48.65 Configuring IPC-Run-20220807.0 ... OK
#10 48.80 Building and testing IPC-Run-20220807.0 ... ! Installing IPC::Run failed. See /root/.cpanm/work/1669074372.6/build.log for details. Retry with --force to force install it.
#10 64.40 FAIL
#10 64.40 15 distributions installed



    # Bio::Seq

#8 297.0 ! Installing the dependencies failed: Module 'XML::LibXML' is not installed, Module 'XML::LibXML::Reader' is not installed, Module 'IPC::Run' is not installed
#8 297.0 ! Bailing out the installation for BioPerl-1.7.8.
#8 297.0 64 distributions installed

### I think I can ditch conda as the base image