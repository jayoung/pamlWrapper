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
my $userTreeFile = "";
my $addToExistingOutputDir = ""; ## default is that I will NOT add to existing output dir
my $strictness = "strict";    ## 'strict' means we insist that 'Time used' will be present at the end of the mlc file, and if it's not we assume PAML failed.   'loose' means it's OK if that's not present (v4.10.6 doesn't always add it)
my $codemlExe = "codeml";  ## default is whichever codeml is in the PATH
my $verboseTable = 0;   ## normally we do NOT output all the parameters for all the models, and we do NOT output site class dN/dS and freq unless a pairwise model comparison has a 'good' p-value, but sometimes for troubleshooting and comparing PAML versions we might want that.

my $scriptName = "pw_makeTreeAndRunPAML_sbatchWrapper.pl";

GetOptions("omega=f"        => \$initialOrFixedOmega,   ## sometimes I do 3, default is 0.4
           "codon=i"        => \$codonFreqModel,        ## sometimes I do 3, default is 2
           "clean=i"        => \$cleanData,             ## sometimes I do 1 to remove sites with gaps in any species
           "verboseTable=i" => \$verboseTable,
           "usertree=s"     => \$userTreeFile,
           "walltime=s"     => \$walltime,
           "add=i"          => \$addToExistingOutputDir,
           "strict=s"       => \$strictness,
           "codeml=s"       => \$codemlExe) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";             
                      ## '--wall 0-6' to specify 6 hrs


#### I don't usually change these things:
my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 
my $jobnamePrefix = "pw_";   

print "\nrunning PAML with these parameters:\n    starting omega $initialOrFixedOmega\n    codon model $codonFreqModel\n    cleandata $cleanData\n\n";

##################

if ($userTreeFile ne "") {
    if (!-e $userTreeFile) {
        die "\n\nERROR - terminating in script $scriptName - you specified tree file $userTreeFile with the --usertree option, but that file does not exist\n\n";
    }
}

if (($strictness ne "strict") & ($strictness ne "loose")) {
    die "\n\nERROR - terminating in script $scriptName - the '--strict' option must be either 'strict' (default) or 'loose'\n\n";
}

## check the codeml executable exists
if ($codemlExe eq "codeml") {
    my $checkCodeml = `which codeml`;
    if ($checkCodeml eq "") {
        die "\n\nERROR - terminating in script $scriptName - codeml executable is not in PATH: $codemlExe\n\n";
    }
} else {
    if (!-e $codemlExe) {
        die "\n\nERROR - terminating in script $scriptName - you specified a custom codeml executable using the --codeml option, but that executable does not exist: $codemlExe\n\n";
    }
}
# some PAML versions don't add a tag to the end of the mlc file, so the way I had of checking for PAML success does not work, and I need to stop checking (i.e. use strict=loose)

if (($codemlExe =~ m/4\.9g/) || ($codemlExe =~ m/4\.10\.6/))   {
    if ($strictness eq "strict") {
        print "    WARNING - because you're using codeml v4.9g or v4.10.6 we are changing the 'strict' setting to 'loose' (i.e. we will not check the end of the mlc files to make sure codeml succeeded)\n\n";
    }
    $strictness = "loose";
}

foreach my $file (@ARGV) {
    if (!-e $file) { die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";}
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

    ### figure out log file name
    my $outfileStem = $file;
    $outfileStem .= ".codon$codonFreqModel";
    $outfileStem .= "_omega$initialOrFixedOmega";
    $outfileStem .= "_clean$cleanData";
    my $logFile = $outfileStem . "_runPAML.log.txt";

    ## run pw_makeTreeAndRunPAML.pl using sbatch (pass through the parameters)
    my $moreOptions = "";
    if ($userTreeFile ne "") { $moreOptions .= "--usertree=$userTreeFile"; }
    my $command = "$masterPipelineDir/scripts/pw_makeTreeAndRunPAML.pl $moreOptions --strict=$strictness --codeml=$codemlExe --omega $initialOrFixedOmega --codon $codonFreqModel --clean $cleanData --verboseTable=$verboseTable $file >> $logFile 2>&1"; 
    $command = "/bin/bash -c \\\"source /app/lmod/lmod/init/profile; module load fhR/4.1.2-foss-2020b ; $command\\\"";
    $command = "sbatch -t $walltime --job-name=$jobnamePrefix"."$file --wrap=\"$command\"";
    system($command);
}

