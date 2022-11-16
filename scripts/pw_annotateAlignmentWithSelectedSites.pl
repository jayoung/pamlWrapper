#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;
use Getopt::Long;

###### takes an alignment, looks for M8 paml output, finds any BEB selected sites (if there were any) and if so, makes a new alignment with an extra seq that allows us to see where those sites are. 

######### set default parameters
my $codonAnnotString = "BEB";
## what parameters were used when PAML was run? (we only need to know this to know what the output dirs are called)
my $codonModel = 2;
my $initOmega = 0.4;
my $cleanData = 0;

## which model do we want to annotate the selected sites for?
my $codemlModel = 8;

## report selected sites with at least this BEB probability into the output file:
my $BEBprobThresholdToPrintSelectedSite = 0.9;

my $scriptName = "pw_annotateAlignmentWithSelectedSites.pl";

######### get any non-default parameters from the command-line:
GetOptions("omega=f" => \$initOmega,         ## sometimes I do 3, default is 0.4
           "codon=i" => \$codonModel,        ## sometimes I do 3, default is 2
           "codonModel=i" => \$codemlModel,  ## default is 8
           "clean=i" => \$cleanData,         ## default is 0. sometimes I do paml with cleandata=1 to remove the sites with gaps in any species.  But I haven't implemented looking at cleandata=1 output. 
           "BEB=f"   => \$BEBprobThresholdToPrintSelectedSite,  # BEB threshold 0.5 would be less conservative, default is 0.9
           "annot=s" => \$codonAnnotString) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n" ; 

################

if ($cleanData==1) {
    die "\n\nERROR - terminating in script $scriptName - script not set up yet to look at cleandata=1 output\n\n";
}

## check that length of annot is 3 characters
if (length($codonAnnotString) != 3) {
    die "\n\nERROR - terminating in script $scriptName - cannot annotate codons with string $codonAnnotString because it is not three characters long\n\n";
}

foreach my $fastaAlnFile (@ARGV) {
    if (!-e $fastaAlnFile) {
        die "\n\nERROR - terminating in script $scriptName - cannot open file $fastaAlnFile\n\n";
    }
    #print "\n\n############################\n\n";
    #print "Working on file $fastaAlnFile\n";
    
    my $dir = ".";
    if ($fastaAlnFile =~ m/\//) {
        my $fileWithoutDir = $fastaAlnFile; 
        $fileWithoutDir =~ m/\/(.+?)$/;
        $fileWithoutDir = $1;
        $dir = $fastaAlnFile;
        $dir =~ s/\/$fileWithoutDir$//;
        #print "file $fastaAlnFile\nfileWithoutDir $fileWithoutDir\ndir $dir\n";
    }

    ## now look at PAML results
    #print "    looking at PAML results\n";
    my $mlcFile = "$dir/M$codemlModel"."_initOmega$initOmega"."_codonModel$codonModel/mlc";
    my $model8siteResultsRef = paml_BEB_results("$mlcFile");
    my %model8siteResults = %$model8siteResultsRef;

    #my $refseq = $model8siteResults{'refSeq'};
    my $sites = "noneOver_$BEBprobThresholdToPrintSelectedSite";
    my $numSites = 0;
    if (defined $model8siteResults{'sites'}) {
        #$sites = join ",", @{$model8siteResults{'sites'}};
        $numSites = @{$model8siteResults{'sites'}};
    }

    ## if there were no sites I do not want to make an output file (?)
    if ($numSites == 0) {
        print "        No sites exceeded the BEB threshold of $BEBprobThresholdToPrintSelectedSite - not annotating this alignment\n\n";
        next;
    }
    
    ## I need to know the length of the alignment, so I can make a blank seq (all ---)
    my $seqIN = Bio::SeqIO->new(-file=>"< $fastaAlnFile", -format=>"fasta");
    my $seqLen = $seqIN->next_seq->length;
    my $annotSeq = "";
    for (my $i=1; $i<=$seqLen; $i++) { $annotSeq .= "-"; }
    my $tempLen = length $annotSeq;

    ## then go through selected sites and figure out nucleotide positions and subsitute something in to the selected codons.  The site numbers PAML outputs refer to the ALIGNMENT not position in the sequence it calls ref seq. The only thing that refseq is used for is telling us what the aa is in that seq at that position
    foreach my $site (@{$model8siteResults{'sites'}}) {
        $site = (split /_/, $site)[0];
        my $nucStart = 3*($site - 1); ## perl uses 0-based start for substr
        substr($annotSeq, $nucStart, 3, $codonAnnotString);
    }

    ## to make output file, I first copy the input alignment, then I add to it another seq that has annotation. 
    my $outfile = $fastaAlnFile;
    $outfile =~ s/\.fasta$//; $outfile =~ s/\.fa$//;
    $outfile .= ".annotBEBover$BEBprobThresholdToPrintSelectedSite.fa";
    system("cp $fastaAlnFile $outfile");
    my $seqOUTannot = Bio::SeqIO->new(-file => ">> $outfile", '-format' => 'Fasta');
    my $annotSeqname = "posSelM$codemlModel"."_BEBover$BEBprobThresholdToPrintSelectedSite";
    my $annotatedSeq = Bio::Seq->new( -display_id => $annotSeqname, 
                                             -seq => $annotSeq);
    $seqOUTannot->write_seq($annotatedSeq);

}
#print "\n################# done ###############\n\n";


#### paml_BEB_results : get the proportion of selected sites, the omega of the selected sites, and the identity of the selected sites, and the name of the first seq in the alignment that the coordinates refer to

sub paml_BEB_results {
    my $file = $_[0];
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";
    }
    my %M8results;
    open (MLC, "< $file");
    my $inM8parametersSection = "no";
    my $inBEBsection = "no";
    while (<MLC>) {
        my $line = $_; chomp $line;
        #### get proportion and omega of selected sites
        if ($line =~ m/^Parameters\sin\sM8/) {
            $inM8parametersSection = "yes";
            next;
        }
        if ($inM8parametersSection eq "yes") {
            if ($line eq "") {
                $inM8parametersSection = "no";
                next;
            }
        }
        if ($inM8parametersSection eq "yes") {
            if ($line =~ m/p1/) {
                my $p1 = (split /\s+/, $line)[3];
                $p1 =~ s/\)//;
                my $w = (split /\s+/, $line)[6];
                $M8results{'p1'} = $p1;
                $M8results{'w'} = $w;
            }
        }
        #### get BEB results
        if ($line =~ m/^Bayes\sEmpirical\sBayes\s/) {
            $inBEBsection = "yes";
            next;
        }
        if ($inBEBsection eq "yes") {
            if ($line =~ m/^The\sgrid/) {
                $inBEBsection = "no";
                next;
            }
        }
        if ($inBEBsection eq "yes") {
            if ($line eq "") {next;}
            if ($line =~ m/^Positively/) {next;}
            if ($line =~ m/post\smean/) {next;}
            if ($line =~ m/^\(amino\sacids\srefer\sto/) {
                my $refSeq = (split /\s/, $line)[6];
                $refSeq =~ s/\)//;
                $M8results{'refSeq'} = $refSeq;
                next;
            }
            my @g = split /\s+/, $line;
            my $prob = $g[3];
            $prob =~ s/\*//g;
            if ($prob < $BEBprobThresholdToPrintSelectedSite) {
                next;
            }
            my $site = "$g[1]"."_$g[2]"."_$prob";
            if (!defined $M8results{'sites'}) {
                @{$M8results{'sites'}} = ($site);
            } else {
                push @{$M8results{'sites'}}, $site;
            }
        }
    }
    return(\%M8results);
}
