#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

#### simple perl script to strip branch lengths out from a tree (phyml format)

my $addFirstLine = 0;  ## newer version of PAML seems more picky about the tree format, wanting a first line in the file that tells (a) how many species and (b) how many trees. I add that first line in order to avoid this error: "Error: end of tree file.."  

my $scriptName = "pw_removeBranchLengthsFromTree.pl";

GetOptions("addFirstLine=i"  => \$addFirstLine) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";             
                

##################

foreach my $treeOutfile (@ARGV) {
    if (!-e $treeOutfile) { die "\n\nERROR - terminating in script $scriptName - file $treeOutfile does not exist\n\n";}
    if (-z $treeOutfile) {
        die "\n\nERROR - terminating in script $scriptName - tree file is empty, perhaps phyml failed\n\n";
    }
    

    ## remove branch lengths
    my $treeWithoutBranches = "$treeOutfile.nolen";
    open (IN, "< $treeOutfile") || die "\n\nERROR - terminating in script $scriptName - couldn't open file $treeOutfile\n\n";
    open (OUT, "> $treeWithoutBranches");
    ## sometimes we need to add a new first line to the tree file ("  numSeqs numTrees\n")
    if ($addFirstLine == 1) {
        # we look inside the original alignment file to get the num seqs
        my $originalAlnFile = $treeOutfile;
        $originalAlnFile =~ s/_phyml_tree$//;
        if (!-e $originalAlnFile) {
            die "\n\nERROR - terminating in script $scriptName - you're asking me to add the first line to the tree file, but I can't figure out what the original alignment file was called\n\n";
        }
        my $numSeqs = `head -1 $originalAlnFile`;
        chomp $numSeqs; $numSeqs =~ s/^\s+//;
        $numSeqs = (split /\s+/, $numSeqs)[0];
        # we look inside the tree file to get the num trees
        my $numTrees = `wc $treeOutfile`;
        chomp $numTrees; $numTrees =~ s/^\s+//; 
        $numTrees = (split /\s+/, $numTrees)[0];
        print OUT "  $numSeqs $numTrees\n";
    }
    while (<IN>) {
        my $line = $_;
        $line =~ s/\:[\d\.]+\,/\,/g;
        $line =~ s/\:[\d\.]+\)/\)/g;
        $line =~ s/\:\-[\d\.]+\)/\)/g;
        print OUT $line;
    }
    close IN;
    close OUT;
}
