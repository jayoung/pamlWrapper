#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

#takes seqs in file1 and reorders them in same order as tree file file2

my $verbose = 0; ## 1 for verbose, 0 for not.

#------------------------------------
if (@ARGV != 2) {die "\n\nterminating - expecting two arguments: (1) seq file (2) tree file\n\n";}
if (!-e $ARGV[0]) {die "\n\nterminating - can't open seq file $ARGV[0]\n\n";}
if (!-e $ARGV[1]) {die "\n\nterminating - can't open seq file $ARGV[1]\n\n";}

#read in the tree and figure out the order
if ($verbose == 1) { print "\n\nReading tree from $ARGV[1]\n"; }
open (TREE, "< $ARGV[1]");
my @lines = <TREE> ;
close TREE;

#check there's just one tree
my @check = grep /\;/, @lines;
if (@check > 1) {die "\n\nterminating - looks like there is more than one tree in file $ARGV[1]\n\n";}
if (@check < 1) {die "\n\nterminating - looks like there is no tree in file $ARGV[1]\n\n";}

my $tree = join "", @lines;
$tree =~ s/[\(\)\n]//g;$tree =~ s/\n//g;
my @seqnames = split /\,/, $tree;
foreach my $seq (@seqnames) {
    if ($seq =~ m/\:/) {$seq = (split /\:/, $seq)[0];}
    $seq =~ s/\'//g;$seq =~ s/;//g;
    if ($verbose == 1) { print "     $seq\n"; }
}
my $num = @seqnames;
#print "\n";

#now read in the sequence file
my %seqs;
my $seqstream = Bio::SeqIO->new(-file => "$ARGV[0]", '-format' => 'Fasta');
my $thisseq = "temp";
if ($verbose == 1) { print "\n\nReading seqs from $ARGV[0]\n"; }
while ($thisseq ne "") {
    my $thisseq = $seqstream ->next_seq() || last;
    my $header = $thisseq->display_id();
    $seqs{$header} = $thisseq;
    if ($verbose == 1) { print "     $header\n"; }
   #print "seq in the seqfile $header blah\n";
}

my $numseqs = keys(%seqs);
if ($num < $numseqs) {print "\n\nWARNING - there are $num seqs in the tree and $numseqs seqs in the file. Should match. Proceeding anyway - will just get the seqs in the tree file\n\n";}
if ($num > $numseqs) {die "\n\nterminating - there are $num seqs in the tree and $numseqs seqs in the file. That means some seqs in the tree are missing from seqs file\n\n";}

#now output seqs, in order

my $out = "$ARGV[0]".".treeorder";
if ($verbose == 1) { print "\n\nWriting seqs to $out\n"; }
my $seqio = new Bio::SeqIO(-file => ">$out", -format => 'Fasta');
foreach my $name (@seqnames) {
    my $thisseq;
    if (defined ($seqs{$name})) {$thisseq = $seqs{$name};} 
    else { 
       my $tryanothername = $name; $tryanothername =~ s/\.frame1pep\.fasta//;
       if (defined ($seqs{$tryanothername})) {$thisseq = $seqs{$tryanothername};} 
       if (!defined ($seqs{$tryanothername})) {die "\n\nterminating - can't find seq $name or $tryanothername in the seq file\n\n";}
    }
    $seqio->write_seq($thisseq);  
}

