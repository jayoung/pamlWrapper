#!/usr/bin/perl
use warnings;
use strict;
use Statistics::Distributions;
use Bio::AlignIO;
use Getopt::Long;

###### assumes PAML was run using the script pw_makeTreeAndRunPAML.pl on the fasta files specified on the command line

################## parse PAML output, calculate p-values for various model comparisons (M8-M7, M8a-M7, M2-M1) and make a giant table of the results. For alignments with decent p-values, reports the sites that are said to be under positive selection from M8's BEB output.  Also makes pdfs of the input tree, and plots of the distribution of omega classes.


##### set up defaults:
## initial omega / codon model (we only need to know this to know what the output dirs are called)
my $initialOrFixedOmega = 0.4;
my $codonFreqModel = 2;
my $cleanData = 0;
my $processTree = "yes"; ## if I ran PAML using a supplied tree (e.g. species tree) I don't want to bother with the steps of this script that process the tree 
#my $processTree = "no";
my $BEBprobThresholdToPrintSelectedSite = 0.9; ### report selected sites with at least this BEB probability into the output file
my $combinedOutputFile = 0;    ## we always make one output file per input file, but do we also make a single output file for all the input files combined?

GetOptions("omega=f"       => \$initialOrFixedOmega,   ## sometimes I do 3, default is 0.4
           "codon=i"       => \$codonFreqModel,        ## sometimes I do 3, default is 2
           "clean=i"       => \$cleanData,             ## sometimes I do 1 to remove the sites with gaps in any species
           "BEB=f"         => \$BEBprobThresholdToPrintSelectedSite, # 0.5 to be less conservative, default is 0.9
           "processTree=s" => \$processTree,
           "comb=i"        => \$combinedOutputFile) or die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - unknown option(s) specified on command line\n\n"; 



###### I don't usually change these things:
my $PAMLresultsDirSuffix = "phymlAndPAML";

## which models to look at output for
my @allmodels = ("M0","M0fixNeutral","M1","M2","M7","M8","M8a");
#my @allmodels = ("M0","M0fixNeutral");

my $masterPipelineDir = $ENV{'PAML_WRAPPER_HOME'}; 

## if I'm processing the tree and plotting it, I need to use a version of Rscript that is compatible with the version of the ape library that I have installed
my $RscriptExecutable = "Rscript";

################

## check Rscript is in our path
my $checkWhich = `which $RscriptExecutable`;
if ($checkWhich eq "") {
    die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - R is not available. If you're working on gizmo/rhino, maybe you need to load an R module before running this script. Try this:\n    module load fhR/4.1.2-foss-2020b\n\n";
}

## prep overall outfiles, including header rows. 
# this outfile is in "long" format, where each paml model gets its own row, so each alignment gets ~7 rows. see pw_parsedPAMLconvertToWideFormat.pl to convert this to a wide format, with only one row per gene.
my $overallOutputFile_fh;
if ($combinedOutputFile) {
    my $overallOutputFile = "allAlignments";
    $overallOutputFile .= ".codonModel$codonFreqModel";
    $overallOutputFile .= "_initOmega$initialOrFixedOmega";
    $overallOutputFile .= "_cleandata$cleanData"; 
    $overallOutputFile .= ".PAMLsummary.tsv";
    open($overallOutputFile_fh, ">", "$overallOutputFile");
    printHeaderRows($overallOutputFile_fh, $BEBprobThresholdToPrintSelectedSite);
}
my @files = sort (@ARGV);

