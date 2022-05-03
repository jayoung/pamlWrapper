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
$options{'sif'} = "/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.3.sif"; # singularity image file
$options{'walltime'} = "1-0"; ## walltime for sbatch jobs
$options{'job'} = "pw_";   
$options{'omega'} = 0.4;
$options{'codon'} = 2;
$options{'clean'} = 0;
$options{'BEB'} = 0.9; ### report selected sites with at least this BEB probability into the output file

### set up usage, including the default options
my $usage = "Usage:\nrunPAML.pl myAln1.fa myAln2.fa\n";
$usage .= "    or, setting one or more of these parameters (showing default values here):\n";
$usage .= "runPAML.pl --omega=$options{'omega'} --codon=$options{'codon'} --clean=$options{'clean'} --BEB=$options{'BEB'} --walltime=$options{'walltime'} --job=$options{'job'} --sif=$options{'sif'} myAln1.fa myAln2.fa";


########## parse command line arguments
### I'll parse command-line args myself in this script, using base perl and avoiding Getopt::Long, because I want this script to have zero dependencies
my @commandLineOptions = grep /^--/, @ARGV;
my @files = grep !/^--/, @ARGV;

### parse the options, testing each
foreach my $commandLineOption (@commandLineOptions) {
    $commandLineOption =~ s/^--//;
    if ($commandLineOption !~ m/=/) {
        die "\n\nTerminating - found a command line option that does not contain '=': that doesn't look right: $commandLineOption.\n\n$usage\n\n";
    }
    my @o = split /=/, $commandLineOption;
    if (!defined $options{$o[0]}) {
        die "\n\nTerminating - found a command line option I don't recognize: $o[0].\n\n$usage\n\n";
    }
    $options{$o[0]} = $o[1];
}

# check remaining args - they should all be names of files that exist:
foreach my $alnFile (@files) {
    if (!-e $alnFile) {
        die "\n\nTerminating - file $alnFile does not exist. It's possible you specified a file that doesn't exist, or it's possible you tried to specify a command line argument and got it slightly wrong.\n\n$usage\n\n";
    }
}

############# now do things

if (!-e $options{'sif'}) {
    die "\n\nTerminating - singularity image file expected by the script does not exist: $options{'sif'}\n\n";
}

foreach my $alnFile (@files) {
    print "###### working on file $alnFile\n";
    my $alnFileStem = $alnFile; #$alnFileStem =~ s/\.fa$//; $alnFileStem =~ s/\.fasta$//;
    ### first we make the shell file
    my $outfileStem = $alnFileStem;
    $outfileStem .= ".codon$options{'codon'}";
    $outfileStem .= "_omega$options{'omega'}";
    $outfileStem .= "_clean$options{'clean'}";

    my $shellFile = $outfileStem . "_runPAML.sh";
    my $logFile = $outfileStem . "_runPAML.log.txt";
    open (SH, "> $shellFile");
    print SH "#!/bin/bash\n";
    print SH "source /app/lmod/lmod/init/profile\n";
    print SH "module load Singularity/3.5.3\n";
    print SH "singularity exec --cleanenv $options{'sif'} pw_makeTreeAndRunPAML.pl --omega=$options{'omega'} --codon=$options{'codon'} --clean=$options{'clean'} --BEB=$options{'BEB'} $alnFile > $logFile\n";
    print SH "module purge\n";
    close SH;
    ### then we set it running using sbatch
    my $command = "sbatch -t $options{'walltime'} --job-name=$options{'job'}"."$alnFile ./$shellFile";
    system($command);
}