#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

#### simple perl script to strip branch lengths out from a tree (phyml format)

my $addFirstLine = 0;  ## newer version of PAML seems more picky about the tree format, wanting a first line in the file that tells (a) how many species and (b) how many trees. I add that first line in order to avoid this error: "Error: end of tree file.."

## removeBootstraps - not tested super well yet. Works for my homing endonuclease project trees
my $removeBootstraps = 0;
my $verbose = 0;

my $scriptName = "pw_removeBranchLengthsFromTree.pl";

GetOptions("addFirstLine=i"     => \$addFirstLine,
           "removeBootstraps=i" => \$removeBootstraps,
           "verbose=i"          => \$verbose) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n";             
                

##################

foreach my $treeOutfile (@ARGV) {
    if (!-e $treeOutfile) { die "\n\nERROR - terminating in script $scriptName - file $treeOutfile does not exist\n\n";}
    if (-z $treeOutfile) {
        die "\n\nERROR - terminating in script $scriptName - tree file is empty, perhaps phyml failed\n\n";
    }

    if ($verbose) {
        print "## working on file $treeOutfile\n";
    }

    ## remove branch lengths
    my $treeWithoutBranches = "$treeOutfile.nolen";
    open (IN, "< $treeOutfile") || die "\n\nERROR - terminating in script $scriptName - couldn't open file $treeOutfile\n\n";
    open (OUT, "> $treeWithoutBranches");
    ## sometimes we need to add a new first line to the tree file ("  numSeqs numTrees\n")
    if ($addFirstLine == 1) {
        # we look inside the original alignment file to get the num seqs
        my $originalAlnFile = $treeOutfile;
        if ($originalAlnFile =~ m/_phyml_tree$/) {
            $originalAlnFile =~ s/_phyml_tree$//;
        }
        if ($originalAlnFile =~ m/_phyml_tree.txt$/) {
            $originalAlnFile =~ s/_phyml_tree.txt$//;
        }
        if ($originalAlnFile =~ m/_phyml_tree.txt.names$/) {
            $originalAlnFile =~ s/_phyml_tree.txt.names$//;
        }
        if ($originalAlnFile eq $treeOutfile) {
            die "\n\nERROR - terminating in script $scriptName - you're asking me to add the first line to the tree file, but I can't figure out what the original alignment file was called. I'm expecting it to end with '_phyml_tree' or '_phyml_tree.txt' or '_phyml_tree.txt.names'\n\n";
        }
        if (!-e $originalAlnFile) {
            die "\n\nERROR - terminating in script $scriptName - you're asking me to add the first line to the tree file, but I can't figure out what the original alignment file was called. I thought it would be called $originalAlnFile but that file doesn't exist\n\n";
        }
        if ($verbose) {
            print "    Getting num seqs from header line of the corresponding alignment file: $originalAlnFile\n";
        }
        # get the first line from the alignment file
        my $alnFileFirstLine = `head -1 $originalAlnFile`;
        my $numSeqs = $alnFileFirstLine;
        chomp $numSeqs; $numSeqs =~ s/^\s+//;
        # it shouldn't contain any non-number non-space characters
        my $numSeqsStripped = $numSeqs;
        $numSeqsStripped =~ s/\d//g;
        $numSeqsStripped =~ s/\s//g;
        if (length($numSeqsStripped)>0) {
            die "\n\nERROR - terminating in script $scriptName - I'm trying to get num seqs from the first line of the original alignment file, but it doesn't look right: $alnFileFirstLine\n\n";
        }
        $numSeqs = (split /\s+/, $numSeqs)[0];
        # we look inside the tree file to get the num trees
        my $numTrees = `wc $treeOutfile`;
        chomp $numTrees; $numTrees =~ s/^\s+//; 
        $numTrees = (split /\s+/, $numTrees)[0];
        print OUT "  $numSeqs $numTrees\n";
        if ($verbose) { print "        numSeqs $numSeqs numTrees $numTrees\n"; }
    }
    while (<IN>) {
        my $line = $_;
        $line =~ s/\:[\d\.]+\,/\,/g;
        $line =~ s/\:[\d\.]+\)/\)/g;
        $line =~ s/\:\-[\d\.]+\)/\)/g;
        if($removeBootstraps) {
            $line =~ s/\)[01]\.\d+/\)/g;
        }
        print OUT $line;
    }
    close IN;
    close OUT;
}
