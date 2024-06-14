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
my $userTreeFile = "";
my $BEBprobThresholdToPrintSelectedSite = 0.9; ## report selected sites with at least this BEB probability into the output file
my $verboseTable = 0;      ## normally we do NOT output all the parameters for all the models, and we do NOT output site class dN/dS and freq unless a pairwise model comparison has a 'good' p-value, but sometimes for troubleshooting and comparing PAML versions we might want that.
my $strictness = "strict"; ## 'strict' means we insist that 'Time used' will be present at the end of the mlc file, and if it's not we assume PAML failed.   'loose' means it's OK if that's not present (v4.10.6 doesn't always add it)
my $codemlExe = "codeml";  ## default is whichever codeml is in the PATH
my $smallDiff = ".5e-6";   ## .5e-6 was what I ALWAYS used before adding the option to change things, Feb 27, 2023. Ziheng recommends "use a value between 1e-6 and 1e-9", so this is OK

my $scriptName = "pw_makeTreeAndRunPAML.pl";

GetOptions("omega=f"        => \$initialOrFixedOmega,   ## sometimes I do 3
           "codon=i"        => \$codonFreqModel,        ## sometimes I do 3
           "clean=i"        => \$cleanData,             ## sometimes I do 1 to remove the sites with gaps in any species
           "smallDiff=s"    => \$smallDiff,
           "usertree=s"     => \$userTreeFile,
           "BEB=f"          => \$BEBprobThresholdToPrintSelectedSite,
           "verboseTable=i" => \$verboseTable,
           "strict=s"       => \$strictness,
           "codeml=s"       => \$codemlExe) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n"; 

##### I don't usually change these things:
my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 

my $codemlCTLtemplateFile = "$masterPipelineDir/templates/master_sitewise_codeml.ctl";

my @modelsToRun = ("0","0fixNeutral","1","2","7","8","8a");
#my @modelsToRun = ("0","1","2","7","8","8a");
#my @modelsToRun = ("0");


################

my $whichCodeml = `which $codemlExe`;
chomp $whichCodeml;
if ($whichCodeml eq "") {
    die "\n\nERROR - terminating in script $scriptName - you specified a codeml executable that does not exist on this system: $codemlExe\n\n";
}

if ($userTreeFile ne "") {
    if (!-e $userTreeFile) {
        die "\n\nERROR - terminating in script $scriptName - you specified tree file $userTreeFile with the --usertree option, but that file does not exist\n\n";
    }
}

if (($strictness ne "strict") & ($strictness ne "loose")) {
    die "\n\nERROR - terminating in script $scriptName - the '--strict' option must be either 'strict' (default) or 'loose'\n\n";
}

#first read in codeml.ctl template
if (!-e $codemlCTLtemplateFile) {
    die "\n\nERROR - terminating in script $scriptName - cannot open template file $codemlCTLtemplateFile\n\n";
}
undef $/;
open (TEMPLATE, "< $codemlCTLtemplateFile");
my @templatelines = <TEMPLATE>;
my $template = $templatelines[0];
close TEMPLATE;

my $topDir = cwd();

