#!/usr/bin/perl
use warnings;
use strict;


#### for each alignment file, makes a shell script that will use the singularity image to run PAML, and launches that shell script using sbatch

## the version of this script in /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl is a copy of the one here: https://github.com/jayoung/pamlWrapper/tree/main/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl

my $singularityImageFile = "/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.0.3.sif";

my $walltime = "1-0"; ## walltime for sbatch jobs
my $jobnamePrefix = "pw_";   

#############

if (!-e $singularityImageFile) {
    die "\n\nTerminating - singularity image file expected by the script does not exist: $singularityImageFile\n\n";
}

foreach my $alnFile (@ARGV) {
    if (!-e $alnFile) {
        die "\n\nTerminating - file $alnFile does not exist\n\n";
    }
    print "###### working on file $alnFile\n";
    my $alnFileStem = $alnFile; #$alnFileStem =~ s/\.fa$//; $alnFileStem =~ s/\.fasta$//;
    ### first we make the shell file
    my $shellFile = $alnFileStem; $shellFile .= "_runPAMLwrapper.sh";
    my $logFile = $alnFileStem; $logFile .= "_runPAMLwrapper.log.txt";
    open (SH, "> $shellFile");
    print SH "#!/bin/bash\n";
    print SH "source /app/lmod/lmod/init/profile\n";
    print SH "module load Singularity/3.5.3\n";
    print SH "singularity exec --cleanenv $singularityImageFile pw_makeTreeAndRunPAML.pl $alnFile > $logFile\n";
    print SH "module purge\n";
    close SH;
    ### then we set it running using sbatch
    my $command = "sbatch -t $walltime --job-name=$jobnamePrefix"."$alnFile ./$shellFile";
    system($command);
}