#!/usr/bin/perl
use warnings;
use strict;
use Cwd;
use Getopt::Long;

#### usage:  pw_makeTreeAndRunPAML.pl alignmentFile(s)*.fa
#takes a bunch of alignments in fasta format. for each one, make a tree (if it does not already exist) and runs paml. 
# with the older version of this repo I was using pw_makeTreeAndRunPAML_sbatchWrapper.pl to run it on the cluster.


## set up defaults:
my $initialOrFixedOmega = 0.4;
my $codonFreqModel = 2;
my $walltime = "1-0";   # if we do use sbatch, default walltime is 1 days
my $cleanData = 0;

GetOptions("omega=f" => \$initialOrFixedOmega,   ## sometimes I do 3
           "codon=i" => \$codonFreqModel,        ## sometimes I do 3
           "clean=i" => \$cleanData,             ## sometimes I do 1 to remove the sites with gaps in any species
           "wall=s" => \$walltime) or die "\n\nterminating - unknown option(s) specified on command line\n\n"; 
               ## '--wall 0-6' to specify 6 hrs

##### I don't usually change these things:
my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 

my $codemlCTLtemplateFile = "$masterPipelineDir/templates/master_sitewise_codeml.ctl";

my @modelsToRun = ("0","0fixNeutral","1","2","7","8","8a");
#my @modelsToRun = ("0","1","2","7","8","8a");
#my @modelsToRun = ("0");

# print "\nrunning PAML with these parameters:\n    starting omega $initialOrFixedOmega\n    codon model $codonFreqModel\n    cleandata $cleanData\n\n";

################

#first read in codeml.ctl template
if (!-e $codemlCTLtemplateFile) {
    die "\n\nterminating pw_makeTreeAndRunPAML.pl - cannot open template file $codemlCTLtemplateFile\n\n";
}
undef $/;
open (TEMPLATE, "< $codemlCTLtemplateFile");
my @templatelines = <TEMPLATE>;
my $template = $templatelines[0];
close TEMPLATE;

my $topDir = cwd();

foreach my $alignmentFile (@ARGV) {
    if (!-e $alignmentFile) {
        die "\n\nterminating - alignment file $alignmentFile does not exist\n\n";
    } 
    my $alnFileWithoutDir = $alignmentFile;
    if ($alnFileWithoutDir =~ m/\//) {
        $alnFileWithoutDir = (split /\//, $alnFileWithoutDir)[-1];
    }
    
    ## make a new folder, and run everything in there
    my $pamlDir = $alnFileWithoutDir . "_phymlAndPAML";
    if (!-e $pamlDir) { mkdir $pamlDir; }
    chdir $pamlDir; ## I'm in $pamlDir
    if (!-e $alnFileWithoutDir) { system ("cp ../$alnFileWithoutDir ."); }
    
    ## convert to paml format, including truncating names to 30 characters
    # This also makes an aliases file so we know what the original names were
    my $alnFilePhylipFormat = "$alnFileWithoutDir.phy";
    if (!-e $alnFilePhylipFormat) {
        system("$masterPipelineDir/scripts/pw_fasta2pamlformat.bioperl $alnFileWithoutDir")
    }
    ## xxx here - I could open up the .phy file and make sure the alignment length is a multiple of three
    
    ## find or make the tree file using pw_runPHYML.pl
    ## xx if I start one PAML run with one set of parameters really soon after the last one, it may THINK there is already a tree but the tree is not ready to use. need to somehow check for that
    
    my $treeDir = $alnFileWithoutDir . "_PHYMLtree";
    if (!-e $treeDir) { mkdir $treeDir; }
    system("cp $alnFilePhylipFormat $treeDir");
    chdir $treeDir; ## I'm in $pamlDir/$treeDir
    my $treeFile1 = "$alnFilePhylipFormat"."_phyml_tree";
    my $treeFile2 = "$alnFilePhylipFormat"."_phyml_tree.nolen";
    if (!-e $treeFile1) { 
        system("$masterPipelineDir/scripts/pw_runPHYML.pl $alnFilePhylipFormat")
    }
    if (!-e $treeFile2) {
        die "\n\nterminating pw_makeTreeAndRunPAML.pl - tree file $treeFile2 does not exist\n\n";
    }
    if (!-e "../$treeFile2") { system("cp $treeFile2 .."); }
    chdir ".."; ## I'm in $pamlDir
    
    my $alnFileForCTLfile = "../$alnFilePhylipFormat";
    my $treeFileForCTLfile = "../$treeFile2";
    
    foreach my $model (@modelsToRun) {
        print "Running model $model\n";
        my $modelDir = "M$model";
        $modelDir .= "_initOmega$initialOrFixedOmega";
        $modelDir .= "_codonModel$codonFreqModel";
        if ($cleanData==1) { $modelDir .= "_cleandata1"; }
        if (!-e $modelDir) { mkdir $modelDir; }
        
        my $codemlfile = "$modelDir/codeml.ctl";
        if (!-e $codemlfile) {
            my $thistemplate = $template;
            $thistemplate =~ s/SEQFILEHERE/$alnFileForCTLfile/;
            $thistemplate =~ s/TREEFILEHERE/$treeFileForCTLfile/;
            
            my $modelToRun = $model;
            my $fixOmega = 0;
            my $thisInitialOrFixedOmega = $initialOrFixedOmega;
            if ($model eq "8a") {
                $modelToRun = "8"; 
                $fixOmega = 1;
                $thisInitialOrFixedOmega = 1;
            }
            if ($model eq "0fixNeutral") {
            $modelToRun = "0"; 
                $fixOmega = 1;
                $thisInitialOrFixedOmega = 1;
            }
            $thistemplate =~ s/WHICHMODEL/$modelToRun/;
            $thistemplate =~ s/FIXOMEGA/$fixOmega/;
            $thistemplate =~ s/INITIALOMEGA/$thisInitialOrFixedOmega/;
            $thistemplate =~ s/CLEANDATA/$cleanData/;
            $thistemplate =~ s/CODONFREQMODEL/$codonFreqModel/;
            
            open (OUT, "> $codemlfile");
            print OUT "$thistemplate\n";
            close OUT;
        }
        #run codeml, if it's not already done
        my $mlcFile = "$modelDir/mlc";
        if (!-e $mlcFile) {
            my $command = "cd $modelDir ; codeml > screenoutput ; cd ..";
            system ("$command");
        } else {
            print "    output $mlcFile exists already - skipping this model\n";
        }
    } # end of foreach my $model loop
    ## go back to the dir we started in
    chdir $topDir; 
    my $parsedPAMLoutputFile = "$pamlDir/$alnFileWithoutDir";
    $parsedPAMLoutputFile =~ s/\.fa$//;
    $parsedPAMLoutputFile =~ s/\.fasta$//;
    $parsedPAMLoutputFile .= ".PAMLsummary.txt";

    if (-e $parsedPAMLoutputFile) {
        print "\n\nSkipping parsing - outfile exists already: $parsedPAMLoutputFile\n\n";
    } else {
        system ("$masterPipelineDir/scripts/pw_parsePAMLoutput.pl $alnFileWithoutDir");
        system ("$masterPipelineDir/scripts/pw_parsedPAMLconvertToWideFormat.pl $parsedPAMLoutputFile");
        if(!-e $parsedPAMLoutputFile) {
            die "\n\nTerminating - parsed PAML output file does not exist: $parsedPAMLoutputFile\n\n";
        }
    }
} # end of foreach my $alignmentFile loop
