#!/usr/bin/perl

use warnings;
use strict;

#### simple perl script to strip branch lengths out from a tree (phyml format)

my $scriptName = "pw_removeBranchLengthsFromTree.pl";

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
