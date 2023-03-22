#!/usr/bin/perl

use warnings;
use strict;
use Bio::SeqIO;
use Bio::PrimarySeq; ## specifically loading it, so I can redefine a subroutine

#removes columns from alignment if all sequences have a gap at that position
#also checks whether there are any codons at all where more than one seq has bases

#this version only removes whole codons

#### do I want to keep codons where only one sequence has anything?
#### before June 4th, 2013, I was requiring >1 sequence had something
my $minSeqsWithoutGap = 1;

################## script begins below

if (@ARGV==0) {
    die "\n\nterminating - please specify one or more alignment files\n\n";
}

foreach my $infile (@ARGV) {
    if (!-e $infile) { die "\n\nterminating - file $infile does not exist\n\n"; }
    if (-z $infile) {next;}
    my $outfile = "$infile" . ".degapcodon";
    my $seqIN = Bio::SeqIO->new(-file => "$infile", '-format' => 'Fasta');
    my @orderedseqs;
    #go through sequences the first time and read them in(the hash called sequences will be a hash of arrays, three letter per position)
    my %sequences;
    my $prevseqlength = "dummy";
    while (my $thisseq = $seqIN->next_seq()) {
        my $seqname = $thisseq->display_id();
        my $sequence = $thisseq->seq();
        push @orderedseqs, $seqname;
        my $length = $thisseq->length();
        if ($prevseqlength ne "dummy") {
            if ($length != $prevseqlength) {die "\n\nterminating - seqlengths are different - perhaps run makeseqssamelength.pl on the alignment first. got to $seqname. length is $length and prev length was $prevseqlength\n\n";}
        }
        $prevseqlength = $length;
        ### check for seeing a sequence twice
        if (defined $sequences{$seqname}) {
            die "\n\nterminating - seeing sequence name $sequence twice in the file - script is not set up to deal with this\n\n";
        }
        for (my $i=0;$i<$length;$i+=3) { 
            my $codon = substr($sequence,$i,3);
            push @{$sequences{$seqname}}, $codon;
        }
    }
    #now go through each position in alignment and if at least one non-gap character, add to string in the new hash, newseqs
    my $numgoodcodons = 0;
    my %newseqs; my $numcodons;
    foreach my $key1 (keys %sequences) {
        $newseqs{$key1} = "";
       $numcodons = @{$sequences{$key1}};
    }
    for (my $j=0;$j<$numcodons;$j++) {
        my $good = 0; my $numgoodseqs = 0;
        #go through all seqs at that position - if at least one is not "---" and not "???" the codon is good to add to the alignment
        foreach my $key2 (keys %sequences) {
            if ((@{$sequences{$key2}}[$j] ne "---")&(@{$sequences{$key2}}[$j] ne "???")){
                $good = 1;$numgoodseqs++; 
                next;
            }
        }
        if ($numgoodseqs >= $minSeqsWithoutGap) {
            if ($good == 1) {$numgoodcodons++;}
            foreach my $key3 (keys %sequences) {
                $newseqs{$key3} .= @{$sequences{$key3}}[$j];
            } 
        }
    }
    if ($numgoodcodons==0) {print "\n\t\tWARNING - skipping alignment $infile - no overlapping codons\n\n";next;}

    my $seqOUT = Bio::SeqIO->new(-file => "> $outfile", '-format' => 'Fasta');
    foreach my $key4 (@orderedseqs) {
        my $letters = $newseqs{$key4};
        my $seq = Bio::Seq->new(-display_id=>$key4, -seq=>$letters, -alphabet=>"dna");
        $seqOUT->write_seq($seq);
    }
}


### my version of validate_seq, to avoid issues caused by the ! characters
{ no warnings 'redefine';
    sub Bio::PrimarySeq::validate_seq {
        my ($self,$seqstr) = @_;
        if( ! defined $seqstr ){ $seqstr = $self->seq(); }
        return 0 unless( defined $seqstr);
        my $MATCHPATTERN = 'A-Za-z\-\.\*\?=~\!';
        if ((CORE::length($seqstr) > 0) &&
            ($seqstr !~ /^([$MATCHPATTERN]+)$/)) {
            $self->warn("JY seq doesn't validate, mismatch is " .
                    ($seqstr =~ /([^$MATCHPATTERN]+)/g));
                return 0;
        }
        return 1;
     }
}


