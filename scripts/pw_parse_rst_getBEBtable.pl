#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Bio::SeqIO;
use Bio::Seq;
use IO::String;

#### take an rst file (output of codeml) and extracts just the BEB outputs, as tab-delimited text. Motivation: may want to use this to plot results.

#### can also output annotation lines where BEB sites over specified probability thresholds will be highlighted

######## set default parameter choices:

# I probably want to output a fasta-format annotation line(s), for one or more specified probability thresholds (just a single annotation line, not adding to existing alignment). Can specify multiple thresholds using comma delimited list on the command-line, e.g. --post=0.75,0.9. Default is to get sites >= 0.9. Uses >=
my $getAnnotLine = 0;
my $posteriorThresholdsString = "0.9";

# I may want to use the input alignment to convert alignment coordinates to coordinates in a reference sequence, whose name I specify either fully, or with a pattern match
my $convertCoords = 0;
my $refName = "";
my $refPattern = "";

######## now, get any user-specified non-default options
GetOptions("annot=i" => \$getAnnotLine, ## default is 1, that I do get annotation line(s)
           "post=s" => \$posteriorThresholdsString,
           "refCoords=i" => \$convertCoords,
           "refName=s" => \$refName,
           "refPattern=s" => \$refPattern) or die "\n\nterminating - unknown option(s) specified on command line\n\n";

############

my @posteriorThresholds;
if ($getAnnotLine == 1) {
    # parse the posterior thresholds:
    $posteriorThresholdsString =~ s/\s//g;
    @posteriorThresholds = split /\,/, $posteriorThresholdsString;
    print "\nWill get annotation lines for these thresholds:\n";
    foreach my $post (@posteriorThresholds) {print "    $post\n";} 
}

if ($convertCoords == 1) {
    if (($refName eq "") & ($refPattern eq "")) {
        die "\n\nTerminating - if you want to convert coordinates from alignment coordinates to coords in an individual sequence, you must specify either refName or refPattern\n\n";
    }
    if (($refName ne "") & ($refPattern ne "")) {
        die "\n\nTerminating - you cannot specify BOTH refName or refPattern - pick one\n\n";
    }
}
foreach my $file (@ARGV) {
    if (!-e $file) { die "\n\nterminating - cannot open file $file\n\n";} 
    my ($shortFileName, $filePath) = getShortFileNameAndPathFromFileName($file);
    open (IN, "< $file");
    my @lines = <IN>;
    close IN;
    
    ## if I will be converting coordinates to a ref seq coordinate, I want to read in the alignment
    my $refSeqName;
    #my $aln;
    my %seqHash;
    my %codonCoordConversion; my %refSeqAminoAcids;
    if ($convertCoords == 1) {
        my $alnFileName = getAlnFileName(\@lines, $filePath);
        print "    reading alignment from file $alnFileName\n";
        # cannot use Bioperl AlignIO to read the seqs, as the file is NOT in classic phylip format, so I made my own subroutine:
        ## when I was using AlignIO:
        # $aln = readAlignmentPAMLformat($alnFileName); # Bio::SimpleAlign object
        
        my $seqHashRef = readAlignmentPAMLformat($alnFileName); # hash of seqs object
        %seqHash = %$seqHashRef;
        # make sure I can find the reference sequence
        if ($refName ne "") {
            #if(!defined $aln->get_seq_by_id($refName)) {
            #    die "\n\nTerminating - you asked to convert coords to coords in a reference seq called $refName but it is not present in the alignment\n\n";
            #}
            if (!defined $seqHash{$refName}) { 
                die "\n\nTerminating - you asked to convert coords to coords in a reference seq called $refName but it is not present in the alignment\n\n";
            }
            $refSeqName = $refName;
            #$refSeqAln = $aln->get_seq_by_id($refName);
        }
        my $matchCount = 0;
        if ($refPattern ne "") {
            ### when I was using AlignIO
            #foreach my $seq ($aln->each_seq()) { # Bio::LocatableSeq
            #    #print "seq $seq\n"; 
            #    my $seqname = $seq->id();
            #    if ($seqname =~ m/$refPattern/) {
            #        $matchCount++;
            #        #$refSeqAln = $seq;
            #        $refSeqName = $seqname;
            #    }
            #}
            
            foreach my $seqname (keys %seqHash) { 
                #print "seq $seq\n"; 
                if ($seqname =~ m/$refPattern/) {
                    $matchCount++;
                    #$refSeqAln = $seq;
                    $refSeqName = $seqname;
                }
            }
        }
        if ($matchCount < 1) {
            die "\n\nTerminating - did not find any sequences with names matching $refPattern\n\n";
        }
        if ($matchCount > 1) {
            die "\n\nTerminating - found more than one sequence with names matching $refPattern\n\n";
        }
        print "    Found ref seq $refSeqName\n";
        my ($codonCoordConversionRef, $refAAsRef) = convertCodonCoords($seqHash{$refSeqName});
        %codonCoordConversion = %$codonCoordConversionRef;
        %refSeqAminoAcids = %$refAAsRef;
    }
    my $BEBscoresRef = getTable(\@lines, "BEB", $file, $convertCoords, \%codonCoordConversion, $refSeqName, \%refSeqAminoAcids);
    if ($getAnnotLine == 1) {
        foreach my $post (@posteriorThresholds) {
            getAnnotLine($BEBscoresRef, $post, "BEB", $file);
        }
    }
}
#print "\n\n";

