#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
# use POSIX qw/ceil/;
# use POSIX qw/floor/;


###### works on the output of pw_combineParsedOutfilesWide.pl to take pairs of results, for corresponding unmasked and CpG alignments, and to put the output on a single row
## simple usage: 
# pw_wideFormatCombineUnmaskedAndMaskedResults.pl zz_allAlignments.PAMLsummaries.codon2_omega0.4_clean0.wide.tsv

#### my old version of pw_parsedPAMLconvertToWideFormat.pl would combine results for pairs of alignments - unmasked and CpG-masked, putting results side-by-side. From June 2024 onwards I want to keep that script simple, with one row per input alignment file, so that I can easily use it in batch mode where I'm only running one alignment at a time.  So MAYBE I'll want a script that takes the wide.tsv files (one row per alignment) and makes them "wider". Maybe I'd base it on this script but I haven't bothered yet.

my $splitGeneName = 1;

############# get the command line options and check them

my $scriptName = "pw_wideFormatCombineUnmaskedAndMaskedResults.pl";

# ## GetOptions syntax:  https://perldoc.perl.org/Getopt/Long.html
GetOptions ( #"cpg=i"        => \$includeCpGMasked, 
             #"ignore_cpg=i" => \$ignoreCpGmasking, 
             "genename=i"   => \$splitGeneName# , 
             # "segname"      => \$figureOutSegmentPositions
             ) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";


################
print "\nTaking wide-format parsed PAML output, and combining unmasked and masked rows for the same gene\n\n";

foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - cannot open file $file\n\n";
    }
    print "    working on file $file\n";
    ### go through input file and collect info for all genes
    my %results; # first key = gene name
                 # second key = masked or unmasked.
                 # rest = whole results line
    open (IN, "< $file");
    my @headerFields;
    while (<IN>) {
        my $line = $_; chomp $line;
        if ($line eq "") {next;} ## empty lines
        if ($line =~ m/^tsvFile\tseqFile\ttreeFile/) {
            @headerFields = split /\t/, $line;
            my $numHeaderFields = @headerFields;
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
            $thisLineHash{ $headerFields[$i] } = $f[$i];
        }

        my $thisAlignmentName = $thisLineHash{'seqFile'}; 
        # my $correspondingUnmaskedAlignmentName = $thisAlignmentName;
        # $correspondingUnmaskedAlignmentName =~ s/\.removeCpGinframe//;
        
        my $geneName = $thisAlignmentName; 
        if ($splitGeneName == 1) {
            if ($geneName =~ m/_/) { 
                $geneName = (split /_/, $geneName)[0];
            }
        }
        ## is it masked or unmasked
        my $mask = "unmasked"; 
        if ($thisAlignmentName =~ m/removeCpGinframe/) { $mask = "masked"; }

        # print "\nline $line masked $mask geneName $geneName\n";

        ## record results
        $results{$geneName}{$mask} = $line;

    } ## end of while (<IN>) loop
    close IN;


    #### old stuff below here
    # xxxx

    #print "\n###### making output file\n";
    ### now make output file
    my $out = $file; $out =~ s/\.tsv$//; 
    $out .= ".combineMasking.tsv";
    
    open (OUT, "> $out");

    #### print header:
    print OUT "gene\t";
    # unmasked
    print OUT join "\t", @headerFields;
    # masked
    foreach my $h (@headerFields) { print OUT "\tCpGmask_$h"; }
    print OUT "\n";

    ### print results for each gene
    foreach my $gene (sort keys %results) {
        if(!defined $results{$gene}{'unmasked'}) {
            die "\n\nTerminating - gene $gene does not have unmasked results\n\n";
        }
        print OUT "$gene\t";
        print OUT $results{$gene}{'unmasked'};
        print OUT "\t";
        if(!defined $results{$gene}{'masked'}) {
            die "\n\nTerminating - gene $gene does not have masked results\n\n";
        }
        print OUT $results{$gene}{'masked'};
        print OUT "\n";
    }
}

print "\nDone.\n\n";