#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

#### runs PHYML to make a tree from a nucleotide alignment.  Specify the alignment file
## can also specify number of bootstraps, e.g. --boot 100 (default=0), model (default=GTR), and datatype (nt is default, aa is the other option)

## simplest phyml run (DNA seq, no bootstrapping)
# pw_runPHYML.pl alnFile.phy

## add bootstrapping, 100 replicates, 4 CPUs
# pw_runPHYML.pl --boot 100 -t 4 alnFile.phy

## add bootstrapping, 100 replicates, 4 CPUs, using sbatch on the cluster
# pw_runPHYML.pl --sbatch --boot 100 -t 4 alnFile.phy

## example of the command it'll spit out:
# phyml -i TRIM25_primates_aln1_NT.fa.phy -d nt --sequential -m GTR --pinv e --alpha e -f e > TRIM25_primates_aln1_NT.fa.phy_phyml_log

#### set up default parameters (chose the ones I use for my trees to make PAML), but I can also specify other parameters on command line
my $datatype = "nt";  
my $model = "GTR";      # (GTR = nucleotide substitution model)
my $numBootstraps = 0;  # 0 means do not provide bootstrap support etc
my $use_sbatch = "";    # default is NOT to use sbatch
my $walltime = "5-0";   # if we do use sbatch, default walltime is 5 days
my $numThreads = 1;     # num threads

my $scriptName = "pw_runPHYML.pl";

GetOptions("dat=s"   => \$datatype,       ## '--dat aa' for amino acid alns
           "model=s" => \$model,        ## '--model JTT' to use JTT model for aa alns
           "boot=i"  => \$numBootstraps, ## '--boot 100' to specify 100 bootstraps
           "sbatch"  => \$use_sbatch,    ## '--sbatch' to use sbatch
            ### I have disabled the ability to ask for >1 thread for now - phyml-mpi seems way slower than it should be. I might need to reinstall it and use a newer version of mpirun
            #"t=i" => \$numThreads,       ## '--t 4' to use 4 threads
           "wall=s"  => \$walltime) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";     ## '--wall 0-6' to specify 6 hrs

my $constantParameters = "--sequential --pinv e --alpha e -f e"; ## i.e. I have not encoded the ability to change them
# --pinv e (= estimate the proportion of invariable sites)
# --alpha e (= estimate the shape of the gamme distribution)
# -f e    (= estimate nucleotide freqs)

## this is what will go into command line phyml call
my $parameters = "--datatype $datatype --model $model -b $numBootstraps $constantParameters";

my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 


##################

my $phyml_exe = "phyml"; 
if ($numThreads > 1) { $phyml_exe = "mpirun -np $numThreads phyml-mpi"; }

if ($use_sbatch) {print "\n\nUsing sbatch to parallelize\n\n";}

foreach my $file (@ARGV) {
    if (!-e $file) { die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";}

    ### figure out output file names
    my $treeOutfile = $file . "_phyml_tree";
    my $treeOutfileWithExt = $file . "_phyml_tree.txt"; # newer versions of phyml use this output name.  I'll rename the output file to be compatible with older version
    if (-e $treeOutfile) {
        #print "    skipping file $file - output exists already $treeOutfile\n";
        next;
    }
    my $logfile = $file . "_phyml_log";

    ### special situation for when there are only 2 seqs in the alignment - we make a fake tree, because PHYML (rightly) doesn't want to make a tree from that.
    my $numSeqs = `head -1 $file`; 
    chomp $numSeqs; $numSeqs =~ s/^\s+//;
    $numSeqs = (split /\s+/, $numSeqs)[0];
    if ($numSeqs == 2) {
        print "\n\n    WARNING - there are only $numSeqs in alignment file $file. This is NOT enough to run PHYML to make a tree. I'm going to make a fake tree (star phylogeny)\n\n";
        open (LOG, "> $logfile");
        print "\n\n    WARNING - there are only $numSeqs in alignment file $file. This is NOT enough to run PHYML to make a tree. I'm going to make a fake tree (star phylogeny)\n\n";
        close LOG;

        ## get seqnames - get rid of first line in the file, then seqnames are every other line
        open (ALN, "< $file");
        my @lines = <ALN>;
        close ALN;
        shift @lines; # remove first line
        my $takeThisLine = 1;
        my @seqnames;
        # keep every other line
        foreach my $line (@lines) {
            if ($takeThisLine) {
                chomp $line; push @seqnames, $line;
            }
            $takeThisLine = !$takeThisLine;
        }
        my $seqnameString = join ",", @seqnames;
        open (TREE, "> $treeOutfile");
        print TREE "($seqnameString);\n";
        close TREE;
        system("$masterPipelineDir/scripts/pw_removeBranchLengthsFromTree.pl --addFirstLine=1 $treeOutfile");
        next;
    }

    ### run PHYML
    my $command = "$phyml_exe -i $file $parameters >> $logfile ; mv $treeOutfileWithExt $treeOutfile ; $masterPipelineDir/scripts/pw_removeBranchLengthsFromTree.pl --addFirstLine=1 $treeOutfile";
    print "    making tree for file $file - command is:\n$command\n\n";
    if (!$use_sbatch) {
        system("$command");
        ### check it worked
        if (!-e $treeOutfile) {
            die "\n\nERROR - terminating in script $scriptName - tree file is not present, perhaps phyml failed\n\n";
        }
        if (-z $treeOutfile) {
            die "\n\nERROR - terminating in script $scriptName - tree file is empty, perhaps phyml failed\n\n";
        }
    } else {
        $command = "sbatch --cpus-per-task=$numThreads -t $walltime --job-name=PHYML --wrap=\"$command\"";
        system("$command");
    }
}
