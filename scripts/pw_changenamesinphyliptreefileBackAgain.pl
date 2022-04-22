#!/usr/bin/perl

use warnings;
use strict;

#usage: changenamesinphyliptreefileBackAgain.pl treefilestochange fileofaliases

### before Aug 2013 this wasn't qutie right - should not have been using =~ s// on the whole line - that just swapped the first match, and sometimes a seq matched >once.

my $treefile = shift @ARGV || die "usage: changenamesinphyliptreefile.pl treefiletochange fileofaliases\n";
my $aliasfile = shift @ARGV || die "usage: changenamesinphyliptreefile.pl treefiletochange fileofaliases\n";

#print "\nfile $treefile\naliasfile $aliasfile\n";

####### go through aliases:
open (TABLE, "< $aliasfile") || die "can't open $aliasfile\n";
my @lines1 = <TABLE>;
my %hashnames;
foreach my $line1 (@lines1) {
   chomp $line1;
   if ($line1 =~ m/^Order/) {next;}
   my $oldname = (split /\t/, $line1)[1];
   #$oldname =~ s/_ORF//;
   #$oldname =~ s/\*//;
   my $newname = (split /\t/, $line1)[0];
   #print "alias old $oldname new $newname\n";
   $hashnames{$oldname} = $newname;
 }
close TABLE;
#print "\n\n";

my $newfile = "$treefile.names";
open (OUTFILE, "> $newfile");

open (INFILE, "< $treefile") || die "can't open treefile $treefile\n";
my @lines = <INFILE>;
close INFILE;

######## go through tree file
foreach my $line (@lines) {
    #$line =~ s/_ORF.frame1pep.fasta//g;
    $line =~ s/.frame1pep.fasta//g;                                                                                              ### new version - using outer parentheses keeps the joining bits
    my @words = split /([\(\)\:\,])/, $line;
    my $newline = "";
    foreach my $word (@words) {
        #print "word $word\n";
        my $test = $word; $test =~ s/\d//g; $test =~ s/\.//g;$test =~ s/\;//g;$test =~ s/\n//g;
        if ($test ne "") {
            if (defined($hashnames{$word})) {
                my $newword = $hashnames{$word};
                #print "swapped $word for $newword\n";
                $word = $newword;
            }
        }
        $newline .= $word;
    }
    print OUTFILE "$newline";
}
close OUTFILE;
#print "\n\n";

