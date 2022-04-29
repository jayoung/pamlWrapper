#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $outfile = "allAlignments.PAMLsummaries.wide.tsv";
my $overwrite = 0;

GetOptions("out=s" => \$outfile,
           "over=i" => \$overwrite) or die "\n\nterminating - unknown option(s) specified on command line\n\n"; 


############

if (-e $outfile) {
    if ($overwrite) {
        die "\n\nTerminating - outfile $outfile exists already: don't want to overwrite it\n\n";
    } else {

        print "\nWARNING - overwriting previous outfile $outfile\n\n";
    }
}
open (OUT, "> $outfile");

my $firstFile = 1;
foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nTerminating - file $file does not exist\n\n";
    }
    if ($file !~ m/PAMLsummary\.wide.tsv/) {
        die "\n\nTerminating - did you really want to run this script on file $file ? It is not a PAMLsummary.wide.tsv file. If you did mean that, change the script\n\n";
    }
    open (IN, "< $file");
    while (<IN>) {
        my $line = $_;
        if (($line =~ m/^Gene\sname/) || ($line =~ m/^seqFile/)) {
            if ($firstFile) { print OUT $line; } else { next; }
        } else {
            print OUT $line; 
        }
    }
    close IN;
    $firstFile = 0;
}
close OUT;
