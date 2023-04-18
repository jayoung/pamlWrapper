#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

### takes seqs in myAln.fa and reorders them in same order as tree file myAln.tree.nwk.  Checks for an alias file (myAln.fa.aliases.txt), because sometimes seqs got renamed to get rid of weird characters before tree was made

my $verbose = 0; ## 1 for verbose, 0 for not.

my $scriptName = "pw_reorderseqs_treeorder.pl";

#------------------------------------
if (@ARGV != 2) {die "\n\nERROR - terminating in script $scriptName - expecting two arguments: (1) seq file (2) tree file\n\n";}
if (!-e $ARGV[0]) {die "\n\nERROR - terminating in script $scriptName - can't open seq file $ARGV[0]\n\n";}
if (!-e $ARGV[1]) {die "\n\nERROR - terminating in script $scriptName - can't open seq file $ARGV[1]\n\n";}

my $out = $ARGV[0];  $out =~ s/\.fasta$//; $out =~ s/\.fa$//;
$out .= ".treeorder.fa";

### read in the tree and figure out the order
if ($verbose == 1) { print "\n\nReading tree from $ARGV[1]\n"; }
open (TREE, "< $ARGV[1]");
my @lines = <TREE> ;
close TREE;

### now that PAML newer version requires an additional first line in the tree file (containing numTaxa and numTrees), we need to get rid of that first line for this purpose:
shift @lines;

### check there's just one tree
my @check = grep /\;/, @lines;
my $numSemicolonLines = @check;
if ($numSemicolonLines > 1) {die "\n\nERROR - terminating in script $scriptName - looks like there is more than one tree in file $ARGV[1]\n\n";}
if ($numSemicolonLines < 1) {die "\n\nERROR - terminating in script $scriptName - looks like there is no tree in file $ARGV[1]\n\n";}

### parse the tree to get seqnames in order
my $tree = join "", @lines;
$tree =~ s/[\(\)\n]//g; $tree =~ s/\n//g;
my @seqnames = split /\,/, $tree;
if ($verbose == 1) { print "### Parsing tree:\n"; print "$tree\n"}

foreach my $seq (@seqnames) {
    if ($seq =~ m/\:/) {$seq = (split /\:/, $seq)[0];}
    #$seq =~ s/\'//g; ### I had this line previously - if the original seqfile had seqnames with ' character, this script fails
    $seq =~ s/;//g;
    if ($verbose == 1) { print "     $seq\n"; }
}
my $num = @seqnames;
#print "\n";

### if there's an alias file, read it:
my $aliasFile = "$ARGV[0].aliases.txt";
my %aliases; # key = second value, the seqname used for the tree, value = first column, the original name
if (-e $aliasFile) {
    if ($verbose == 1) { print "### Reading alias file $aliasFile\n"; }
    open (ALIAS, "< $aliasFile");
    while (<ALIAS>) {
        my $line = $_; chomp $line;
        my @f = split /\t/, $line;
        $aliases{$f[1]} = $f[0];
        if ($verbose == 1) { print "     tree $f[1] seq $f[0]\n"; }
    }
    close ALIAS;
}

### now read in the sequence file
my %seqs;
my $seqstream = Bio::SeqIO->new(-file => "$ARGV[0]", '-format' => 'Fasta');
my $thisseq = "temp";
if ($verbose == 1) { print "\n\n### Reading seqs from $ARGV[0]\n"; }
while ($thisseq ne "") {
    my $thisseq = $seqstream ->next_seq() || last;
    my $header = $thisseq->display_id();
    $seqs{$header} = $thisseq;
    if ($verbose == 1) { print "     $header\n"; }
   #print "seq in the seqfile $header blah\n";
}

my $numseqs = keys(%seqs);
if ($num < $numseqs) {print "\n\nWARNING - there are $num seqs in the tree and $numseqs seqs in the file. Should match. Proceeding anyway - will just get the seqs in the tree file\n\n";}
if ($num > $numseqs) {die "\n\nERROR - terminating in script $scriptName - there are $num seqs in the tree and $numseqs seqs in the file. That means some seqs in the tree are missing from seqs file\n\n";}

### now output seqs, in order
if ($verbose == 1) { print "\n\nWriting seqs to $out\n"; }
my $seqio = new Bio::SeqIO(-file => ">$out", -format => 'Fasta');
foreach my $name (@seqnames) {
    my $thisseq;
    if (defined $aliases{$name}) { 
        $name = $aliases{$name}; 
    }
    if ($verbose == 1) { print "     looking for seq $name\n"; }
    if (defined ($seqs{$name})) { 
        $thisseq = $seqs{$name}; 
    }  else { 
       my $tryanothername = $name; $tryanothername =~ s/\.frame1pep\.fasta//;
       if (defined ($seqs{$tryanothername})) {$thisseq = $seqs{$tryanothername};} 
       if (!defined ($seqs{$tryanothername})) {die "\n\nERROR - terminating in script $scriptName - can't find seq $name or $tryanothername in the seq file\n\n";}
    }
    $seqio->write_seq($thisseq);  
}