foreach my $alignmentFile (@ARGV) {
    if (!-e $alignmentFile) {
        die "\n\nERROR - terminating in script $scriptName - alignment file $alignmentFile does not exist\n\n";
    } 
    print "\n######## Running PAML for alignment $alignmentFile with codon model $codonFreqModel, starting omega $initialOrFixedOmega, cleandata $cleanData, smallDiff $smallDiff\n";
    print "\n    codeml executable: $whichCodeml\n\n";

    my $alnFileWithoutDir = $alignmentFile;
    if ($alnFileWithoutDir =~ m/\//) {
        $alnFileWithoutDir = (split /\//, $alnFileWithoutDir)[-1];
    }
    ## run some checks on the alignment using pw_checkAlignmentBasics.pl :
    # are seqs the same length?
    # is alignment length is a multiple of three?
    # my $exitCode = system("$masterPipelineDir/scripts/pw_checkAlignmentBasics.pl $alnFileWithoutDir") >> 8;
    my $exitCode = system("$masterPipelineDir/scripts/pw_checkAlignmentBasics.pl $alignmentFile") >> 8;
    if ($exitCode > 0) {
        die "\n\nERROR - terminating in script $scriptName - ERROR - problem with seq lengths in alignment file (see details above). Is this really an in-frame alignment?  We need an in-frame alignment to run PAML\n\n";
    }
    # check for internal stops/frameshifts
    # my $exitCode2 = system("$masterPipelineDir/scripts/pw_checkAlignmentFrameshiftsStops.pl $alnFileWithoutDir") >> 8;
    my $exitCode2 = system("$masterPipelineDir/scripts/pw_checkAlignmentFrameshiftsStops.pl $alignmentFile") >> 8;
    if ($exitCode2 > 0) {
        print "    WARNING - some seqs in this alignment file have internal stops/frameshifts (see details above). Is this really an in-frame alignment?  We need an in-frame alignment to run PAML. Proceeding, but you might want to check your alignment\n\n";
    }


    ## make a new folder, and run everything in there
    # my $pamlDir = $alnFileWithoutDir . "_phymlAndPAML";
    my $pamlDir = $alignmentFile . "_phymlAndPAML";
    #print "\npamlDir $pamlDir\n\n";
    if (!-e $pamlDir) { mkdir $pamlDir; }
    if (!-e "$pamlDir/$alnFileWithoutDir") { system ("cp $alignmentFile $pamlDir"); }
    chdir $pamlDir; ## I'm in $pamlDir
    #if (!-e $alnFileWithoutDir) { system ("cp ../$alnFileWithoutDir ."); }
    
    ## convert to paml format, including truncating names to 30 characters
    # This also makes an aliases file so we know what the original names were
    my $alnFilePhylipFormat = "$alnFileWithoutDir.phy";
    if (!-e $alnFilePhylipFormat) {
        system("$masterPipelineDir/scripts/pw_fasta2pamlformat.bioperl $alnFileWithoutDir")
    }
    
    ## find or make the tree file using pw_runPHYML.pl
    ## xx if I start one PAML run with one set of parameters really soon after the last one, it may THINK there is already a tree but the tree is not ready to use. need to somehow check for that
    
    my $treeFile1;
    my $treeFile2;
    if ($userTreeFile eq "") {   
        ### we're making a tree
        my $treeDir = $alnFileWithoutDir . "_PHYMLtree";
        if (!-e $treeDir) { mkdir $treeDir; }
        system("cp $alnFilePhylipFormat $treeDir");
        chdir $treeDir; ## I'm in $pamlDir/$treeDir
        $treeFile1 = "$alnFilePhylipFormat"."_phyml_tree";
        $treeFile2 = "$alnFilePhylipFormat"."_phyml_tree.nolen";
        if (!-e $treeFile1) { 
            system("$masterPipelineDir/scripts/pw_runPHYML.pl $alnFilePhylipFormat")
        }
        if (!-e $treeFile2) {
            die "\n\nERROR - terminating in script $scriptName - tree file $treeFile2 does not exist\n\n";
        }
        if (!-e "../$treeFile2") { system("cp $treeFile2 .."); }
        chdir ".."; ## I'm in $pamlDir
    } else {
        ### we're using the user-specified tree
        # xx for now we use it directly, but we probably want to do some checks on it, maybe remove branch lengths etc. 
        # xx we might also need to swap in names using the aliases file (.aliases.txt), because in the alignment I might have truncated some long names before running PAML. The user will assume the tree file and fasta file they supplied as inputs should have the same names

        ## first we check that the treefile and alignment file the user specified have names that match each other
        my $exitCode = system("$masterPipelineDir/scripts/pw_checkUserTree.pl $alnFileWithoutDir ../$userTreeFile") >> 8;
        if ($exitCode > 0) {
            die "\n\nERROR - terminating in script $scriptName - problem with the user tree (see details above - if that error refers to a tsv file, you should see it inside the folder called $pamlDir).\n\n";
        }
        ## then we truncate long names in the treefile just like we might have done in the alignment file
        system("cp ../$userTreeFile .");
        system("$masterPipelineDir/scripts/pw_changenamesinphyliptreefile.pl --format old_new $userTreeFile $alnFileWithoutDir.aliases.txt");
        $treeFile2 = "$userTreeFile.names";
    }
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
            $thistemplate =~ s/SMALLDIFF/$smallDiff/;
            
            open (OUT, "> $codemlfile");
            print OUT "$thistemplate\n";
            close OUT;
        }
        #run codeml, if it's not already done
        my $mlcFile = "$modelDir/mlc";
        if (!-e $mlcFile) {
            my $command = "cd $modelDir ; $codemlExe > screenoutput.txt ; cd ..";
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
        my $otherOptions = "";
        if ($userTreeFile ne "") { 
            $otherOptions .= "--processTree=no --usertree=$userTreeFile"; 
        }

        # my $cwd = cwd();
        # print "\n############################\n\n";
        # print "Parsing PAML.\n";
        # print "    cwd $cwd\n";
        # print "    pamlDir $pamlDir\n";
        # print "    alnFileWithoutDir $alnFileWithoutDir\n";

        # system ("$masterPipelineDir/scripts/pw_parsePAMLoutput.pl $otherOptions -verboseTable=$verboseTable -strict=$strictness -omega=$initialOrFixedOmega -codon=$codonFreqModel -clean=$cleanData -BEB=$BEBprobThresholdToPrintSelectedSite $alnFileWithoutDir");
        system ("$masterPipelineDir/scripts/pw_parsePAMLoutput.pl $otherOptions -verboseTable=$verboseTable -strict=$strictness -omega=$initialOrFixedOmega -codon=$codonFreqModel -clean=$cleanData -BEB=$BEBprobThresholdToPrintSelectedSite --dir=$pamlDir $alnFileWithoutDir");

        ### before Jun 14 2024 I did not include the --cpg=1 option, so the script would produce empty output if run on a single CpG-masked alignment.  xxx still testing
        system ("$masterPipelineDir/scripts/pw_parsedPAMLconvertToWideFormat.pl $parsedPAMLoutputFile");
        # system ("$masterPipelineDir/scripts/pw_parsedPAMLconvertToWideFormat.pl --cpg=1 $parsedPAMLoutputFile");
        if(!-e $parsedPAMLoutputFile) {
            die "\n\nERROR - terminating in script $scriptName - parsed PAML output file does not exist: $parsedPAMLoutputFile\n\n";
        }
    }
} # end of foreach my $alignmentFile loop

print "\n################# done ###############\n\n";