foreach my $fastaAlnFile (@files) {
    if (!-e $fastaAlnFile) {
        die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot open file $fastaAlnFile\n\n";
    }

    print "\n\n############################\n\n";
    print "Parsing PAML output for alignment $fastaAlnFile\n";
    
    my $filenameWithoutDir = $fastaAlnFile;
    if ($filenameWithoutDir =~ m/\//) {
        $filenameWithoutDir = (split /\//, $filenameWithoutDir)[-1];
    }
    
    my $fileStem = $filenameWithoutDir;
    $fileStem =~ s/\.fa$//;
    $fileStem =~ s/\.fasta$//;
    
    my $PAMLresultsDir = "$fastaAlnFile"."_$PAMLresultsDirSuffix";
    if (!-e $PAMLresultsDir) {
        die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot find PAML results master dir $PAMLresultsDir\n\n";
    }

    #### first, change names in tree file (with and without branch lengths) back to originals
    if ($processTree eq "yes") {
        my $aliasesFile = "$PAMLresultsDir/$filenameWithoutDir.aliases.txt";
        my $geneTreeDir = "$PAMLresultsDir/$filenameWithoutDir"."_PHYMLtree";
        my $geneTreeFile = "$filenameWithoutDir.phy_phyml_tree";
        my $geneTreeFileNoLen = "$filenameWithoutDir.phy_phyml_tree.nolen";
        
        if (!-e $aliasesFile) {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot find alias file $aliasesFile\n\n";
        }
        if (!-e $geneTreeDir) {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot find gene tree dir $geneTreeDir\n\n";
        }
        if (!-e "$geneTreeDir/$geneTreeFile") {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot find gene tree file $geneTreeFile\n\n";
        }
        if (!-e "$geneTreeDir/$geneTreeFileNoLen") {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot find gene tree file without branch lengths $geneTreeFileNoLen\n\n";
        }
        
        print "    restoring original seq names in tree files\n";
        system("$masterPipelineDir/scripts/pw_changenamesinphyliptreefileBackAgain.pl $geneTreeDir/$geneTreeFile $aliasesFile");
        system("$masterPipelineDir/scripts/pw_changenamesinphyliptreefileBackAgain.pl $geneTreeDir/$geneTreeFileNoLen $aliasesFile");
        
        print "    drawing trees\n";
        plot_tree("$geneTreeDir/$geneTreeFile.names");
        plot_tree("$geneTreeDir/$geneTreeFileNoLen.names");
        
        ## reorder seqs in tree order, so that the alignment is easier to look at
        print "    getting a seq file in tree order\n";
        system("$masterPipelineDir/scripts/pw_reorderseqs_treeorder.pl $PAMLresultsDir/$filenameWithoutDir $geneTreeDir/$geneTreeFile.names");
    }
    ## now look at PAML results
    print "    looking at PAML results\n";
    
    ## prep outfile, including header rows:
    my $outfileStem = "$PAMLresultsDir/$fileStem";
    $outfileStem .= ".codonModel$codonFreqModel";
    $outfileStem .= "_initOmega$initialOrFixedOmega";
    $outfileStem .= "_cleandata$cleanData"; 

    my $outfile = "$outfileStem.PAMLsummary.tsv";

    open(my $outfile_fh, ">", "$outfile");
    printHeaderRows($outfile_fh, $BEBprobThresholdToPrintSelectedSite);

    my %allPAMLresults;
    ## first read in all the paml results (I need them all before I can get the p-values)
    foreach my $thisModel (@allmodels) {
        my $modelSubDir = "$PAMLresultsDir/$thisModel"."_initOmega$initialOrFixedOmega"."_codonModel$codonFreqModel";
        if ($cleanData == 1) { $modelSubDir .= "_cleandata1"; }
        if (!-e $modelSubDir) {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot open PAML results dir $modelSubDir\n\n";
        }
        my $mlcFile = "$modelSubDir/mlc";
        if (!-e $mlcFile) {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot open mlc file $mlcFile\n\n";
        }
        $allPAMLresults{$thisModel} = parse_paml($mlcFile, $thisModel);
    }
        
    ### call an R script that plots the distributions of site omega classes:
    plot_omegas("$PAMLresultsDir", "$outfileStem", \%allPAMLresults, \@allmodels);
    
    ## then calculate 2deltaML and p-values, comparing models
    my $pamlStatsRef = paml_stats(\%allPAMLresults);
    my %pamlStats = %$pamlStatsRef;
    
    foreach my $thisModel (@allmodels) {
        my $pamlResultRef = $allPAMLresults{$thisModel};
        my %pamlResult = %{$pamlResultRef};
        my $pamlWorked = "yes";
        if (defined $pamlResult{'warnings'}) {
            if ($pamlResult{'warnings'} eq "FAILED!!!") { 
                die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - looks like PAML failed - mlc file is $pamlResult{'file'}\n\n";
            } else {
                print "        WARNING - paml result had a warning $pamlResult{'warnings'} - see file $pamlResult{'file'}\n";
            }
        }
        
        #### start making output line
        # numSeqs seqLenNT seqLenCodons model resultsDir startingOmega 
        my $outputLine = "$fastaAlnFile";
        my $numNT = $pamlResult{'numcodons'} * 3;
        $outputLine .= "\t$pamlResult{'numseqs'}\t$numNT\t$pamlResult{'numcodons'}\t";
        # lnL np test 2diffML df pValue
        my $modelSubDir = "$PAMLresultsDir/$thisModel"."_initOmega$initialOrFixedOmega"."_codonModel$codonFreqModel";
        if ($cleanData == 1) { $modelSubDir .= "_cleandata1"; }
        if (!-e $modelSubDir) {
            die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl - cannot open PAML results dir $modelSubDir\n\n";
        }
        $outputLine .= "$thisModel\t$modelSubDir\t";
        $outputLine .= "$codonFreqModel\t$initialOrFixedOmega\t$cleanData\t";
        $outputLine .= "$pamlResult{'lnL'}\t$pamlResult{'np'}\t";
        my $reportTestResults = "no";
        #print "        model $thisModel\n";
        if ($thisModel eq "M2") { $reportTestResults = "M2_M1"; }
        if ($thisModel eq "M8") { $reportTestResults = "M8_M7"; }
        if ($thisModel eq "M8a") { $reportTestResults = "M8_M8a"; }
        if ($thisModel eq "M0fixNeutral") { $reportTestResults = "M0_M0fix"; }
        if ($reportTestResults ne "no") {
            #print "\n\nDOING A TEST!\n";
            my $MLdiff = "$reportTestResults"."_2ML";
            my $npDiff = "$reportTestResults"."_npDiff";
            my $pval = "$reportTestResults"."_pval";
            $outputLine .= "$reportTestResults\t$pamlStats{$MLdiff}\t";
            $outputLine .= "$pamlStats{$npDiff}\t$pamlStats{$pval}\t";
        } else {
            $outputLine .= "\t\t\t\t";
        }
        # kappa treeLen treeLen_dN treeLen_dS overallOmega
        if ($thisModel eq "M0") {
            $outputLine .= "$pamlResult{'kappa'}\t$pamlResult{'treelength'}\t";
            $outputLine .= "$pamlResult{'treelength_dN'}\t$pamlResult{'treelength_dS'}\t";
            $outputLine .= "$pamlResult{'overallOmega'}\t";
        } else {
            $outputLine .= "\t\t\t\t\t";
        }
        # M2: proportionSelectedSites estimatedOmegaOfSelectedClass seqToWhichSiteCoordsRefer whichSites
        if ($thisModel eq "M2") { 
            if ($pamlStats{'M2_M1_pval'} < 0.1) {
                print "                test M2 vs M1 had a good p-value!\n";
                my $model2p = $pamlResult{"p"};
                $model2p = (split /\,/, $model2p)[2];
                my $model2w = $pamlResult{"w"};
                $model2w = (split /\,/, $model2w)[2];
                $outputLine .= "$model2p";
                $outputLine .= "\t$model2w";
                $outputLine .= "\tnotGettingThisInfoRightNow\t\t";
            } else {
                $outputLine .= "\t\t\t\t";
            }
        }
        
        # M8: proportionSelectedSites estimatedOmegaOfSelectedClass seqToWhichSiteCoordsRefer numSites whichSites
        if ($thisModel eq "M8") {
            if (($pamlStats{'M8_M7_pval'} < 0.1) || ($pamlStats{'M8_M8a_pval'} < 0.1))  {
                print "                test M8vsM7 and/or M8avsM7 had a good p-value!\n";
                #print "getting sites!\n";
                my $model8siteResultsRef = paml_BEB_results("$modelSubDir/mlc");
                my %model8siteResults = %$model8siteResultsRef;
                $outputLine .= "$model8siteResults{'p1'}";
                $outputLine .= "\t$model8siteResults{'w'}";
                $outputLine .= "\t$model8siteResults{'refSeq'}";
                my $sites = "noneOver_$BEBprobThresholdToPrintSelectedSite";
                my $numSites = 0;
                if (defined $model8siteResults{'sites'}) {
                    $sites = join ",", @{$model8siteResults{'sites'}};
                    $numSites = @{$model8siteResults{'sites'}};
                }
                $outputLine .= "\t$numSites";
                $outputLine .= "\t$sites";
                ## annotate selected sites
                my $treeorderFile = "$PAMLresultsDir/$filenameWithoutDir";
                $treeorderFile =~ s/\.fasta$//; $treeorderFile =~ s/\.fa$//; 
                $treeorderFile .= ".treeorder.fa";
                system("$masterPipelineDir/scripts/pw_annotateAlignmentWithSelectedSites.pl $treeorderFile");

            } else {
                $outputLine .= "\t\t\t\t";
            }
        }
        print $outfile_fh "$outputLine\n";
        if ($combinedOutputFile) {print $overallOutputFile_fh "$outputLine\n";}
    }
    if ($combinedOutputFile) {print $overallOutputFile_fh "\n";}
    close $outfile_fh;
}
if ($combinedOutputFile) {close $overallOutputFile_fh;}

############# subroutines - not sure whether I'm still using all of these

sub printHeaderRows {
    my $fh = $_[0];
    my $BEB = $_[1];
    print $fh "seqFile\tnumSeqs\tseqLenNT\tseqLenCodons\tmodel\tresultsDir\t";
    print $fh "codonModel\tstartingOmega\tcleanData\t";
    print $fh "lnL\tnp\ttest\t2diffML\tdf\tpValue\tkappa\ttreeLen\ttreeLen_dN\ttreeLen_dS\toverallOmega\t";
    print $fh "proportionSelectedSites\testimatedOmegaOfSelectedClass\tseqToWhichSiteCoordsRefer\tnumSitesBEBover$BEB\twhichSitesBEBover$BEB\n";
}

### put together the output I've collected using other subroutines
sub paml_output {
    my %pamlResults = %{$_[0]};
    my %pamlStats = %{$_[1]};
    my $dirName = $_[2];
    my $numDinucleotidesMasked = $_[3];
    my $outputLine;
    my @allmodels = ("M0","M1","M2","M7","M8","M8a");
    if ( (defined $pamlResults{'M0'}{'warnings'}) || 
         (defined $pamlResults{'M1'}{'warnings'}) || 
         (defined $pamlResults{'M2'}{'warnings'}) || 
         (defined $pamlResults{'M7'}{'warnings'}) || 
         (defined $pamlResults{'M8'}{'warnings'}) || 
         (defined $pamlResults{'M8a'}{'warnings'})) {
        my $warningString = "";
        for my $model (@allmodels) {
            if (defined $pamlResults{$model}{'warnings'}) {
                $warningString .= "; $model: $pamlResults{$model}{'warnings'}";
            }
        }
        $outputLine = "\tPROBLEM $warningString";
    } else {
        my $numNT = $pamlResults{'M0'}{'numcodons'} * 3;
        $outputLine = "\t$pamlResults{'M0'}{'numseqs'}\t$pamlResults{'M0'}{'numcodons'}\t$numNT\t$numDinucleotidesMasked\t";
        $outputLine .= "$pamlResults{'M0'}{'treelength'}\t$pamlResults{'M0'}{'treelength_dN'}\t$pamlResults{'M0'}{'treelength_dS'}\t$pamlResults{'M0'}{'kappa'}\t$pamlResults{'M0'}{'overallOmega'}\t";
        for my $model (@allmodels) {
            $outputLine .= "$pamlResults{$model}{'lnL'}\t$pamlResults{$model}{'np'}\t";
        }
        $outputLine .= "$pamlStats{'M2_M1_2ML'}\t$pamlStats{'M2_M1_pval'}\t";
        $outputLine .= "$pamlStats{'M8_M7_2ML'}\t$pamlStats{'M8_M7_pval'}\t";
        $outputLine .= "$pamlStats{'M8_M8a_2ML'}\t$pamlStats{'M8_M8a_pval'}";
    }
    return($outputLine);
}

### figure out 2ML and p-value, given the lnL for each model
sub paml_stats {
    my %pamlResults = %{$_[0]};
    my %M0hash = %{$pamlResults{"M0"}};
    my %M1hash = %{$pamlResults{"M1"}};
    my %M2hash = %{$pamlResults{"M2"}};
    my %M7hash = %{$pamlResults{"M7"}};
    my %M8hash = %{$pamlResults{"M8"}};
    my %M8ahash = %{$pamlResults{"M8a"}};
    my %pamlStats;
    ## check for  paml failures
    my $allPAMLsWorked = "yes";
    if (defined $M0hash{'warnings'}) {
        if ($M0hash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if (defined $M1hash{'warnings'}) {
        if ($M1hash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if (defined $M2hash{'warnings'}) {
        if ($M2hash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if (defined $M7hash{'warnings'}) {
        if ($M7hash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if (defined $M8hash{'warnings'}) {
        if ($M8hash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if (defined $M8ahash{'warnings'}) {
        if ($M8ahash{'warnings'} eq "FAILED!!!") { $allPAMLsWorked = "no"; }
    }
    if ($allPAMLsWorked eq "no") {
        $pamlStats{'M2_M1_2ML'} = "paml_failed";
        $pamlStats{'M8_M7_2ML'} = "paml_failed";
        $pamlStats{'M8_M8a_2ML'} = "paml_failed";
        $pamlStats{'M2_M1_npDiff'} = "paml_failed";
        $pamlStats{'M8_M7_npDiff'} = "paml_failed";
        $pamlStats{'M8_M8a_npDiff'} = "paml_failed";
        $pamlStats{'M2_M1_pval'} = "paml_failed";
        $pamlStats{'M8_M7_pval'} = "paml_failed";
        $pamlStats{'M8_M8a_pval'} = "paml_failed";
    } else {
        $pamlStats{'M2_M1_2ML'} = 2 * ($M2hash{'lnL'} - $M1hash{'lnL'});
        $pamlStats{'M8_M7_2ML'} = 2 * ($M8hash{'lnL'} - $M7hash{'lnL'});
        $pamlStats{'M8_M8a_2ML'} = 2 * ($M8hash{'lnL'} - $M8ahash{'lnL'});
        $pamlStats{'M2_M1_npDiff'} = $M2hash{'np'} - $M1hash{'np'};
        $pamlStats{'M8_M7_npDiff'} = $M8hash{'np'} - $M7hash{'np'};
        $pamlStats{'M8_M8a_npDiff'} = $M8hash{'np'} - $M8ahash{'np'};
        $pamlStats{'M2_M1_pval'} =  Statistics::Distributions::chisqrprob ($pamlStats{'M2_M1_npDiff'},$pamlStats{'M2_M1_2ML'});
        $pamlStats{'M8_M7_pval'} =  Statistics::Distributions::chisqrprob ($pamlStats{'M8_M7_npDiff'},$pamlStats{'M8_M7_2ML'});
        $pamlStats{'M8_M8a_pval'} =  Statistics::Distributions::chisqrprob ($pamlStats{'M8_M8a_npDiff'},$pamlStats{'M8_M8a_2ML'});
        #if (defined %{$pamlResults{"M0fixNeutral"}}) {
        if (%{$pamlResults{"M0fixNeutral"}}) {
            my %M0fixhash = %{$pamlResults{"M0fixNeutral"}};
            $pamlStats{'M0_M0fix_2ML'} = 2 * ($M0hash{'lnL'} - $M0fixhash{'lnL'});
            $pamlStats{'M0_M0fix_npDiff'} = $M8hash{'np'} - $M8ahash{'np'};
            $pamlStats{'M0_M0fix_pval'} =  Statistics::Distributions::chisqrprob ($pamlStats{'M0_M0fix_npDiff'},$pamlStats{'M0_M0fix_2ML'});
        }
    }
    return(\%pamlStats);
}

### read the mlc file, and get the bits of the output I'm interested in
sub parse_paml {
    my $file = $_[0];
    my $model = $_[1];
    #print "    model $model\n";
    #my $seenBranchLineYet = "no";
    my $seenTimeUsedLineYet = "no";
    if (!-e $file) {
        die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl in parse_paml subroutine - cannot open mlc file $file\n\n";
    }
    open (MLC, "< $file");
    my $problem = "no";
    my %pamlResults;
    $pamlResults{'file'} = $file;
    while (<MLC>) {
        my $line = $_; chomp $line;
        
        ## I use the 'Time used' line that should appear at the end of the file to check that the PAML run worked
        if ($line =~ m/^Time\sused:\s/) { $seenTimeUsedLineYet = "yes"; }
        
        ## I am checking for a rooted tree - that's unlikely
        if ($line =~ m/^This\sis\sa\srooted\stree/) {
            print "    WARNING - rooted tree used for PAML!!!\n";
            $problem = "yes";
            $pamlResults{'warnings'} = "not a rooted tree";
        }
        if ($line =~ m/^omega\s/) { ### only M0 output has a line that looks like this
            #print "        found an omega line : looks like M0\n";
            my $omega = (split /\s+/, $line)[3];
            $pamlResults{'overallOmega'} = $omega;
        }
        #### num seqs and num codons
        if ($line =~ m/^ns\s=/) {
            #print "        found a numseqs line\n";
            if (defined $pamlResults{'numseqs'}) {
                print "   WARNING - found ns line TWICE in file $file\n";
            } else {
                my $numseqs = (split /\s+/, $line)[2];
                my $numcodons = (split /\s+/, $line)[5];
                $pamlResults{'numseqs'} = $numseqs;
                $pamlResults{'numcodons'} = $numcodons;
            }
        }
        #### tree length
        if ($line =~ m/^tree\slength\s\=/) {
            #print "        found a treelength line\n";
            if (defined $pamlResults{'treelength'}) {
                print "   WARNING - found tree length TWICE in file $file\n";
            } else {
                my $treelen = $line;$treelen =~ s/^tree\slength\s=\s+//;
                $pamlResults{'treelength'} = $treelen;
            }
        }
        if ($line =~ m/^tree\slength\sfor\sdN/) { ### only M0 output has a line that looks like this
            #print "        found a dN treelength line\n";
            my $treelen_dN = (split /\s+/, $line)[4];
            $pamlResults{'treelength_dN'} = $treelen_dN;
        }
        if ($line =~ m/^tree\slength\sfor\sdS/) { ### only M0 output has a line that looks like this
            #print "        found a dS treelength line\n";
            my $treelen_dS = (split /\s+/, $line)[4];
            $pamlResults{'treelength_dS'} = $treelen_dS;
        }
        #### lnL and np
        if ($line =~ m/^lnL/) {
            #print "        found an lnL line\n$line\n";
            if (defined $pamlResults{'lnL'}) {
                print "   WARNING - found lnL TWICE in file $file\n";
            } else {
                ## need to cope with lines that look like either one of these lines:
                # lnL(ntime: 23  np: 26):  -6966.055017      +0.000000
                # lnL(ntime:107  np:110):  -8172.781787      +0.000000
                
                ### before changing script to cope with second type of line:
                #my $lnl = (split /\s+/, $line)[4];
                #my $np = (split /\s+/, $line)[3];
                #$np =~ s/[\):]//g;
                
                ### after changing script to cope with second type of line:
                my $lnl = (split /:/, $line)[3];
                $lnl = (split /\s+/, $lnl)[1];
                my $np = (split /:/, $line)[2];
                $np =~ s/[\):]//g;
                
                #print "            lnl $lnl np $np blah\n";
                $pamlResults{'lnL'} = $lnl;
                $pamlResults{'np'} = $np;
            }
        }
        #### kappa
        if ($line =~ m/^kappa/) {
            #print "        found a kappa line\n";
            if (defined $pamlResults{'kappa'}) {
                print "   WARNING - found kappa TWICE in file $file\n";
            } else {
                my $kappa = $line;
                $kappa =~ s/^kappa\s\(ts\/tv\)\s=\s+//;
                $pamlResults{'kappa'} = $kappa;
            }
        }
        ###### parameters of the omega distributions - this won't be found for M0
        if ($line =~ m/^p\:/) {
            #print "        found an omega distribution p line\n";
            my @p = split /\s+/, $line; shift @p;
            $pamlResults{'p'} = join ",", @p;
        }
        if ($line =~ m/^w\:/) {
            #print "        found an omega distribution w line\n";
            my @w = split /\s+/, $line; shift @w;
            $pamlResults{'w'} = join ",", @w;
        }
    }  ## end of "while (<MLC>)" loop
    close MLC;
    if ($seenTimeUsedLineYet eq "no") {
        print "    PROBLEM - paml failed!!!!! model $model file $file\n\n";
        $pamlResults{'warnings'} = "FAILED!!!";
    }
    return(\%pamlResults);
}

#### paml_BEB_results : get the proportion of selected sites, the omega of the selected sites, and the identity of the selected sites, and the name of the first seq in the alignment that the coordinates refer to

sub paml_BEB_results {
    my $file = $_[0];
    if (!-e $file) {
        die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl in paml_BEB_results subroutine - file $file does not exist\n\n";
    }
    my %M8results;
    open (MLC, "< $file");
    my $inM8parametersSection = "no";
    my $inBEBsection = "no";
    while (<MLC>) {
        my $line = $_; chomp $line;
        #### get proportion and omega of selected sites
        if ($line =~ m/^Parameters\sin\sM8/) {
            $inM8parametersSection = "yes";
            next;
        }
        if ($inM8parametersSection eq "yes") {
            if ($line eq "") {
                $inM8parametersSection = "no";
                next;
            }
        }
        if ($inM8parametersSection eq "yes") {
            if ($line =~ m/p1/) {
                my $p1 = (split /\s+/, $line)[3];
                $p1 =~ s/\)//;
                my $w = (split /\s+/, $line)[6];
                $M8results{'p1'} = $p1;
                $M8results{'w'} = $w;
            }
        }
        #### get BEB results
        if ($line =~ m/^Bayes\sEmpirical\sBayes\s/) {
            $inBEBsection = "yes";
            next;
        }
        if ($inBEBsection eq "yes") {
            if ($line =~ m/^The\sgrid/) {
                $inBEBsection = "no";
                next;
            }
        }
        if ($inBEBsection eq "yes") {
            if ($line eq "") {next;}
            if ($line =~ m/^Positively/) {next;}
            if ($line =~ m/post\smean/) {next;}
            if ($line =~ m/^\(amino\sacids\srefer\sto/) {
                my $refSeq = (split /\s/, $line)[6];
                $refSeq =~ s/\)//;
                $M8results{'refSeq'} = $refSeq;
                next;
            }
            my @g = split /\s+/, $line;
            my $prob = $g[3];
            $prob =~ s/\*//g;
            if ($prob < $BEBprobThresholdToPrintSelectedSite) {
                next;
            }
            my $site = "$g[1]"."_$g[2]"."_$prob";
            if (!defined $M8results{'sites'}) {
                @{$M8results{'sites'}} = ($site);
            } else {
                push @{$M8results{'sites'}}, $site;
            }
        }
    }
    return(\%M8results);
}

sub plot_omegas {
    my $pamlDir = $_[0];
    my $outfileStem = $_[1];
    my $pamlResultsRef = $_[2];
    my %pamlResults2 = %$pamlResultsRef;
    my $allModelsRef = $_[3];
    my @allmodels = @$allModelsRef;
    ### call an R script that displays the distributions of omega:
    my $omegaDistributionsPlotFile = "$outfileStem.omegaDistributions.pdf";
    #print "   omegaDistributionsPlotFile $omegaDistributionsPlotFile\n";

    if (!-e $omegaDistributionsPlotFile) {
        print "    plotting omega distributions for $pamlDir\n";
        my $Rcommand = "";
        for my $model (@allmodels) {
            if ($model eq "M0fixNeutral") { next; }
            if ($model eq "M0") {
                $Rcommand .= " $model"."_p=1";
                $Rcommand .= " $model"."_w=$pamlResults2{$model}{'overallOmega'}";
            } else {
                $Rcommand .= " $model"."_p=$pamlResults2{$model}{'p'}";
                $Rcommand .= " $model"."_w=$pamlResults2{$model}{'w'}";
            }
        } 
        $Rcommand = "Rscript $masterPipelineDir/scripts/pw_plotOmegaDistributions.R outputPlotFile=$omegaDistributionsPlotFile myTitle=$pamlDir $Rcommand >> $pamlDir/plotOmegaDistributions.logfile.Rout 2>&1";
        system($Rcommand);
    }
}


sub plot_tree {
    my $treefile = $_[0];
    if (!-e $treefile) {
        die "\n\nERROR - terminating in script pw_parsePAMLoutput.pl in plot_tree subroutine - cannot find gene tree file $treefile\n\n";
    }
    my $treefileShortName = $treefile;
    if ($treefileShortName =~ m/\//) {
        $treefileShortName = (split /\//, $treefileShortName)[-1];
    }
    my $outfile = "$treefile.pdf";
    if (!-e $outfile) {
        print "    drawing gene tree\n";
        my $Routfile1 = "$treefile.treeplot.Rout";
        my $command1 = "$RscriptExecutable $masterPipelineDir/scripts/pw_plottree.R ";
        $command1 .= "myCex=1 plotbootstrap=FALSE myTitle=$treefileShortName $treefile > $Routfile1 2>&1";
        system("$command1");
    }
}

