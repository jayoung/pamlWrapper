#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

### checks whether output exists already, and if not, it runs pw_makeTreeAndRunPAML.pl

## we will check for existing PAML output run using these parameters

## set up defaults:
my $initialOrFixedOmega = 0.4;
my $codonFreqModel = 2;
my $walltime = "1-0";   # if we do use sbatch, default walltime is 1 days
my $cleanData = 0;
my $addToExistingOutputDir = ""; ## default is that I will NOT add to existing output dir

GetOptions("omega=f" => \$initialOrFixedOmega,   ## sometimes I do 3, default is 0.4
           "codon=i" => \$codonFreqModel,        ## sometimes I do 3, default is 2
           "clean=i" => \$cleanData,             ## sometimes I do 1 to remove the sites with gaps in any species
           "walltime=s"  => \$walltime,
           "add"     => \$addToExistingOutputDir) or die "\n\nterminating - unknown option(s) specified on command line\n\n";             
                      ## '--wall 0-6' to specify 6 hrs


#### I don't usually change these things:
my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 
my $jobnamePrefix = "pw_";   

print "\nrunning PAML with these parameters:\n    starting omega $initialOrFixedOmega\n    codon model $codonFreqModel\n    cleandata $cleanData\n\n";

##################

foreach my $file (@ARGV) {
    if (!-e $file) { die "\n\nterminating - file $file does not exist\n\n";}
    print "\n####### Working on file $file\n";
    ## I used to always check for the top level outdir.
    # now I still do it by default, but I can override by including --add on the command line (because I might want to run PAML again with different parameters)
    my $outdir = $file . "_phymlAndPAML";
    if (!$addToExistingOutputDir) {
        if (-e $outdir) {
            print "    SKIPPING this file - output directory $outdir exists already.\n";
            print "    Include --add on the command line to override this check, for example if you want to run using a different set of parameters and add results to the existing directory\n";
            print "    If you want to get rid of previous results and re-run PAML, do this: rm -r $outdir\n";
            next;
        }
    }
    ## run pw_makeTreeAndRunPAML.pl using sbatch (pass through the parameters)
    my $command = "$masterPipelineDir/scripts/pw_makeTreeAndRunPAML.pl --omega $initialOrFixedOmega --codon $codonFreqModel --clean $cleanData $file >> $file.phymlAndPAML.log.txt";
    $command = "/bin/bash -c \\\"source /app/lmod/lmod/init/profile; module load fhR/4.1.2-foss-2020b ; $command\\\"";
    $command = "sbatch -t $walltime --job-name=$jobnamePrefix"."$file --wrap=\"$command\"";
    system($command);
}
