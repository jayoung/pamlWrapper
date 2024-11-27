#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $outfile = "allAlignments.PAMLsummaries.wide.tsv";
my $overwrite = 0;

my $scriptName = "pw_combinedParsedOutfilesWide.pl";

GetOptions("out=s" => \$outfile,
           "over=i" => \$overwrite) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n"; 


## Nov 23 2022 - added the name of the tsv file as the first field, to help track situations where I have multiple runs on the same alignment/tree combo, e.g. when testing different PAML versions, or testing on different computers.

############

if (-e $outfile) {
    if ($overwrite) {
        die "\n\nERROR - terminating in script $scriptName - outfile $outfile exists already: don't want to overwrite it\n\n";
    } else {
        print "\nWARNING - overwriting previous outfile $outfile\n\n";
    }
}
open (OUT, "> $outfile");

my $firstFile = 1;
my $firstFileNumFields;
foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";
    }
    if ($file !~ m/\.wide\.tsv/ & $file !~ m/\.wide\.combineMasking\.tsv/) {
        die "\n\nERROR - terminating in script $scriptName - did you really want to run this script on file $file ? It is not a .wide.tsv or a .wide.combineMasking.tsv file. If you did mean that, change the script\n\n";
    }
    # print "## file $file\n";
    open (IN, "< $file");
    while (<IN>) {
        my $line = $_;
        my @f = split /\t/, $line;
        my $numFields = @f;
        # print "line $line\n\nnumFields $numFields\n\n"; die;
        if (($line =~ m/^Gene\sname/) || ($line =~ m/^seqFile/) || ($line =~ m/^gene/) || ($line =~ m/^tsvFile/)) {
            if ($firstFile) { 
                print OUT "tsvFile\t$line"; 
                $firstFileNumFields = $numFields;
            } else { 
                next; 
            }
        } else {
            if (!defined $firstFileNumFields) {
                die "\n\nERROR - didn't find expected header line in the first file. Script expects it to start with 'Gene name' or 'seqFile' or 'gene' or 'tsvFile'\n\n";
            }
            print OUT "$file\t$line"; 
            if ($numFields != $firstFileNumFields) {
                die "\n\nERROR - first file had $firstFileNumFields fields per line, but file $file has $numFields\n\n";
            }
        }
    }
    close IN;
    $firstFile = 0;
}
close OUT;
