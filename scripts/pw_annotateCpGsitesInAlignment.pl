#!/usr/bin/perl

use warnings;
use strict;
use Bio::SeqIO;

# looks for pairs of columns from alignment where any sequence has a CpG at that position
# output files. makes an annotated alignment file - with one additional sequence that contains X for CpG residues and - for others 

my $dinucAnnotation = "NN";

################## script begins below

foreach my $infile (@ARGV) {
    if (!-e $infile) { die "\n\nterminating - file $infile does not exist\n\n"; }
    if (-z $infile) {
        print "    WARNING - skipping file $infile, as it is empty\n";
        next;
    }
    print "\n#### working on file $infile\n";
    my $outfile = $infile;
    $outfile =~ s/\.fasta$//; $outfile =~ s/\.fa$//; 
    $outfile .= ".annotateCpG.fa";
    if (-e $outfile) {
        print "skipping file $infile - outfile $outfile already exists\n"; 
        next;
    }
    
    my $seqIN = Bio::SeqIO->new(-file => "$infile", '-format' => 'Fasta');
    #go through sequences the first time and read them in (the hash called sequences will be a hash of arrays, values is the seq object)
    my %sequences;
    my $prevseqlength = "dummy";
    while (my $thisseq = $seqIN->next_seq()) {
        my $seqname = $thisseq->display_id();
        my $sequence = $thisseq->seq();
        my $length = $thisseq->length();
        if ($prevseqlength ne "dummy") {
            if ($length != $prevseqlength) {die "\n\nterminating - seqlengths are different - perhaps run makeseqssamelength.pl on the alignment first. got to $seqname. length is $length and prev length was $prevseqlength\n\n";}
        }
        $prevseqlength = $length;
        ### check for seeing a sequence twice
        if (defined $sequences{$seqname}) {
            die "\n\nterminating - seeing sequence name $sequence twice in the file - script is not set up to deal with this\n\n";
        }
        $sequences{$seqname} = $thisseq;
    }
    
    #### make an "annotation" line to add to the alignment, where CpG residues are marked with XX and non-CpGs are simply gaps  use $prevseqlength
    my $annotationLine = "";
    for (my $i=1; $i<=$prevseqlength; $i++) { $annotationLine .= "-"; }
    my $tempLen = length $annotationLine;
    
    #now go through each dinucleotide in alignment and if at least one CpG, replace with the replacement character
    for (my $dinucStart=0;$dinucStart<($prevseqlength-2);$dinucStart++) {
        my $anyCpG = "no";
        foreach my $seq (keys %sequences) {
            my $thisDinuc = $sequences{$seq}->seq;
            $thisDinuc = substr($thisDinuc, $dinucStart, 2);
            if (($thisDinuc eq "CG") || ($thisDinuc eq "cg")) {
               $anyCpG = "yes";
            }
        }
        if ($anyCpG eq "no") {next;}
        substr($annotationLine, $dinucStart, 2, $dinucAnnotation);
    }
    # to annotate the CpGs, I start with the input alignment, and simply add one more seq row that contains the annotations
    system("cp $infile $outfile");
    my $seqOUTannot = Bio::SeqIO->new(-file => ">> $outfile", '-format' => 'Fasta');
    my $annotatedSeq = Bio::Seq->new(-display_id=>"CpGdinucleotides", -seq=>$annotationLine);
    $seqOUTannot->write_seq($annotatedSeq);
}

