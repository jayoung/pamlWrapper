#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use POSIX qw/ceil/;
use POSIX qw/floor/;

die "\n\nTerminating - this script is just a stub - if I actually want to use it I need to work on it. I copied it";


#### my old version of pw_parsedPAMLconvertToWideFormat.pl would combine results for pairs of alignments - unmasked and CpG-masked, putting results side-by-side. From June 2024 onwards I want to keep that script simple, with one row per input alignment file, so that I can easily use it in batch mode where I'm only running one alignment at a time.  So MAYBE I'll want a script that takes the wide.tsv files (one row per alignment) and makes them "wider". Maybe I'd base it on this script but I haven't bothered yet.



#### old stuff below here

###### works on the output of pp_parsePAMLoutput.pl to convert it into "wide" table format, where each gene has only a single row
## simple usage: 
# pw_parsedPAMLconvertToWideFormat.pl list17_HultquistFinalList_PAMLsummary.tsv 

## but add command line options if desired:
# --tree to include total tree length (total, dN, dS) in the output. before June 17 2019 I did not, and I might want to mimic that in future, so default is no
# --genename=no to prevent attempt to parse input file name to get gene name. Useful e.g. if I have run PAML on GARD segments of the same gene.  In this case I output the entire file name in the gene name column

## examples:
# pw_parsedPAMLconvertToWideFormat.pl list17_HultquistFinalList_PAMLsummary.tsv 
# pw_parsedPAMLconvertToWideFormat.pl --tree list17_HultquistFinalList_PAMLsummary.tsv 


## this version of the script is capable of looking for two alignments for each gene, with and without CpG masking

## xxx to do - add another column that's the selected sites in a less ugly format
## xxx I might be able to add BH-corrected p-values in this script (see https://metacpan.org/pod/Statistics::Multtest) but for now I will open the output in R and do it


############# get the command line options and check them 
## set defaults for each option
my $includeCpGMasked = 0; ## I mostly DO want to look for corresponding results on CpG-masked versions of the alignments, but not always (e.g. if I have run PAML on multiple GARD segments of the same gene, and did not do masked)
my $ignoreCpGmasking = 1; ## perhaps now I mostly want to run this in a very simple mode, where I just convert long output to wide output, ignoreing whether or not the alignment is CpG masked.  I've made this more complex than it needs to be by having two options $includeCpGMasked and $ignoreCpGmasking. Should think a bit about the situations where I want to run this. Right now I'm making this work best for situations where I run the entire pipeline on single alignments individually, and don't want to try to find and combine the masked and unmasked results for the same gene.

my $splitGeneName = 0; ## I mostly DO want to get gene name by splitting up input file name, but not always (e.g.. if I have run PAML on multiple GARD segments of the same gene)
my $figureOutSegmentPositions = ''; ## in the unusual case I ran PAML on GARD segments I might want to know segment name,startNT,endNT,startAA,endAA

my $scriptName = "pw_parsedPAMLconvertToWideFormat.pl";

## GetOptions syntax:  https://perldoc.perl.org/Getopt/Long.html
GetOptions ( "cpg=i"        => \$includeCpGMasked, 
             "ignore_cpg=i" => \$ignoreCpGmasking, 
             "genename=i"   => \$splitGeneName, 
             "segname"      => \$figureOutSegmentPositions) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";

################

## xx add some arg checking, perhaps, as not all combinations make sense togeter
## xx right now, if I don't figure out gene name (like if I'm running on GARD segments), I've got no way to combine the masked and unmasked runs for the same alignment. I need to replace $gene tag with $unmaskedAlignmentName

