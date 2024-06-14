#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use POSIX qw/ceil/;
use POSIX qw/floor/;


## see pw_wideFormatCombineUnmaskedAndMaskedResults.pl for the old version of this script, where I combined results for pairs of alignments (unmasked and CpG-masked). Now I keep it simple and just do one row per input alignment.

###### works on the output of pp_parsePAMLoutput.pl to convert it into "wide" table format, where each gene has only a single row
## simple usage: 
# pw_parsedPAMLconvertToWideFormat.pl ACE2_primates_aln1_NT.codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv

## but add command line options if desired:
# --tree to include total tree length (total, dN, dS) in the output. before June 17 2019 I did not, and I might want to mimic that in future, so default is no
# --genename=1 to attempt to parse input file name to get gene name. Useful e.g. if I have run PAML on GARD segments of the same gene.  In this case I output the entire file name in the gene name column

## examples:
# pw_parsedPAMLconvertToWideFormat.pl ACE2_primates_aln1_NT.codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
# pw_parsedPAMLconvertToWideFormat.pl --tree ACE2_primates_aln1_NT.codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv


## this version of the script is capable of looking for two alignments for each gene, with and without CpG masking

## xxx to do - add another column that's the selected sites in a less ugly format

############# get the command line options and check them 
## set defaults for each option

my $splitGeneName = 0; ## I often DO want to get gene name by splitting up input file name, but not always (e.g. if I have run PAML on multiple GARD segments of the same gene, it's useful)
my $figureOutSegmentPositions = 0; ## in the unusual case I ran PAML on GARD segments I might want to know segment name,startNT,endNT,startAA,endAA

my $scriptName = "pw_parsedPAMLconvertToWideFormat.pl";

## GetOptions syntax:  https://perldoc.perl.org/Getopt/Long.html
GetOptions ( "genename=i"   => \$splitGeneName, 
             "segname=i"    => \$figureOutSegmentPositions) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";

################

foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - cannot open file $file\n\n";
    }
    print "    converting parsed PAML output to wide format\n";
    ### go through input file and collect info for all genes
    my %results; # first key = gene name. 
                 # second key = species set: all or noNWM
                 # third key = masked or unmasked.
                 # fourth key = paml test
                 # rest = results
    open (IN, "< $file");
    my %warningsIssued; ## warns about each alignment file analyzed that I decided to ignore. keep track of which warnings I already issued.
    my @headerFieldNames;
    while (<IN>) {
        my $line = $_; chomp $line;
        if ($line eq "") {next;} ## empty lines
        if ($line =~ m/^seqFile\ttreeFile/) {
            @headerFieldNames = split /\t/, $line;
            my $numHeaderFields = @headerFieldNames;
            #print "\nheader line\n\n$line\n\n";
            #print "processed header - found $numHeaderFields fields\n";
            next;
        } ## header
        #print "line $line\n";
        my @f = split /\t/, $line; my $numFields = @f;

        ## put the values in a hash using the header names as keys, so that I don't need to rely on the order of the fields, which might change
        my %thisLineHash;
        for (my $i=0;$i<$numFields;$i++) {
            if(!defined $f[$i]) {next;}
            $thisLineHash{ $headerFieldNames[$i] } = $f[$i];
        }

        ## name of the alignment file is very useful:
        ## get that, and other useful things, from the line
        my $alnName = $thisLineHash{'seqFile'}; 
        my $mod = $thisLineHash{'model'};
        my $codon = $thisLineHash{'codonModel'};
        my $omega = $thisLineHash{'startingOmega'};
        my $clean = $thisLineHash{'cleanData'}; 
        ## check whether we already collected results for this combination of inputs
        if (defined $results{$alnName}{$codon}{$omega}{$clean}{$mod}) {
            die "\n\nERROR - terminating in script $scriptName - already saw results for aln $alnName model $mod - this script is not designed to handle that (not any more, anyway)\n\n";
        }
        
        ## add all the other results
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"treeFile"} = $thisLineHash{'treeFile'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"pamlVersion"} = $thisLineHash{'pamlVersion'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"numSeqs"} = $thisLineHash{'numSeqs'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"alnLenNT"} = $thisLineHash{'seqLenNT'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"alnLenAA"} = $thisLineHash{'seqLenCodons'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"resultsDir"} = $thisLineHash{'resultsDir'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"lnL"} = $thisLineHash{'lnL'};
        $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"np"} = $thisLineHash{'np'};

        ## record special output for M0 - overall dN/dS and total tree length
        if ($mod eq "M0") {
            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"tot_treeLen"} = $thisLineHash{'treeLen'};
            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"dN_treeLen"} = $thisLineHash{'treeLen_dN'};
            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"dS_treeLen"} = $thisLineHash{'treeLen_dS'};
            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"overall_dNdS"} = $thisLineHash{'overallOmega'};
        }

        ## record output if this line reflects a statistical test
        # if ($numFields < 15) {next;} ## used to have this line, but I think I can replace by if (defined $thisLineHash{'test'})
        if (defined $thisLineHash{'test'}) {
            if  ($thisLineHash{'test'} ne "") {
                my $test = $thisLineHash{'test'}; 
                my $diffML2 = $thisLineHash{'2diffML'}; 
                my $pVal = $thisLineHash{'pValue'}; 
                $results{$alnName}{$codon}{$omega}{$clean}{$test}{"diffML2"} = $diffML2;
                $results{$alnName}{$codon}{$omega}{$clean}{$test}{"pVal"} = $pVal;
                ## if it's the M8 line and the test was signif, I record results about number of selected sites
                #if (($numFields >= 24) & ($mod eq "M8")) { ## used to have this line, but I think the "if ($thisLineHash{'test'} ne "")" conditional takes care of it.
                if ($mod eq "M8") {
                    if (defined $thisLineHash{'proportionSelectedSites'}) {
                        if ($thisLineHash{'proportionSelectedSites'} ne "") {
                            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"percentSelected"} = 100*$thisLineHash{'proportionSelectedSites'}; 
                            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"dNdSselected"} = $thisLineHash{'estimatedOmegaOfSelectedClass'}; 
                            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"numSitesBEB_90"} = $thisLineHash{'numSitesBEBover0.9'}; 
                            $results{$alnName}{$codon}{$omega}{$clean}{$mod}{"sitesBEB_90"} = $thisLineHash{'whichSitesBEBover0.9'}; 
                        }
                    }
                }
            }
        }
    }
    close IN;
    #print "\n###### making output file\n";
    ### now make output file
    my $out = $file; $out =~ s/\.tsv$//; $out .= ".wide";
    $out .= ".tsv";
    
    open (OUT, "> $out");
    ### print header:
    if ($splitGeneName == 1) { print OUT "gene\t"; }
    print OUT "seqFile\ttreeFile\tpamlVersion";
    # all species
    print OUT "\tnum seqs\tcodon model\tinitial omega\tcleandata";
    printHeaderFieldsEachAnalysis();
    print OUT "\n";

    ### print results for each aln file
    foreach my $alnFile (sort keys %results) {
        #print "\ngetting results for alnFile $alnFile\n";
        ## maybe we get the gene name from the aln name
        my $geneName = $alnFile; 
        if ($splitGeneName == 1) {
            if ($geneName =~ m/_/) { 
                $geneName = (split /_/, $geneName)[0];
            }
        }

        ## get results of each analysis type (codon+omega+cleandata combination)
        my @allCodons = sort keys %{$results{$alnFile}};
        foreach my $thisCodon (@allCodons) {
            my @allOmegas = sort keys %{$results{$alnFile}{$thisCodon}};
            foreach my $thisOmega (@allOmegas) {
                #print "    thisOmega $thisOmega\n";
                #print "    thisCodon $thisCodon\n";
                my @allCleans = sort keys %{$results{$alnFile}{$thisCodon}{$thisOmega}};
                foreach my $thisClean (@allCleans) {
                    # print "alnFile $alnFile thisOmega $thisOmega thisCodon $thisCodon thisClean $thisClean\n"; 
                    # if (!defined $results{$alnFile}{$thisCodon}{$thisOmega}{$thisClean}) {
                    #     print "    PROBLEM!\n"
                    # }
                    # die;
                    if ($splitGeneName == 1) {
                        print OUT "$geneName\t";
                    }
                    print OUT "$alnFile";
                    print OUT "\t$results{$alnFile}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'treeFile'}";
                    print OUT "\t$results{$alnFile}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'pamlVersion'}";
                    print OUT "\t$results{$alnFile}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'numSeqs'}"; 
                    print OUT "\t$thisCodon";
                    print OUT "\t$thisOmega";
                    print OUT "\t$thisClean";
                    printResults($alnFile, $thisOmega, $thisCodon, $thisClean, \%results);
                    print OUT "\n";
                }# end of foreach my $thisClean loop
            } # end of foreach my $thisCodon loop
        } # end of foreach my $thisOmega loop
    } # end of foreach my $alnFile loop
    close OUT;
}

