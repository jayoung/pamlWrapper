#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;

## we check that:
#    all seqs are the same length
#    alignment length is a multiple of 3. 
#    there are no duplicate sequence names
#    there are >=2 seqs 
#      (if there are only 2 seqs, we need to make a fake tree and only run M0 and M0fix, but I think I'll do that back in the main script)

my $scriptName = "pw_checkAlignmentBasics.pl";

my $exitCode = 0;
foreach my $file (@ARGV){
    if (!-e $file) { die "\n\nERROR - terminating in script $scriptName - cannot open file $file\n\n"; }
    my $seqIN = Bio::SeqIO->new(-file => "< $file", '-format' => 'fasta');
    my %lengths; # key = seq length, values=seqnames with that length
    my %seqnames;
    my $numSeqs = 0;
    while (my $seq = $seqIN ->next_seq) {
        my $len = $seq->length(); 
        my $header = $seq->display_id();
        $numSeqs++;
        if (defined $seqnames{$header}) {
            print "\n    ERROR - sequence $header appears more than once in alignment file $file\n\n";
            $exitCode = 1;
        }
        $seqnames{$header}=1;
        push @{$lengths{$len}}, $header;
    }
    print "    checking num seqs in file $file\n";
    if ($numSeqs < 2) {
        print "\n    ERROR - there are only $numSeqs in alignment file $file - cannot run PAML\n";
        $exitCode = 1;
    } 
    print "    checking seqlengths in file $file\n";
    my $numDiffLengths = keys %lengths;
    if ($numDiffLengths > 1) {
        print "\n    ERROR - the sequences in alignment file $file are not all the same length\n\n\tLength\tSeqs\n";
        foreach my $length (sort keys %lengths) {
            my $seqString = join ",", @{$lengths{$length}};
            print "\t$length\t$seqString\n"
        }
        print "\n";
        $exitCode = 1;
    } else {
        # check length is an even multiple of 3
        my $alnLen = (keys %lengths)[0];
        if (($alnLen % 3) != 0) {
            print "\n    ERROR - alignment file $file has seq length $alnLen: this is not divisible by 3, indicating it is not an in-frame alignment. Cannot proceed with PAML\n\n";
            $exitCode = 1;
        }
    }
}
exit $exitCode;

## exit codes - https://perlmaven.com/how-to-exit-from-perl-script 
#  exit codes contain 2 bytes: the actual exit code is in the upper byte. So in order to get back the 42 as above we have to right-shift the bits using the >> bitwise operator with 8 bits
# without the >> 8 translation, 0 is 0, 1 becomes 256, and 2 becomes 512