## xx make a separate script that would combine results for masked/unmasked, if desired


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

        my $thisAlignmentName = $thisLineHash{'seqFile'}; 
        my $correspondingUnmaskedAlignmentName = $thisAlignmentName;
        $correspondingUnmaskedAlignmentName =~ s/\.removeCpGinframe//;
        
        my $geneName = $thisAlignmentName; 
        if ($splitGeneName == 1) {
            if ($geneName =~ m/_/) { 
                $geneName = (split /_/, $geneName)[0];
            }
        }
        my $mask = "unmasked"; 
        #print "line $line geneName $geneName\n";
        if ($ignoreCpGmasking == 0) {
            if ($thisAlignmentName =~ m/removeCpGinframe/) { $mask = "masked"; }
        }
        my $mod = $thisLineHash{'model'};
        my $codon = $thisLineHash{'codonModel'};
        my $omega = $thisLineHash{'startingOmega'};
        my $clean = $thisLineHash{'cleanData'}; 

        my $alnName = $geneName;
        if ($splitGeneName == 0) {
            $alnName = $correspondingUnmaskedAlignmentName;
        }
        if (defined $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}) {
            print "    WARNING - already saw results for gene $geneName $mask $mod - did you intend to use the --genename=no option to suppress parsing gene name from file name?\n\n";
        }
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"treeFile"} = $thisLineHash{'treeFile'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"pamlVersion"} = $thisLineHash{'pamlVersion'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"numSeqs"} = $thisLineHash{'numSeqs'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"alnLenNT"} = $thisLineHash{'seqLenNT'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"alnLenAA"} = $thisLineHash{'seqLenCodons'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"resultsDir"} = $thisLineHash{'resultsDir'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"lnL"} = $thisLineHash{'lnL'};
        $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"np"} = $thisLineHash{'np'};

        ## record special output for M0 - overall dN/dS and total tree length
        if ($mod eq "M0") {
            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"tot_treeLen"} = $thisLineHash{'treeLen'};
            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"dN_treeLen"} = $thisLineHash{'treeLen_dN'};
            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"dS_treeLen"} = $thisLineHash{'treeLen_dS'};
            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"overall_dNdS"} = $thisLineHash{'overallOmega'};
        }

        ## record output if this line reflects a statistical test
        # if ($numFields < 15) {next;} ## used to have this line, but I think I can replace by if (defined $thisLineHash{'test'})
        if (defined $thisLineHash{'test'}) {
            if  ($thisLineHash{'test'} ne "") {
                my $test = $thisLineHash{'test'}; 
                my $diffML2 = $thisLineHash{'2diffML'}; 
                my $pVal = $thisLineHash{'pValue'}; 
                $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$test}{"diffML2"} = $diffML2;
                $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$test}{"pVal"} = $pVal;
                ## if it's the M8 line and the test was signif, I record results about number of selected sites
                #if (($numFields >= 24) & ($mod eq "M8")) { ## used to have this line, but I think the "if ($thisLineHash{'test'} ne "")" conditional takes care of it.
                if ($mod eq "M8") {
                    if (defined $thisLineHash{'proportionSelectedSites'}) {
                        if ($thisLineHash{'proportionSelectedSites'} ne "") {
                            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"percentSelected"} = 100*$thisLineHash{'proportionSelectedSites'}; 
                            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"dNdSselected"} = $thisLineHash{'estimatedOmegaOfSelectedClass'}; 
                            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"numSitesBEB_90"} = $thisLineHash{'numSitesBEBover0.9'}; 
                            $results{$alnName}{$mask}{$codon}{$omega}{$clean}{$mod}{"sitesBEB_90"} = $thisLineHash{'whichSitesBEBover0.9'}; 
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
    print OUT "seqFile\ttreeFile\tpamlVersion";
    # all species
    print OUT "\tnum seqs\tcodon model\tinitial omega\tcleandata";
    printHeaderFieldsEachAnalysis("");
    if ($includeCpGMasked == 1) {
        printHeaderFieldsEachAnalysis("CpGmask ");
    }
    print OUT "\n";

    ### print results for each gene
    foreach my $gene (sort keys %results) {
        #print "\ngetting results for gene $gene\n";
        #print "gene $gene\n";
        my @allCodons = sort keys %{$results{$gene}{'unmasked'}};
        foreach my $thisCodon (@allCodons) {
            my @allOmegas = sort keys %{$results{$gene}{'unmasked'}{$thisCodon}};
            foreach my $thisOmega (@allOmegas) {
                #print "    thisOmega $thisOmega\n";
                #print "    thisCodon $thisCodon\n";
                my @allCleans = sort keys %{$results{$gene}{'unmasked'}{$thisCodon}{$thisOmega}};
                foreach my $thisClean (@allCleans) {
                    # print "gene $gene thisOmega $thisOmega thisCodon $thisCodon thisClean $thisClean\n"; 
                    # if (!defined $results{$gene}{'unmasked'}{$thisCodon}{$thisOmega}{$thisClean}) {
                    #     print "    PROBLEM!\n"
                    # }
                    # die;

                    print OUT "$gene";
                    print OUT "\t$results{$gene}{'unmasked'}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'treeFile'}";
                    print OUT "\t$results{$gene}{'unmasked'}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'pamlVersion'}";
                    print OUT "\t$results{$gene}{'unmasked'}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'numSeqs'}"; 
                    print OUT "\t$thisCodon";
                    print OUT "\t$thisOmega";
                    print OUT "\t$thisClean";
                    printResults("unmasked", $gene, $thisOmega, $thisCodon, $thisClean, \%results);
                    if ($includeCpGMasked == 1) {
                        printResults("masked", $gene, $thisOmega, $thisCodon, $thisClean, \%results);
                    }
                    print OUT "\n";
                }# end of foreach my $thisClean loop
            } # end of foreach my $thisCodon loop
        } # end of foreach my $thisOmega loop
    } # end of foreach my $gene loop
    close OUT;
}

