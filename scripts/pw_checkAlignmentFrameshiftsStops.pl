#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;

my $scriptName = "pw_checkAlignmentFrameshiftsStops.pl";

### check each seq of an in-frame alignment for internal stop codons and frameshifts
my $exitCode = 0;
foreach my $file (@ARGV){
    if (!-e $file) { die "\n\nERROR - terminating in script $scriptName - cannot open file $file\n\n"; }
    print "    checking for stops/frameshifts in file $file\n";
    my $seqIN = Bio::SeqIO->new(-file => "< $file", '-format' => 'fasta');
    while (my $seq = $seqIN ->next_seq) {
        my $len = $seq->length(); 
        my $header = $seq->display_id();

        ### check for stop codons. We only count stop codons that have at least one non-gap codon afterwards
        my $numInternalsStops = 0;
        my $haveAstopCodonWeMightCount = 0; # seeing a stop codon flips this to 1. Seeing a non-gap codon after it triggers us to count it and reset this to 0.
        for (my $i=1; $i<$len; $i=$i+3) {
            my $thisCodon = uc($seq->subseq($i, ($i+2)));
            if ($thisCodon ne "---") {
                if ($haveAstopCodonWeMightCount) { $numInternalsStops++; $haveAstopCodonWeMightCount = 0; $exitCode = 1;}
            }
            if ($thisCodon =~ m/TGA|TAG|TAA/) {
                $haveAstopCodonWeMightCount = 1;
            }
        }

        ### check gaps in the alignment, testing whether the length of each is a multiple of 3
        my $GAPon = 0; my $GAPstart; my $GAPend;
        my $numFrameshifts = 0;
        for (my $i=1;$i<=$len;$i++) {
            my $thisNuc = uc($seq->subseq($i, $i));
            if (($thisNuc =~ m/-/i) & ($GAPon == 0)) { # the beginning of a gap
                $GAPstart = $i; $GAPon = 1;
            }   
            if (($thisNuc !~ m/-/i) & ($GAPon == 1)) { # the end of a gap
                $GAPend = $i - 1; $GAPon = 0;
                my $gapSize = $GAPend + 1 - $GAPstart;
                if (($gapSize % 3) != 0) { 
                    # for this purpose I think I don't care about frameshifting gaps at the start of the seq.
                    if ($GAPstart != 1) { $numFrameshifts++; }
                    $exitCode = 1;
                }
            }        
        } 
        #### I was initially going to test if we're in a gap at the end of the seq, but for this purpose I think I don't care about frameshifting gaps at the end of the seq.
        # if ($GAPon == 1) { # the end of a gap
        #     $GAPend = $len;
        #     print "gap in seq $header\tstart $GAPstart\tend $GAPend\n";
        # }        

        if (($numInternalsStops > 0) || ($numFrameshifts > 0)) {
            print "        WARNING - seq $header had $numInternalsStops internal stops and $numFrameshifts frameshifting gaps\n";
        }

    }
}
exit($exitCode);
