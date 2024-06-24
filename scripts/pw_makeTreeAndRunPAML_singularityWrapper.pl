#!/usr/bin/perl
use warnings;
use strict;

###### for each alignment file, makes a shell script that will use the singularity/apptainer image to run PAML, and launches that shell script using sbatch.

# yes, this script has the word singularity in the name, butI now use the newer version of singularity, called apptainer

###### usage: runPAML.pl myAln1.fa myAln2.fa
### options:
# --omega=0.4  (starting omega)
# --codon=2    (codon model)
# --clean=0    (cleandata setting)
# --BEB=0.9    (BEB score threshold to report positively selected sites)

## the version of this script in /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl is a copy of the one here: https://github.com/jayoung/pamlWrapper/tree/main/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl


###### set up defaults for all the options
my %options;
$options{'sif'} = "/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.11.sif"; # singularity image file
$options{'walltime'} = "1-0"; ## walltime for sbatch jobs
$options{'job'} = "pw_";   
$options{'omega'} = 0.4;
$options{'codon'} = 2;
$options{'clean'} = 0;
$options{'smallDiff'} = ".5e-6"; ## .5e-6 was what I ALWAYS used before adding the option to change things, Feb 27, 2023. Ziheng recommends "use a value between 1e-6 and 1e-9", so this is OK
$options{'usertree'} = "";
$options{'BEB'} = 0.9; ### report selected sites with at least this BEB probability into the output file
$options{'verboseTable'} = 0; ## normally we do NOT output all the parameters for all the models, and we do NOT output site class dN/dS and freq unless a pairwise model comparison has a 'good' p-value, but sometimes for troubleshooting and comparing PAML versions we might want that.
$options{'add'} = 0; ## a.k.a addToExistingOutputDir
$options{'version'} = "4.10.6";
$options{'strict'} = "strict";    ## 'strict' means we insist that 'Time used' will be present at the end of the mlc file, and if it's not we assume PAML failed.   'loose' means it's OK if that's not present (v4.10.6 doesn't always add it)

### set up usage, including the default options
my $script = "runPAML.pl"; ## runPAML.pl is a copy of pw_makeTreeAndRunPAML_singularityWrapper.pl

my $usage = "Usage:\n$script myAln1.fa myAln2.fa\n";
$usage .= "    Options:\n";
$usage .= "        --omega=$options{'omega'} : starting omega for codeml\n"; 
$usage .= "        --codon=$options{'codon'} : codon model for codeml\n";
$usage .= "        --clean=$options{'clean'} : cleandata option for codeml\n";
$usage .= "        --smallDiff=$options{'smallDiff'} : smallDiff option for codeml\n";
$usage .= "        --usertree=$options{'usertree'} : the default behavior is to run PHYML to generate a tree from the alignment, but if we want to specify the input tree for PAML, we use this option\n";
$usage .= "        --BEB=$options{'BEB'} : BEB threshold for reporting positively selected sites\n";
$usage .= "        --verboseTable=$options{'verboseTable'} : ## normally we do NOT output all the parameters for all the models, and we do NOT output site class dN/dS and freq unless a pairwise model comparison has a 'good' p-value, but sometimes for troubleshooting and comparing PAML versions we might want that\n";
$usage .= "        --add=$options{'add'} : if output directory for a previous PAML run exists, are we allowed to add output to it?\n";
$usage .= "        --version=$options{'version'} : which version of codeml do we want to run? (options: 4.9a, 4.9a_cc, 4.9g, 4.9h, 4.9j, 4.10.6, 4.10.6cc)\n";
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
        die "\n\nERROR - terminating in script $script - you are trying to specify the codeml executable, but we cannot do that when using the singularity container. Maybe you want to use pw_makeTreeAndRunPAML_sbatchWrapper.pl instead - you can choose the codeml executable there.\n\n$usage\n\n";
    }
    $options{$o[0]} = $o[1];
}

# check remaining args - they should all be names of files that exist:
foreach my $alnFile (@files) {
    if (!-e $alnFile) {
        die "\n\nERROR - terminating in script $script - file $alnFile does not exist. It's possible you specified a file that doesn't exist, or it's possible you tried to specify a command line argument and got it slightly wrong.\n\n$usage\n\n";
    }
}