############ 
sub printHeaderFieldsEachAnalysis {
    my $prefix = $_[0];
    if ($figureOutSegmentPositions) {
        my @h0 = ("segment name", "segment start (nt)", "segment end (nt)", "segment start (aa)", "segment end (aa)");
        foreach my $h0 (@h0) {print OUT "\t". $prefix . $h0;}
    }
    my @h1 = ("numNT", "numAA");
    foreach my $h1 (@h1) {print OUT "\t". $prefix . $h1;}

    my @h2 = ("M0 overall dN/dS", "M0 lnL", "M0fix lnL", "M0vsM0fixed pVal");
    foreach my $h2 (@h2) {print OUT "\t". $prefix . $h2;}

    my @h3 = ("M0 total tree length", "M0 total dN tree length", "M0 total dS tree length");
    foreach my $h3 (@h3) {print OUT "\t". $prefix . $h3;}

    my @h3a = ("M1 lnL", "M2 lnL", "M7 lnL", "M8 lnL", "M8a lnL");
    foreach my $h3a (@h3a) {print OUT "\t". $prefix . $h3a;}

    my @h4 = ("M8vsM8a 2xlnL", "M8vsM8a pVal", "M8vsM7 2xlnL", "M8vsM7 pVal", "M2vsM1 2xlnL","M2vsM1 pVal", "M8 percent sites under positive selection", "M8 dN/dS of selected sites", "M8 num sites with BEB >=0.9", "M8 which sites have BEB >=0.9");
    foreach my $h4 (@h4) {print OUT "\t". $prefix . $h4;}
}

sub printResults {
    my $masked = $_[0];
    my $gene = $_[1];
    my $thisOmega = $_[2];
    my $thisCodon = $_[3];
    my $thisClean = $_[4];
    my $resultsRef = $_[5];
    my %results = %$resultsRef;
    
    if ($figureOutSegmentPositions) {
        my $seg = "";
        my $segStart = "";
        my $segEnd = "";
        my $segStartAA = "";
        my $segEndAA = "";
        if ($gene !~ m/_seg/) {
            print "    WARNING - you asked me to figure out segment positions, but the input file name $gene does not contain _seg\n";
        } else {
            my $segString = (split /_seg/, $gene)[1];
            $segString =~ s/\.fa$//; $segString = "seg".$segString;
            $segString =~ s/.removeCpGinframe//;
            ($seg,$segStart,$segEnd) = split /[-_]/, $segString;
        ## ceiling and floor because seg names contain start and end of GARD segs, whereas the actual segment seqs I output were rounded off to the nearest codon boundary
            $segStartAA = ceil(1+($segStart-1)/3);
            $segEndAA = floor($segEnd/3);
            #print "\ngene $gene masked $masked seg $seg segStart $segStart segEnd $segEnd segStartAA $segStartAA segEndAA $segEndAA\n"; 
        }
        print OUT "\t$seg\t$segStart\t$segEnd\t$segStartAA\t$segEndAA";
    }
    
    if (!defined $results{$gene}{$masked}) {
        die "\n\nERROR - terminating in script $scriptName - no results for gene $gene with mask setting $masked - maybe you want to use the --cpg=no option while parsing??\n\n";
    }
    
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'alnLenNT'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'alnLenAA'}";

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'overall_dNdS'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0fixNeutral'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0_M0fix'}{'pVal'}";

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'tot_treeLen'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'dN_treeLen'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M0'}{'dS_treeLen'}";

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M1'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M2'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M7'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'lnL'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8a'}{'lnL'}";

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M8a'}{'diffML2'}"; 
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M8a'}{'pVal'}"; 

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M7'}{'diffML2'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8_M7'}{'pVal'}";

    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M2_M1'}{'diffML2'}";
    print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M2_M1'}{'pVal'}";

    if (defined $results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'percentSelected'} ) {
        print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'percentSelected'}";
        print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'dNdSselected'}";
        print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'numSitesBEB_90'}";
        print OUT "\t$results{$gene}{$masked}{$thisCodon}{$thisOmega}{$thisClean}{'M8'}{'sitesBEB_90'}";
    } else { 
        print OUT "\t\t\t\t";
    }
}
