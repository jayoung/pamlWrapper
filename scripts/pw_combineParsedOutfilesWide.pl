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
foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nERROR - terminating in script $scriptName - file $file does not exist\n\n";
    }
    if ($file !~ m/PAMLsummary\.wide.tsv/) {
        die "\n\nERROR - terminating in script $scriptName - did you really want to run this script on file $file ? It is not a PAMLsummary.wide.tsv file. If you did mean that, change the script\n\n";
    }
    print "## file $file\n";
    open (IN, "< $file");
    while (<IN>) {
        my $line = $_;
        if (($line =~ m/^Gene\sname/) || ($line =~ m/^seqFile/)) {
            if ($firstFile) { print OUT "tsvFile\t$line"; } else { next; }
        } else {
            print OUT "$file\t$line"; 
        }
    }
    close IN;
    $firstFile = 0;
}
close OUT;