#### get path to the codeml executable within the container
# 4.9a, 4.9g, 4.9h, 4.9j, 4.10.6
$options{'codemlExe'} = "undefinedSoFar";  
if ($options{'version'} eq "4.9a") { 
    $options{'codemlExe'} = "/src/paml/paml4.9a/src/codeml";
}
if ($options{'version'} eq "4.9a_cc") { 
    $options{'codemlExe'} = "/src/paml_ccCompiled/paml4.9a/src/codeml";
}
if ($options{'version'} eq "4.9g") { 
    $options{'codemlExe'} = "/src/paml/paml4.9g/src/codeml";
}
if ($options{'version'} eq "4.9h") { 
    $options{'codemlExe'} = "/src/paml/paml4.9h/src/codeml";
}
if ($options{'version'} eq "4.9j") { 
    $options{'codemlExe'} = "/src/paml/paml4.9j/src/codeml";
}
# if ($options{'version'} eq "4.10.6") { 
#     $options{'codemlExe'} = "/src/paml/paml-4.10.6/src/codeml";
# }
# if ($options{'version'} eq "4.10.6cc") { 
#     $options{'codemlExe'} = "/src/paml_ccCompiled/paml-4.10.6/src/codeml";
# }
if ($options{'version'} eq "4.10.6") { 
    $options{'codemlExe'} = "/src/paml/paml-github20221201/src/codeml";
}
# some PAML versions don't add a tag to the end of the mlc file, so the way I had of checking for PAML success does not work, and I need to stop checking (i.e. use strict=loose)
if ($options{'version'} eq "4.9g") { 
# if (($options{'version'} eq "4.9g") || ($options{'version'} eq "4.10.6")) { 
    if ($options{'strict'} ne "loose") {
        print "    WARNING - because you're using codeml v$options{'version'} we are changing the 'strict' setting to 'loose' (i.e. we will not check the end of the mlc files to make sure codeml succeeded\n\n)";
    }
    $options{'strict'} = "loose";
}
if ($options{'codemlExe'} eq "undefinedSoFar") {
    die "\n\nERROR - terminating in script $script - you specified a version of codeml that is not installed in the container. Available options: 4.9a, 4.9g, 4.9h, 4.9j, 4.10.6\n\n"
}


############# now do things

if (!-e $options{'sif'}) {
    die "\n\nERROR - terminating in script $script - singularity image file expected by the script does not exist: $options{'sif'}\n\n";
}

my $singularityImageVersion = $options{'sif'};
if ($singularityImageVersion =~ m/\//) {
    $singularityImageVersion = (split /\//, $singularityImageVersion)[-1];
}
$singularityImageVersion =~ s/\.sif$//;
$singularityImageVersion =~ s/^paml_wrapper-v//;
## convert 1.1.0 to an true number
my @singularityImageVersionPieces = split /\./, $singularityImageVersion;
$singularityImageVersion = join ".", @singularityImageVersionPieces[0..1];

foreach my $alnFile (@files) {
    print "###### working on file $alnFile\n";
    print "    using executable $options{'codemlExe'}\n";
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

    ### sometimes I want to run using an older singularity image, where I did NOT encode some of the options I have now
    my $singularityVersionDependentOptions = "";
    if ($singularityImageVersion >= 1.2) {
        $singularityVersionDependentOptions .= "--strict=$options{'strict'}";
    }

    #my $singularityCommand = "singularity exec --cleanenv ";
    my $singularityCommand = "apptainer exec --bind \$(pwd):/mnt -H /mnt --cleanenv ";
    
    $singularityCommand .= "$options{'sif'} pw_makeTreeAndRunPAML.pl --codeml=$options{'codemlExe'} $moreOptions $singularityVersionDependentOptions --omega=$options{'omega'} --codon=$options{'codon'} --clean=$options{'clean'} --smallDiff=$options{'smallDiff'} --BEB=$options{'BEB'} --verboseTable=$options{'verboseTable'} $alnFile &>> $logFile";

    open (LOG, "> $logFile");
    print LOG "\n######## Running PAML wrapper within this apptainer container:\n$options{'sif'}\n\n";
    print LOG "Passing the following command to the container:\n\n";
    print LOG "$singularityCommand\n\n";
    print LOG "Running on rhino/gizmo, sometimes we get a apptainer-related error containing these words 'WARNING: Bind mount overlaps container CWD may not be available' but I think it's OK to ignore it.\n\n";
    print LOG "All following output comes from the apptainer container, running pw_makeTreeAndRunPAML.pl.\n\n";
    close LOG;

    open (SH, "> $shellFile");
    print SH "#!/bin/bash\n";
    print SH "source /app/lmod/lmod/init/profile\n";
    # print SH "module load Singularity/3.5.3\n";
    print SH "module load Apptainer/1.1.6\n";
    print SH "$singularityCommand\n";
    #print SH "echo\n";
    print SH "module purge\n";
    close SH;
    ### then we set it running using sbatch
    my $command = "sbatch -t $options{'walltime'} --job-name=$options{'job'}"."$alnFile ./$shellFile";
    system($command);
}