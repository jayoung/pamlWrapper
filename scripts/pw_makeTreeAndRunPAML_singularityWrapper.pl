#!/usr/bin/perl
use warnings;
use strict;

###### for each alignment file, makes a shell script that will use the singularity image to run PAML, and launches that shell script using sbatch.

###### usage: runPAML.pl myAln1.fa myAln2.fa
### options:
# --omega=0.4  (starting omega)
# --codon=2    (codon model)
# --clean=0    (cleandata setting)
# --BEB=0.9    (BEB score threshold to report positively selected sites)

## the version of this script in /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl is a copy of the one here: https://github.com/jayoung/pamlWrapper/tree/main/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl


###### set up defaults for all the options
my %options;
$options{'sif'} = "/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.2.sif"; # singularity image file
$options{'walltime'} = "1-0"; ## walltime for sbatch jobs
$options{'job'} = "pw_";   
$options{'omega'} = 0.4;
$options{'codon'} = 2;
$options{'clean'} = 0;
$options{'usertree'} = "";
$options{'BEB'} = 0.9; ### report selected sites with at least this BEB probability into the output file
$options{'add'} = 0; ## a.k.a addToExistingOutputDir
$options{'codeml'} = "codeml";  ## default is whichever codeml is in the PATH
$options{'strict'} = "strict";    ## 'strict' means we insist that 'Time used' will be present at the end of the mlc file, and if it's not we assume PAML failed.   'loose' means it's OK if that's not present (v4.10.6 doesn't always add it)

### set up usage, including the default options
my $script = "runPAML.pl"; ## runPAML.pl is a copy of pw_makeTreeAndRunPAML_singularityWrapper.pl

my $usage = "Usage:\n$script myAln1.fa myAln2.fa\n";
$usage .= "    Options:\n";
$usage .= "        --omega=$options{'omega'} : starting omega for codeml\n"; 
$usage .= "        --codon=$options{'codon'} : codon model for codeml\n";
$usage .= "        --clean=$options{'clean'} : cleandata option for codeml\n";
$usage .= "        --usertree=$options{'usertree'} : the default behavior is to run PHYML to generate a tree from the alignment, but if we want to specify the input tree for PAML, we use this option\n";
$usage .= "        --BEB=$options{'BEB'} : BEB threshold for reporting positively selected sites\n";
$usage .= "        --add=$options{'add'} : if output directory for a previous PAML run exists, are we allowed to add output to it?\n";
$usage .= "        --walltime=$options{'walltime'} : how much time to request for each job\n";
$usage .= "        --job=$options{'job'} : prefix for sbatch job names\n";
$usage .= "        --sif=$options{'sif'} : name and location of singularity image file\n";

########## parse command line arguments
### I'll parse command-line args myself in this script, using base perl and avoiding Getopt::Long, because I want this script to have zero dependencies
my @commandLineOptions = grep /^--/, @ARGV;
my @files = grep !/^--/, @ARGV;

### parse the options, testing each
foreach my $commandLineOption (@commandLineOptions) {
    $commandLineOption =~ s/^--//;
    if ($commandLineOption !~ m/=/) {
        die "\n\nERROR - terminating in script $script - found a command line option that does not contain '=': that doesn't look right: $commandLineOption.\n\n$usage\n\n";
    }
    my @o = split /=/, $commandLineOption;
    if (!defined $options{$o[0]}) {
        die "\n\nERROR - terminating in script $script - found a command line option I don't recognize: $o[0].\n\n$usage\n\n";
    }
    if($o[0] eq "codeml") {
        die "\n\nERROR - terminating in script $script - you are trying to specify the codeml execuytable, but we cannot do that when using the singularity container. Maybe you want to use pw_makeTreeAndRunPAML_sbatchWrapper.pl instead - you can choose the codeml executable there.\n\n$usage\n\n";
    }
    $options{$o[0]} = $o[1];
}

# check remaining args - they should all be names of files that exist:
foreach my $alnFile (@files) {
    if (!-e $alnFile) {
        die "\n\nERROR - terminating in script $script - file $alnFile does not exist. It's possible you specified a file that doesn't exist, or it's possible you tried to specify a command line argument and got it slightly wrong.\n\n$usage\n\n";
    }
}

############# now do things

if (!-e $options{'sif'}) {
    die "\n\nERROR - terminating in script $script - singularity image file expected by the script does not exist: $options{'sif'}\n\n";
}

foreach my $alnFile (@files) {
    print "###### working on file $alnFile\n";
    my $alnFileStem = $alnFile; 
    
    # check for the top level outdir (can override by including --add on the command line, because I might want to run PAML again with different parameters)
    my $outdir = $alnFileStem . "_phymlAndPAML";
    if (!$options{'add'}) {
        if (-e $outdir) {
            print "    SKIPPING this file - output directory $outdir exists already.\n";
            print "    Include --add=1 on the command line to override this check, for example if you want to run using a different set of parameters and add results to the existing directory\n";
            print "    If you want to get rid of previous results and re-run PAML, do this: rm -r $outdir\n";
            next;
        }
    }

    ### first we make the shell file (figure out log file name at the same time)
    my $outfileStem = $alnFileStem;
    $outfileStem .= ".codon$options{'codon'}";
    $outfileStem .= "_omega$options{'omega'}";
    $outfileStem .= "_clean$options{'clean'}";

    my $shellFile = $outfileStem . "_runPAML.sh";
    my $logFile = $outfileStem . "_runPAML.log.txt";

    my $moreOptions = "";
    if ($options{'usertree'} ne "") { $moreOptions .= "--usertree=$options{'usertree'}"; }

    my $singularityCommand = "singularity exec --cleanenv $options{'sif'} pw_makeTreeAndRunPAML.pl $moreOptions --strict=$options{'strict'} --omega=$options{'omega'} --codon=$options{'codon'} --clean=$options{'clean'} --BEB=$options{'BEB'} $alnFile &>> $logFile";

    open (LOG, "> $logFile");
    print LOG "\n######## Running PAML wrapper within this singularity container:\n$options{'sif'}\n\n";
    print LOG "Passing the following command to the container:\n\n";
    print LOG "$singularityCommand\n\n";
    print LOG "Running on rhino/gizmo, sometimes we get a singularity-related error containing these words 'WARNING: Bind mount overlaps container CWD may not be available' but I think it's OK to ignore it.\n\n";
    print LOG "All following output comes from the singularity container, running pw_makeTreeAndRunPAML.pl.\n\n";
    close LOG;

    open (SH, "> $shellFile");
    print SH "#!/bin/bash\n";
    print SH "source /app/lmod/lmod/init/profile\n";
    print SH "module load Singularity/3.5.3\n";
    print SH "$singularityCommand\n";
    print SH "echo\n";
    print SH "module purge\n";
    close SH;
    ### then we set it running using sbatch
    my $command = "sbatch -t $options{'walltime'} --job-name=$options{'job'}"."$alnFile ./$shellFile";
    system($command);
}