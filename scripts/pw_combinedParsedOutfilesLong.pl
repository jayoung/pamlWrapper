#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $outfile = "allAlignments.PAMLsummaries.tsv";
my $overwrite = 0;

GetOptions("out=s" => \$outfile,
           "over=i" => \$overwrite) or die "\n\nERROR - terminating in script pw_combinedParsedOutfilesLong.pl - unknown option(s) specified on command line\n\n"; 


############

if (-e $outfile) {
    if ($overwrite) {
        die "\n\nERROR - terminating in script pw_combinedParsedOutfilesLong.pl - outfile $outfile exists already: don't want to overwrite it\n\n";
    } else {

        print "\nWARNING - overwriting previous outfile $outfile\n\n";
    }
}
open (OUT, "> $outfile");

my $firstFile = 1;
foreach my $file (@ARGV) {
    if (!-e $file) {
        die "\n\nERROR - terminating in script pw_combinedParsedOutfilesLong.pl - file $file does not exist\n\n";
    }
    if ($file !~ m/PAMLsummary\.tsv/) {
        die "\n\nERROR - terminating in script pw_combinedParsedOutfilesLong.pl - did you really want to run this script on file $file ? It is not a PAMLsummary.tsv file. If you did mean that, change the script\n\n";
    }
    open (IN, "< $file");
    while (<IN>) {
        my $line = $_;
        if ($line =~ m/^seqFile/) {
            if ($firstFile) { print OUT $line; } else { next; }
        } else {
            print OUT $line; 
        }
    }
    close IN;
    $firstFile = 0;
    print OUT "\n"; # empty line between each alignment file's output
}
close OUT;
