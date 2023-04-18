#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;
use Bio::TreeIO;
use IO::String;

## we check that seq file and tree file contain the same seqs, with exactly the same names
# if not, we make the start of a name translation file 

my $scriptName = "pw_checkUserTree.pl";

###### 
my $exitCode = 0;

###### some checks before we start
if (@ARGV != 2) {
    die "\n\nERROR - terminating in script $scriptName - please provide two file names: (1) alignment (2) tree\n\n";
    $exitCode = 1;
}

my $alnFile = $ARGV[0];
my $treeFile = $ARGV[1];

if (!-e $alnFile) {
    die "\n\nERROR - terminating in script $scriptName - the alignment file you specified does not exist: $alnFile\n\n";
    $exitCode = 1;
}
if (!-e $treeFile) {
    die "\n\nERROR - terminating in script $scriptName - the alignment file you specified does not exist: $treeFile\n\n";
    $exitCode = 1;
}
print "    in $scriptName: checking seq names match between alignment file $alnFile and user-specified tree file $treeFile\n";

### get seq names from alignment
my @orderedSeqnames;
my %seqnameHash;
my $seqIN = Bio::SeqIO->new(-file => "< $alnFile", '-format' => 'fasta');
while (my $seq = $seqIN ->next_seq) {
    my $header = $seq->display_id();
    push @orderedSeqnames, $header;
    $seqnameHash{$header} = 1;
}
my $numSeqs = @orderedSeqnames;
#print "Alignment file has $numSeqs sequences\n";

### get taxon names from tree
my $numTrees = 0;
my $numLeaves;
my @treeIDs;
my %treeIDhash;

## used this before PAML required a first line containing num taxa and num trees
# my $treeIN = Bio::TreeIO->new(-format => "newick", -file   => "< $treeFile");

## now have to use much more code to get the tree ready to read, because we have to ingore that first line.:
open (TREE, "< $treeFile");
my @tree_lines = <TREE>;
close TREE;
my $numTreeLines = @tree_lines;
if ($numTreeLines != 2) {
    die "\n\nERROR - terminating in script $scriptName - the tree file should contain exactly two lines, but it has $numTreeLines line(s).  PAML 4.10.6 and above is more picky about this than older versions of PAML.  The first line should look something like this: '  22 1' (i.e., two spaces, the number of taxa in your tree, then one space, then 1, for the number of trees in the file), and the second line should contain the tree itself.: $treeFile\n\n";
    $exitCode = 1;
}
my $treeString = $tree_lines[1]; chomp $treeString;
my $treeIO = IO::String->new($treeString); 
my $treeIN = Bio::TreeIO->new(-format => "newick", -fh => $treeIO);

## look at the tree:
while( my $tree = $treeIN->next_tree ) {
    my @leaves = $tree->get_leaf_nodes();
    $numTrees++;
    foreach my $leaf (@leaves) {
        # print "leaf ID ", $leaf->id(), "\n";
        my $leafID = $leaf->id();
        push @treeIDs, $leafID;
        $treeIDhash{$leafID} = 1;
    }
    $numLeaves = @treeIDs;
}
if ($numTrees != 1) {
    die "\n\nERROR - terminating in script $scriptName - the tree file you specified contains $numTrees and we are expecting just 1 tree\n\n";
    $exitCode = 1;
}
#print "Tree has $numLeaves leaves\n";


### go through seqIDs and check whether they're present in the tree
my $countAlnSeqsNotInTree = 0;
my @alnSeqsNotInTree;
foreach my $seqname (@orderedSeqnames) {
    if (defined $treeIDhash{$seqname}) {
        $seqnameHash{$seqname} = $seqname;
    } else {
        $countAlnSeqsNotInTree++;
        push @alnSeqsNotInTree, $seqname;
    }
}


### go through treeIDs and check whether they're present in the alignment
my $countTreeTipsNotInAln = 0;
my @tipNamesNotInAln;
foreach my $tipname (@treeIDs) {
    if (defined $seqnameHash{$tipname}) {
        $treeIDhash{$tipname} = $tipname;
    } else {
        $countTreeTipsNotInAln++;
        push @tipNamesNotInAln, $tipname;
    }
}

### if the tree and the aln matched, all is well and we can exit
if (($countAlnSeqsNotInTree == 0) & ($countTreeTipsNotInAln == 0)) {
    print "        ... they match\n";
    exit $exitCode;
}

### if they DON'T match, we open a file where we show which ones match and which ones don't.
$exitCode = 1;
my $alnToTreeNameFile = $alnFile;
$alnToTreeNameFile =~ s/\.nwk$//; $alnToTreeNameFile =~ s/\.newick$//;
my $temp = $alnFile; $temp =~ s/\.fasta$//;$temp =~ s/\.fa$//;
$alnToTreeNameFile .= ".vs.$temp.nameTable.tsv";
open (OUT, "> $alnToTreeNameFile");
print OUT "seqID_alignment\tseqID_tree\n";
## first we print those that match
foreach my $seqID (sort @orderedSeqnames) {
    print OUT "$seqID\t$seqID\n";
}
## then we print IDs we found in the alignment file but not the tree file
foreach my $seqID (sort @alnSeqsNotInTree) {
    print OUT "$seqID\t\n";
}
## then we print IDs we found in the tree file but not the alignment file
foreach my $seqID (sort @tipNamesNotInAln) {
    print OUT "\t$seqID\n";
}
close OUT;

print "\n\nERROR - sequence names did NOT match between alignment file and tree file.\n";
print "    There were $countAlnSeqsNotInTree seqs in the alignment but not in the tree\n";
print "    There were $countTreeTipsNotInAln seqs in the tree but not in the alignment\n\n";
print "    The following file will show you which seqs did not match up:\n";
print "        $alnToTreeNameFile\n";
print "    If you edit that file to pair up names, you can use it as input to the script pw_changenamesinphyliptreefile.pl to swap names in the tree so that it matches the alignment.  Example command:\n";
my $temp2 = $alnToTreeNameFile; $temp2 =~ s/\.tsv$//;
print "        pw_changenamesinphyliptreefile.pl $treeFile $temp2.edited.txt\n";
print "\n";

exit $exitCode;

## exit codes - https://perlmaven.com/how-to-exit-from-perl-script 
#  exit codes contain 2 bytes: the actual exit code is in the upper byte. So in order to get back the 42 as above we have to right-shift the bits using the >> bitwise operator with 8 bits
# without the >> 8 translation, 0 is 0, 1 becomes 256, and 2 becomes 512