######## getTable: a subroutine to get the desired table from a file. arguments are:
# (a) an array of the lines I read in from the whole file 
# (b) analysis type (BEB/NEB)
# (c) the name of the input file (so I can construct output file name)
sub getTable {
    my @lines = @{$_[0]};
    my $analysisDesired = $_[1];
    my $file = $_[2];
    
    my $convertCoords = $_[3];
    #my $aln = $_[4];
    #my $seqHashRef = $_[4]; my %seqHash = %{$seqHashRef};
    my $coordsHashRef = $_[4]; my %coordsHash = %{$coordsHashRef};
    my $refSeqName = $_[5];
    my $refSeqAAsRef = $_[6]; my %refSeqAminoAcids = %{$refSeqAAsRef};
    
    my $sectionStartString = "";
    if ($analysisDesired eq "BEB") {$sectionStartString="Bayes Empirical Bayes";}
    #if ($analysisDesired eq "NEB") {$sectionStartString="Naive Empirical Bayes";}
    if ($sectionStartString eq "") { die "\n\nterminating - problem in the getTable subroutine!\n\n"; }
    my $sectionEndString = "Positively selected sites";
    
    ### open out file and print a header
    open (OUT, "> $file.$analysisDesired.tsv");
    my @headerFields = ("codon", "aa_seq1", 
                        "class1", "class2", "class3", "class4", "class5", 
                        "class6", "class7", "class8", "class9", "class10", "class11", 
                        "bestClass", "omegaPostMean", "omegaSE");
    my $refSeqAlnObj;
    if ($convertCoords == 1) {
        my $extraField1name = "codon_in_$refSeqName";
        my $extraField2name = "aa_in_$refSeqName";
        @headerFields = (@headerFields, $extraField1name, $extraField2name);
        #$refSeqAlnObj = $aln->get_seq_by_id($refSeqName); # Bio::LocatableSeq 
        #$refSeqAlnObj = $seqHash{$refSeqName};
        #print "refSeqAlnObj $refSeqAlnObj\n"; die;
    }
    print OUT join "\t", @headerFields;
    print OUT "\n";
    
    ### go through input lines and find the info I'm looking for
    my @scores; # collect BEB/NEB scores in case I want to output an annotation line. The sites will always be in the right order, so I'll just put them in an array, without tracking the position. 
    my $inDesiredSection = "no";
    foreach my $line (@lines) {
        chomp $line; 
        # recognize start of the section we want
        if ($line =~ m/^$sectionStartString/) {
            $inDesiredSection = "yes";
            next;
        }
        if ($line =~ m/^$sectionEndString/) {
            $inDesiredSection = "no";
        }
        if ($inDesiredSection eq "no") {next;}
        if ($line eq "") {next;}
        if ($line =~ m/^\(amino\sacids\srefer\sto/) {next;}
        ## now we are left with just the lines of interest
        $line =~ s/[\(\)]//g;
        $line =~ s/\s\+\-\s/ /;
        $line =~ s/^\s+//;
        $line =~ s/\s+/\t/g;
        my @f = split /\t/, $line;
        print OUT "$line";
        if ($convertCoords == 1) {
             my $refCoord = $coordsHash{$f[0]};
             my $refAA = $refSeqAminoAcids{$f[0]};
             print OUT "\t$refCoord\t$refAA";
        }
        print OUT "\n";
        push @scores, $f[12];
    }
    close OUT;
    return(\@scores);
}

######## getAnnotLine: a subroutine to output annotation line. arguments are:
# (a) a hash of the relevant scores 
# (b) the score threshold to annotate a site
# (c) analysis type (BEB/NEB) (to help construct output file name)
# (d) the name of the input file (to help construct output file name)
sub getAnnotLine {
    my @scores = @{$_[0]};
    my $threshold = $_[1];
    my $analysisDesired = $_[2];
    my $file = $_[3];
    
    my $annotLine = "";
    foreach my $score (@scores) {
        if ($score >= $threshold) { $annotLine .= $analysisDesired ; }
        else { $annotLine .= "---"; }
    }
    
    my $annotFileName = "$file.annot.$analysisDesired.$threshold.fa";
    my $descLine = "PAML_" . $analysisDesired . "over" . $threshold;
    my $seq = Bio::Seq->new(-seq=>$annotLine, -display_id=>$descLine);
    my $seqOUT = Bio::SeqIO->new(-file=>"> $annotFileName", -format=>"fasta");
    $seqOUT->write_seq($seq);
}

######## getShortFileNameAndPathFromFileName: a subroutine to take a filename, and split it into the path and the filename
sub getShortFileNameAndPathFromFileName {
    my $file = $_[0];
    my $shortFileName = $file; 
    my $filePath = ".";
    if ($file =~ m/\//) { 
        $shortFileName = (split /\//, $file)[-1];
        $filePath = $file; $filePath =~ s/$shortFileName//; $filePath =~ s/\/$//;
    }
    return($shortFileName, $filePath);
}

######## getAlnFileName: a subroutine to find the name of the alignment file, and check it exists
sub getAlnFileName {
    my @lines = @{$_[0]}; my $rstFilePath = $_[1];
    my $alnFile = shift @lines; chomp $alnFile;
    $alnFile =~ s/Supplemental\sresults\sfor\sCODEML\s\(seqf:\s//;
    $alnFile =~ s/\s+treef:\s.+?$//;
    my ($alnFileShortName, $alnFilePath) = getShortFileNameAndPathFromFileName($alnFile);
    my $alnFileWithPath = "$rstFilePath/$alnFile";
    if (!-e $alnFileWithPath) {
        die "\n\nTerminating - cannot find the alignment file specified in the rst file. Should be called $alnFileWithPath\n\n";
    }
    return($alnFileWithPath);
}

######## readAlignmentPAMLformat: a subroutine to read an alignment in PAML format (like phylip format, but not quite) and wrangle it into a Bioperl alignment object
sub readAlignmentPAMLformat {
    my $file = $_[0];
    open (ALN, "< $file");
    my @lines = <ALN>;
    close ALN;
    my $header = shift @lines;  $header =~ s/^\s+//; 
    my $numSeqs = (split /\s/, $header)[0];
    my $numPos = (split /\s/, $header)[1];
    my $numRemainingLines = @lines;
    ## fudge together a phylip format alignment
    my $fastaAln = "";
    my $toggleNewline = 0;
    foreach my $line (@lines) {
        chomp $line;
        if ($toggleNewline == 1) { 
            $fastaAln .= "$line\n"; $toggleNewline = 0;
        } else { 
            $fastaAln .= ">$line\n"; $toggleNewline = 1;
        }
    }
    
    ## now make AlignIO object from string rather than from file
    my $stringFH = IO::String->new($fastaAln); 
    
    ## when I was using AlignIO
    #my $alnIN = Bio::AlignIO->new(-fh => $stringFH, -format => "fasta");
    #my $aln = $alnIN->next_aln();
    #print "    found alignment with " . $aln->num_sequences() . " seqs and " . $aln->length() . " positions\n\n";
    #return($aln);
    
    my $seqIN = Bio::SeqIO->new(-fh => $stringFH, -format => "fasta");
    my %seqs; my $length;
    while (my $seq=$seqIN->next_seq()) {
        my $id = $seq->display_id(); $seqs{$id} = $seq;
    }
    print "    found alignment with $numSeqs seqs and $numPos positions\n\n";
    return(\%seqs);
}

######## convertCodonCoords: a subroutine to take the aligned reference sequence, and get a hash whose keys are the codon positions in the alignment, and values are the codon positions in the ref seq (with "-" for gaps)
sub convertCodonCoords {
    my $seq = $_[0];
    my %coords; my %refSeqAminoAcids;
    my $length = $seq->length();
    my $letters = $seq->seq();
    my $ungappedRefSeqCodonCount = 1; my $alnCodonCount = 1;
    for (my $i=0; $i<$length; $i=$i+3) {  # $i is the 0-based nucleotide position of the first position of the codon
        my $codon = substr($letters, $i, 3);
        #my $codonObj = $seq->trunc( $i+1, $i+4);
        #my $codon = $codonObj->seq();
        #print "alignment codon $alnCodonCount refseq codon $ungappedRefSeqCodonCount sequence $codon\n"; 
        if ($codon !~ m/-/) { 
            $coords{$alnCodonCount} = $ungappedRefSeqCodonCount;
            my $codonObj = Bio::Seq->new(-seq=>$codon);
            $refSeqAminoAcids{$alnCodonCount} = $codonObj->translate->seq;
            $ungappedRefSeqCodonCount++; 
        } else {
            $coords{$alnCodonCount} = "-";
            $refSeqAminoAcids{$alnCodonCount} = "-";
        }
        #print "codon pos in aln $alnCodonCount ref seq pos $ungappedRefSeqCodonCount sequence $codon amino acid $refSeqAminoAcids{$alnCodonCount}\n";
        $alnCodonCount++;
    }
    return(\%coords, \%refSeqAminoAcids);
}
