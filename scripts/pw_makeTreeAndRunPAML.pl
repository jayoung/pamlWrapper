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
my $cleanData = 0;
my $BEBprobThresholdToPrintSelectedSite = 0.9; ### report selected sites with at least this BEB probability into the output file

GetOptions("omega=f" => \$initialOrFixedOmega,   ## sometimes I do 3
           "codon=i" => \$codonFreqModel,        ## sometimes I do 3
           "clean=i" => \$cleanData,             ## sometimes I do 1 to remove the sites with gaps in any species
           "BEB=f"   => \$BEBprobThresholdToPrintSelectedSite) or die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - unknown option(s) specified on command line\n\n"; 

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
    die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - cannot open template file $codemlCTLtemplateFile\n\n";
}
undef $/;
open (TEMPLATE, "< $codemlCTLtemplateFile");
my @templatelines = <TEMPLATE>;
my $template = $templatelines[0];
close TEMPLATE;

my $topDir = cwd();

foreach my $alignmentFile (@ARGV) {
    if (!-e $alignmentFile) {
        die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - alignment file $alignmentFile does not exist\n\n";
    } 
    print "\n######## Running PAML for alignment $alignmentFile with codon model $codonFreqModel, starting omega $initialOrFixedOmega, cleandata $cleanData\n";
    my $alnFileWithoutDir = $alignmentFile;
    if ($alnFileWithoutDir =~ m/\//) {
        $alnFileWithoutDir = (split /\//, $alnFileWithoutDir)[-1];
    }
    ## run some checks on the alignment
    # are seqs the same length?
    my $exitCode = system("$masterPipelineDir/scripts/pw_checkAlignmentBasics.pl $alnFileWithoutDir") >> 8;
    if ($exitCode > 0) {
        die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - ERROR - problem with seq lengths in alignment file (see details above). Is this really an in-frame alignment?  We need an in-frame alignment to run PAML\n\n";
    }
    # check for internal stops/frameshifts
    my $exitCode2 = system("$masterPipelineDir/scripts/pw_checkAlignmentFrameshiftsStops.pl $alnFileWithoutDir") >> 8;
    if ($exitCode2 > 0) {
        print "    WARNING - some seqs in this alignment file have internal stops/frameshifts (see details above). Is this really an in-frame alignment?  We need an in-frame alignment to run PAML. Proceeding, but you might want to check your alignment\n\n";
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
        die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - tree file $treeFile2 does not exist\n\n";
    }
    if (!-e "../$treeFile2") { system("cp $treeFile2 .."); }
    chdir ".."; ## I'm in $pamlDir
    
    my $alnFileForCTLfile = "../$alnFilePhylipFormat";
    my $treeFileForCTLfile = "../$treeFile2";
    
    foreach my $model (@modelsToRun) {
        print "    Running model $model\n";
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
            print "        output $mlcFile exists already - skipping this model\n";
        }
        # we also convert the rst file to tab-delimited, just for M8
        if ($model eq "8") {
            system ("$masterPipelineDir/scripts/pw_parse_rst_getBEBtable.pl $modelDir/rst");
        }

    } # end of foreach my $model loop
    ## go back to the dir we started in
    chdir $topDir; 
    
    ## parse PAML output
    my $parsedPAMLoutputFile = "$pamlDir/$alnFileWithoutDir";
    $parsedPAMLoutputFile =~ s/\.fa$//;
    $parsedPAMLoutputFile =~ s/\.fasta$//;
    $parsedPAMLoutputFile .= ".codonModel$codonFreqModel";
    $parsedPAMLoutputFile .= "_initOmega$initialOrFixedOmega";
    $parsedPAMLoutputFile .= "_cleandata$cleanData"; 
    $parsedPAMLoutputFile .= ".PAMLsummary.tsv";
    if (-e $parsedPAMLoutputFile) {
        print "\n\nSkipping parsing - outfile exists already: $parsedPAMLoutputFile\n\n";
    } else {
        system ("$masterPipelineDir/scripts/pw_parsePAMLoutput.pl -omega=$initialOrFixedOmega -codon=$codonFreqModel -clean=$cleanData -BEB=$BEBprobThresholdToPrintSelectedSite $alnFileWithoutDir");

        system ("$masterPipelineDir/scripts/pw_parsedPAMLconvertToWideFormat.pl $parsedPAMLoutputFile");
        if(!-e $parsedPAMLoutputFile) {
            die "\n\nERROR - terminating in script pw_makeTreeAndRunPAML.pl - parsed PAML output file does not exist: $parsedPAMLoutputFile\n\n";
        }
    }
} # end of foreach my $alignmentFile loop

print "\n################# done ###############\n\n";