############ 
sub printHeaderFieldsEachAnalysis {
    if ($figureOutSegmentPositions) {
        my @h0 = ("segment name", "segment start (nt)", "segment end (nt)", "segment start (aa)", "segment end (aa)");
        foreach my $h0 (@h0) {print OUT "\t". $h0;}
    }
    my @h1 = ("numNT", "numAA");
    foreach my $h1 (@h1) {print OUT "\t". $h1;}

    my @h2 = ("M0 overall dN/dS", "M0 lnL", "M0fix lnL", "M0vsM0fixed pVal");
    foreach my $h2 (@h2) {print OUT "\t". $h2;}

    my @h3 = ("M0 total tree length", "M0 total dN tree length", "M0 total dS tree length");
    foreach my $h3 (@h3) {print OUT "\t". $h3;}

    my @h3a = ("M1 lnL", "M2 lnL", "M7 lnL", "M8 lnL", "M8a lnL");
    foreach my $h3a (@h3a) {print OUT "\t". $h3a;}

    my @h4 = ("M8vsM8a 2xlnL", "M8vsM8a pVal", "M8vsM7 2xlnL", "M8vsM7 pVal", "M2vsM1 2xlnL","M2vsM1 pVal", "M8 percent sites under positive selection", "M8 dN/dS of selected sites", "M8 num sites with BEB >=0.9", "M8 which sites have BEB >=0.9");
    foreach my $h4 (@h4) {print OUT "\t". $h4;}
}

sub printResults {
    my $aln = $_[0];
    my $thisOmega = $_[1];
    my $thisCodon = $_[2];
    my $thisClean = $_[3];
    my $resultsRef = $_[4];
    my %results = %$resultsRef;
    if ($figureOutSegmentPositions) {
        my $seg = "";
        my $segStart = "";
        my $segEnd = "";
        my $segStartAA = "";
        my $segEndAA = "";
        if ($aln !~ m/_seg/) {
            print "    WARNING - you asked me to figure out segment positions, but the input file name $aln does not contain _seg\n";
        } else {
            my $segString = (split /_seg/, $aln)[1];
            $segString =~ s/\.fa$//; $segString = "seg".$segString;
            ($seg,$segStart,$segEnd) = split /[-_]/, $segString;
            ## ceiling and floor because seg names contain start and end of GARD segs, whereas the actual segment seqs I output were rounded off to the nearest codon boundary
            $segStartAA = ceil(1+($segStart-1)/3);
            $segEndAA = floor($segEnd/3);
            #print "\naln $aln masked $masked seg $seg segStart $segStart segEnd $segEnd segStartAA $segStartAA segEndAA $segEndAA\n"; 
        }
        print OUT "\t$seg\t$segStart\t$segEnd\t$segStartAA\t$segEndAA";
    }
    
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'alnLenNT'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'alnLenAA'}";

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'overall_dNdS'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0fixNeutral'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0_M0fix'}{'pVal'}";

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'tot_treeLen'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'dN_treeLen'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'dS_treeLen'}";

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M1'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M2'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M7'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'lnL'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8a'}{'lnL'}";

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M8a'}{'diffML2'}"; 
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M8a'}{'pVal'}"; 

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M7'}{'diffML2'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M7'}{'pVal'}";

    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M2_M1'}{'diffML2'}";
    print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M2_M1'}{'pVal'}";

    if (defined $results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'percentSelected'} ) {
        print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'percentSelected'}";
        print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'dNdSselected'}";
        print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'numSitesBEB_90'}";
        print OUT "\t$results{$aln}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'sitesBEB_90'}";
    } else { 
        print OUT "\t\t\t\t";
    }
}
