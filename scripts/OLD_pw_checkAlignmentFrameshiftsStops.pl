#!/usr/bin/perl

use warnings;
use strict;
use Bio::AlignIO;
use Bio::SeqIO;
use Getopt::Long;

##### input is a multiple sequence alignment, with a reference sequence that encodes a complete ORF as the first sequence. 
## default option is to deal with output of MACSE (--MACSE=1), which tries to align in-frame, and frameshifts are denoted by ! characters.
## if --MACSE=0, we expect maf converted to fasta, where alignments are often not in-frame at all (if there are indels in non-ref seqs)

## tests each other sequence for frameshifts w.r.t. the reference sequence, and stop codons that are not at the end of the sequence.
## I do tolerate frameshifts at the very beginning or very end of each aligned seq
## tests the reference seq for an intact ORF
## allows for a special case, PEG10, that has a programmed ribosome frameshift, and allows us to ignore frameshifts within a certain distance of the programmed frameshift
## tolerates stops near but not quite at the end (as well as AFTER end of ref seq) - tolerable distance is (by default) 60bp (20 codons)

# xxxx add an option to find one or more human seqs as the reference seq, and to take their average length as the reference sequence length (default is to take first seq as ref)


## output = four files: 
# noPseuds.fa = same alignment, without any pseudogenes
# pseudReportSummary.txt = num intact genes and pseudogenes
# pseudReportEachGene.txt = which genes are intact/pseuds
# pseudReportDetailed.txt = locations of stop codons/frameshifts in each pseudogene

# checkAlignmentFrameshiftsStops.bioperl PNMA3_NM_013364.refGene.100way.frags.2.combined.fa.degapped



#### defaults for command-line specifiable options:
our $stopCodonDistCheck = 60; ## stop codon is OK if it is within this distance from the end of the reference seq (also OK if any distance after the end of the reference seq)
our $alnIsMACSE = 1; ## 0 or 1, whether the alignment is output of MACSE aligner (so that frameshifts can be encoded by !)
our $minAlignedLengthProportion = 0.8; ## proportion of refseq len that the ungapped length of a a seq needs to cover - if it doesn't meet this threshold, it will be called 'truncated'
our $findFullLenRefSeqs = 0;  ## default is to take the first sequence in the alignment as the reference sequence, and to figure out minimum aligned lengths from that, but if we use -findFullLenSeqs=1 it will find any seqs labelled Homo_sapiens (or whatever string is specified using) and use that as reference length 
our $fullLenSeqRefString = "Homo_sapiens";
our $geneField = 0; ## 0-based count of which "_"-delimited field to find the gene name in, considering plain file name without dir.
our $supplyGeneName = 0;  # for one-off runs, where I constructed seq names differently and won't be able to find gene name automatically
our $manuallySuppliedGeneName = "undefined";

our $debug = 0;  ## to help figure things out

###### get any command line options

## get any non-default options from commandline
GetOptions("MACSE=i" => \$alnIsMACSE,
           "minLen=i" => \$minAlignedLengthProportion,
           "stopCodonDist=i" => \$stopCodonDistCheck,
           "findFullLenRefSeqs=i" => \$findFullLenRefSeqs,
           "fullLenSeqRefString=s" => \$fullLenSeqRefString,
           "geneField=i" => \$geneField,
           "supplyGeneName=i", => \$supplyGeneName,
           "geneName=s" => \$manuallySuppliedGeneName,
           "debug=i" => \$debug
            ) or die "\n\nterminating - unknown option(s) specified on command line\n\n";


########## script

if ($alnIsMACSE == 1) {
    print "\n\nParsing MACSE alignment - frameshifts should be denoted by ! characters\n\n";
} else {
    print "\n\nParsing non-MACSE alignment\n\n";
}


our $seqOUT;

