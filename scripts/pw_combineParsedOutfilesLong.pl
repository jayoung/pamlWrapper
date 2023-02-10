#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $outfile = "allAlignments.PAMLsummaries.tsv";
my $overwrite = 0;

my $scriptName = "pw_combineParsedOutfilesLong.pl";

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
foreach my $file (@ARGV) {
    # print "\n#### file $file\n";
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";
    }
    if ($file !~ m/PAMLsummary\.tsv/) {
        die "\n\nERROR - terminating in script $scriptName - did you really want to run this script on file $file ? It is not a PAMLsummary.tsv file. If you did mean that, change the script\n\n";
    }
    open (IN, "< $file");
    my $numLinesRecorded = 0;
    while (<IN>) {
        my $line = $_;
        if ($line =~ m/^seqFile/) {
            if ($firstFile) { print OUT "tsvFile\t$line"; } else { next; }
        } else {
            print OUT "$file\t$line";  $numLinesRecorded++;
        }
    }
    close IN;
    if ($numLinesRecorded == 0) {
        print "\n    WARNING! didn't add any output for file $file\n\n";
    }
    if ($numLinesRecorded < 7) {
        print "\n    WARNING! only added $numLinesRecorded lines of output (expected 7) for file $file\n\n";
    }
    $firstFile = 0;
    print OUT "\n"; # empty line between each alignment file's output
}
close OUT;