foreach my $file (@ARGV){
    if (!-e $file) { die "\n\nterminating - cannot open file $file\n\n"; }
    print "\n#### working on file $file\n";
    ## gene should be the first part of the file name
    my $gene = "notDefined";
    if ($supplyGeneName == 0) {
        if ($file !~ m/_/) {
            print "    cannot figure out gene name from file name $file\n";
        } else {
            if ($file =~ m/\//) { 
                $gene = (split /\//, $file)[-1];
            } else { 
                $gene = $file; 
            }
            $gene = (split /_/, $gene)[$geneField];
            print "    gene $gene\n";
        }
    }
    if ($supplyGeneName == 1) {
        if ($manuallySuppliedGeneName eq "undefined") {
            die "\n\nterminating - you set supplyGeneName to 1, so you need to also specify name using -geneName=thisGeneName\n\n";
        }
        $gene = $manuallySuppliedGeneName;
        print "    gene $gene\n";
    }
    my $outStem = $file; $outStem =~ s/\.fasta$//; $outStem =~ s/\.fa$//;
    my $outSeqs = "$outStem.noPseuds.fa";
    my $outReportEachGene = "$outStem.pseudReportEachGene.txt";
    my $outReportOverallSummary = "$outStem.pseudReportSummary.txt";
    my $outReportDetails = "$outStem.pseudReportDetailed.txt";
    
    $seqOUT = Bio::SeqIO->new(-file => "> $outSeqs", '-format' => 'fasta');
    open (SUMMARY, "> $outReportOverallSummary");
    print SUMMARY "Gene_type\tCount\tFile\n";
    open (EACHGENE, "> $outReportEachGene");
    print EACHGENE "Seq\tPseud\tNum_frameshifts\tNum_stops\tUngapped_length\n";
    open (DETAILS, "> $outReportDetails");
    print DETAILS "Seq\tRegion_start_refCoord\tRegion_end_refCoord\tRegion_start_alnCoord\tRegion_end_alnCoord\tIndel_size\tRegion_type\n";
    
    my $refSeq = "NA"; my $refName;
    my $lengthThreshold;
    my $intactCounts = 0; my $pseudCounts = 0; my $truncatedCounts = 0;
    ## the ! in MACSE alignments made validate_seq complain, so I redefined that subroutine below
    my $alnIN = Bio::AlignIO->new(-file => "< $file",
                                 -alphabet => "dna", 
                                 -format => "fasta");
    while (my $aln = $alnIN -> next_aln) {
        if (! $aln->is_flush() ) {
            die "\n\nterminating - seqs in alignment are not all the same length - input file was $file\n\n";
        }
        my $alnLen = $aln->length();
        
        ## use gap_col_matrix to see where the alignment gaps are. Generates an array where each element in the array is a hash reference with a key of the sequence name and a value of 1 if the sequence has a gap at that column
        my $gapsRef;
        if ($alnIsMACSE==1) {
            $gapsRef = $aln->gap_col_matrix("-|!");
        } else {
            $gapsRef = $aln->gap_col_matrix();
        }
        my @gaps = @{$gapsRef}; my @seqBases; 
        
        ### process reference sequence(s)
        my ($refSeqNamesRef, $refSeqAverageLength, $refBasesRef, $ungappedRefLen, $refInfoRef) = getRefSeqs($aln, $gene);
        my %refInfo = %$refInfoRef;  # keys = status: pseud/intact
                     #        MACSEframeshifts (array of 0-based bp locations w.r.t. ref seq of any MACSE frameshifts (!)
                     #        inFrameStops (array of 0-based bp locations w.r.t. ref seq of any MACSE frameshifts (!)
        my @refSeqNames = @$refSeqNamesRef;
        my @refBases = @$refBasesRef;
        $lengthThreshold = $refSeqAverageLength * $minAlignedLengthProportion;
        my $rounded = sprintf("%.1f", $lengthThreshold);
        my $refName = $refSeqNames[0];
        print "ref seqs @refSeqNames length $refSeqAverageLength : length threshold is $rounded\n\n";
        
        ### iterate through each non-ref seq. We'll take the first of the ref seqs (if >1) as the one to measure length and frameshifts against
        ## go through the seqs
        foreach my $seq ( $aln->each_seq() ) {
            my $name = $seq->display_id();
            my $isArefSeq = "no";
            foreach my $refSeqName (@refSeqNames) {
                if ($refSeqName eq $name) {$isArefSeq = "yes";}
            }
            if ($isArefSeq eq "yes") { next; }
            
            ### check non-ref seqs against reference seq
            my $seqName = $seq->display_id();
            @seqBases = split //, $seq->seq();
            my $ungappedSeqLen = getUngappedLen($seq, $alnIsMACSE);
            if ($debug==1) { print "    got other seq $seqName ungappedSeqLen $ungappedSeqLen\n"; }
            ### iterate through alignment positions
            my $refPosition = 0; my $seqPosition = 0;
            my $refIsInAGap = ""; my $seqIsInAGap = "";
            my $refCharsWithinThisGapCount = 0; my $seqCharsWithinThisGapCount = 0;
            my $gapOpenPosRef; my $gapOpenPosAln;
            my $numFrameshifts = 0; my $numStops = 0;
            my $refCodon = ""; my $seqCodon = ""; ## these codons will be what's aligned to each codon in the ungapped ref seq
            #  then at each position of the alignment I will compare non-ref to ref, and see if they have the same or opposite gap status.  
            # If it's opposite, in whichever sequence has the 'insertion' relative to the other, I start counting non-gap characters, until the gap ends in the other seq. 
            # Once the gap ends, I total up the non-gap characters, and see if it's a multiple of three.
            for (my $i=0; $i<$alnLen; $i++) {
                my $refGapThisPos = ${$gaps[$i]}{$refName};
                my $seqGapThisPos = ${$gaps[$i]}{$seqName};
                ## for positions where ref is non-gap, update the codons
                if ($seqGapThisPos eq "") { $seqPosition++ ; }
                my $distFromSeqEnd = $ungappedSeqLen - $seqPosition;
                my $distFromRefEnd = $ungappedRefLen - $refPosition;
                
                #### if it is a MACSE alignment, we check for stop codons w.r.t. the in-frame alignment (if not we check below)
                if ($alnIsMACSE==1) {
                    $refCodon .= $refBases[$i];
                    $seqCodon .= $seqBases[$i];
                    ($refCodon, $seqCodon, $numStops) = checkForStopCodon($refCodon, $seqCodon, $refPosition, $distFromRefEnd, $i, $seqName, $numStops);
                }
                
                if ($refGapThisPos eq "") { 
                    #### if it is a non-MACSE alignment, we check for stop codons w.r.t the ungapped ref seq.
                    if ($alnIsMACSE==0) {
                        $refCodon .= $refBases[$i];
                        $seqCodon .= $seqBases[$i];
                        ($refCodon, $seqCodon, $numStops) = checkForStopCodon($refCodon, $seqCodon, $refPosition, $distFromRefEnd, $i, $seqName, $numStops);
                    }
                    $refPosition++;
                }
                
                #### open a gap in the ref seq w.r.t. the other seq
                if (($refIsInAGap eq "") & 
                    ($refGapThisPos eq "1") & 
                    ($refGapThisPos ne $seqGapThisPos)) {
                    if ($debug==1) {
                        print "        pos $i opening a gap in reference seq compared to $seqName\n";
                    }
                    $refIsInAGap = "1"; 
                    $gapOpenPosRef = $refPosition;
                    $gapOpenPosAln = $i + 1;
                }
                #### close a gap in the ref seq w.r.t. the other seq
                if (($refIsInAGap eq "1") & 
                    ($refGapThisPos eq "") & 
                    ($seqGapThisPos eq "")) {
                    if ($debug==1) {
                        print "        pos $i closing a gap in reference seq compared to $seqName\n";
                        print "            $seqName had $seqCharsWithinThisGapCount non-gap chars\n";
                    }
                    if (($seqCharsWithinThisGapCount % 3) != 0) {
                        $numFrameshifts = reportFrameshift($refPosition, $seqPosition, $i, $seqCharsWithinThisGapCount, $distFromSeqEnd, $gapOpenPosRef, $gapOpenPosAln, $numFrameshifts, "insertion", $seqName, $gene, \%refInfo);
                    }
                    $refIsInAGap = "";
                    $refCharsWithinThisGapCount = 0; ## reset
                    $seqCharsWithinThisGapCount = 0; ## reset
                }
                #### continue a gap in the ref seq w.r.t. the other seq
                if (($refIsInAGap eq "1") & 
                    ($refGapThisPos eq "1")) {
                    if ($debug==1) {
                        print "            pos $i continuing a gap in reference seq compared to $seqName\n";
                    }
                    if ($seqGapThisPos eq "") {$seqCharsWithinThisGapCount++;}
                }
                #### open a gap in this seq w.r.t. the ref seq
                if (($seqIsInAGap eq "") & 
                    ($seqGapThisPos eq "1") & 
                    ($refGapThisPos ne $seqGapThisPos)) {
                    if ($debug==1) {
                        print "        pos $i opening a gap in $seqName compared to ref\n";
                    }
                    $seqIsInAGap = "1"; 
                    $gapOpenPosRef = $refPosition; 
                    $gapOpenPosAln = $i + 1;
                }
                #### continue a gap in the ref seq w.r.t. the other seq
                if (($seqIsInAGap eq "1") & 
                    ($seqGapThisPos eq "1")) {
                    if ($debug==1) {
                        print "            pos $i continuing a gap in $seqName compared to ref\n";
                    }
                    if ($refGapThisPos eq "") {$refCharsWithinThisGapCount++;}
                }
                #### close a gap in this seq w.r.t. the ref seq
                if (($seqIsInAGap eq "1") & 
                    ($seqGapThisPos eq "")) {
                    if ($debug==1) {
                        print "        pos $i closing a gap in $seqName compared to ref\n";
                        print "            Ref had $refCharsWithinThisGapCount non-gap chars\n";
                    }
                    if (($refCharsWithinThisGapCount % 3) != 0) {
                        $numFrameshifts = reportFrameshift($refPosition, $seqPosition, $i, $refCharsWithinThisGapCount, $distFromSeqEnd, $gapOpenPosRef, $gapOpenPosAln, $numFrameshifts, "deletion", $seqName, $gene, \%refInfo);
                    }
                    $seqIsInAGap = "";
                    $refCharsWithinThisGapCount = 0; ## reset
                    $seqCharsWithinThisGapCount = 0; ## reset
                }
            } ## end of $i loop (each alignment position)
            print EACHGENE "$seqName\t";
            if ( ($numFrameshifts + $numStops) > 0 ) {
                print EACHGENE "Pseud";
                $pseudCounts++;
            } else {
                ## test Intact genes for whether they're truncated
                if ($ungappedSeqLen < $lengthThreshold) {
                    print EACHGENE "Truncated";
                    $truncatedCounts++;
                } else {
                    print EACHGENE "Intact";
                    $seqOUT->write_seq($seq);
                    $intactCounts++;
                }
            }
            print EACHGENE "\t$numFrameshifts\t$numStops\t$ungappedSeqLen\n";
        } ## end of each seq loop
        my $refCounts = @refSeqNames;
        print SUMMARY "Ref\t$refCounts\t$file\n";
        print SUMMARY "Intact\t$intactCounts\t$file\n";
        print SUMMARY "Truncated\t$truncatedCounts\t$file\n";
        print SUMMARY "Pseud\t$pseudCounts\t$file\n";
    } # next_aln loop (meaningless for fasta files, which only contain one alignment
    
    close EACHGENE;
    close DETAILS;
    close SUMMARY;
} # each input file loop

############# subroutines


### name(s) and average length of the reference sequences
sub getRefSeqs {
    my $subAln = $_[0]; my $gene = $_[1]; 
    
    ### figure out name and average length of ref seq(s)
    my @refSeqNames; my @refSeqLengths; my $aveLen;
    ## we might take the first sequence:
    if ($findFullLenRefSeqs == 0) {
        my $firstSeq = $subAln->get_seq_by_pos(1);
        my $name = $firstSeq->display_id();
        push @refSeqNames, $name;
        $aveLen = getUngappedLen($firstSeq, $alnIsMACSE);
        print "    Taking the first sequence as the reference seq $name length $aveLen\n";
    } else {  ## or we might use the string to match
        my $lengthsTotal = 0;
        foreach my $alnSeq ($subAln->each_seq()) {
            my $name = $alnSeq->display_id();
            if ($name !~ m/$fullLenSeqRefString/) {next;}
            my $refLen = getUngappedLen($alnSeq, $alnIsMACSE);
            print "    Found a reference seq $name length $refLen\n";
            push @refSeqNames, $name;
            $lengthsTotal += $refLen;
        }
        # check whether I found any refseqs
        if (@refSeqNames == 0) {
            die "\n\nTerminating - could not find any reference seq names - I was looking for seqnames that match $fullLenSeqRefString\n\n";
        }
        $aveLen = $lengthsTotal / @refSeqNames;
    }
    
    ### now do something with that
    my $firstRefSeq = $refSeqNames[0];
    my @refBases; my $ungappedFirstRefLen; my %firstRefInfo;
    foreach my $refName (@refSeqNames) {
        my $refSeq = $subAln->get_seq_by_id($refName);
        $seqOUT->write_seq($refSeq);
        my $ungappedRefLen = getUngappedLen($refSeq, $alnIsMACSE);
        
        ## we check the reference seq for unexpected stops and frameshifts, e.g. for PEG10, which has a programmed frameshift.
        my $numRefFrameshifts = 0; my $numRefStops = 0;
        my %refInfo = checkRefSeqIntact($refSeq);
        if ($refInfo{'status'} eq "pseud") {
            if (defined $refInfo{'MACSEframeshifts'}) {
                $numRefFrameshifts = @{$refInfo{'MACSEframeshifts'}};
            }
            if (defined $refInfo{'inFrameStops'}) {
                $numRefStops = @{$refInfo{'inFrameStops'}};
            }
            print "    WARNING - the reference sequence has frameshifts or in-frame stop codons\n";
            print "        Num frameshifts $numRefFrameshifts num stops $numRefStops\n";
            print "\n";
        }
        ## output for ref seq
        print EACHGENE "$refName\tReference\t$numRefFrameshifts\t$numRefStops\t$ungappedRefLen\n";
        ## and for just the first ref seq:
        if ($refName eq $firstRefSeq) { 
            @refBases = split //, $refSeq->seq(); 
            $ungappedFirstRefLen = getUngappedLen($refSeq, $alnIsMACSE);
            %firstRefInfo = %refInfo;
        }
    }
    
    return(\@refSeqNames, $aveLen, \@refBases, $ungappedFirstRefLen, \%firstRefInfo);
}

### seq length not including any gaps
sub getUngappedLen {
    my $seqObj = $_[0];
    my $alnIsMACSE = $_[1];
    my $seq = $seqObj->seq();
    $seq =~ s/\-//g;
    if ($alnIsMACSE == 1) { $seq =~ s/\!//g; }
    my $ungappedLen = length($seq);
    return($ungappedLen);
}


### my version of validate_seq, to avoid issues caused by the ! characters
{ no warnings 'redefine';
    sub Bio::LocatableSeq::validate_seq {
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

## simply check an ungapped seq for whether it is an intact ORF. This is only intended for the reference sequence - all the others get checked in a different way. I leave the frameshifts where they are for this purpose.
sub checkRefSeqIntact {
    my $seq = $_[0];
    my $letters = $seq->seq();
    my @eachLetter = split //, $letters;
    my %info;
    $info{'status'} = "intact";
    my $goodORF = 1;
    my $ungapped = $letters; $ungapped =~ s/-//g; 
    if ($ungapped =~ m/\!/) {
        $info{'status'} = "pseud";
        @{$info{'MACSEframeshifts'}} = ();
        my @ungappedLetters = split //, $ungapped;
        my $gappedCount = 0; my $ungappedCount = 0;
        foreach my $l (@eachLetter) {
            if ($l eq "!") {
                push @{$info{'MACSEframeshifts'}}, $ungappedCount;
                my $tempUngappedCount = 1+$ungappedCount;
                my $tempGappedCount = 1+$gappedCount;
                print DETAILS $seq->display_id();
                print DETAILS "\t$tempUngappedCount\t$tempUngappedCount\t";
                print DETAILS "$tempGappedCount\t$tempGappedCount\t";
                print DETAILS "1\tFrameshift ref\n";
            }
            $gappedCount++;
            if ($l !~ m/!|-/) {$ungappedCount++;}
        }
    }
    $ungapped =~ s/!/-/g;
    my $ungappedObj = Bio::Seq->new(-seq=>$ungapped);
    my $translated = $ungappedObj->translate()->seq();
    # stop codon is OK at the end but nowhere else 
    $translated =~ s/\*$//;
    if ($translated =~ m/\*/) {
        $info{'status'} = "pseud";
        my @ungappedAminoAcids = split //, $translated;
        my $gappedCount = 0; my $ungappedCount = 0;
        @{$info{'inFrameStops'}} = ();
        foreach my $u (@ungappedAminoAcids) {
            if ($u eq "*") {
                my $pos = $ungappedCount*3;
                push @{$info{'inFrameStops'}}, $pos;
                $pos = $pos + 1;
                print DETAILS $seq->display_id();
                print DETAILS "\t$pos\t$pos\t";
                print DETAILS "NA\tNA\t";
                print DETAILS "1\tStop codon ref\n";
            }
            $ungappedCount++;
        }
    }
    return(%info);
}

sub checkForStopCodon {
    my ($refCodon, $seqCodon, $refPosition, $distFromRefEnd, $i, $seqName, $numStops) = @_;
    ## if refCodon length is 3, test for stop codons and reset 
    if (length($refCodon)==3) {
        if (uc($refCodon) !~ m/TAA|TAG|TGA/) {
            if (uc($seqCodon) =~ m/TAA|TAG|TGA/) {
                if ($debug==1) {
                    print "        seq $seqName pos $i IN-FRAME STOP CODON!\n";  
                }
                my $stopType = "Stop codon";
                if ($distFromRefEnd < $stopCodonDistCheck) {
                    $stopType = "Ignoring stop codon near end";
                    if ($debug==1) {
                        print "        $seqName has stop codon close to ref end - ignoring\n";
                    }
                } else  {
                    $numStops++;
                }
                print DETAILS "$seqName\t";
                print DETAILS $refPosition-1, "\t", $refPosition+1, "\t";
                print DETAILS $i-1, "\t", $i+1 ;
                print DETAILS "\tNA\t$stopType\n";
            }
        }
        $refCodon = ""; $seqCodon = ""; 
    }
    return ($refCodon, $seqCodon, $numStops);
}

sub reportFrameshift {
    my ($refPosition, $seqPosition, $i, $gapLen, $distFromSeqEnd, $gapOpenPosRef, $gapOpenPosAln, $numFrameshifts, $fsType, $seqName, $gene, $refInfoRef) = @_;
    my %refInfo = %$refInfoRef;
    
    if ($debug==1) {
        print "                FRAMESHIFT! refPosition $refPosition seqPosition $seqPosition distFromSeqEnd $distFromSeqEnd\n";
    }
    if (($seqPosition > 3) & ($distFromSeqEnd > 3)) {
        my $fsTag = "Frameshift $fsType";
        $numFrameshifts++;
        print DETAILS "$seqName\t";
        print DETAILS "$gapOpenPosRef\t", $refPosition-1, "\t";
        print DETAILS "$gapOpenPosAln\t", $i ;
        print DETAILS "\t$gapLen\t$fsTag\n";
    }
    return($numFrameshifts);
}
