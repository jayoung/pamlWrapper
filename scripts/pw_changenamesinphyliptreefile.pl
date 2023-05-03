#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

# usage: pw_changenamesinphyliptreefile.pl treefilestochange fileofaliases
# default behavior is that the fileofaliases has this format:
#     new names -  old name 
# we can also use alias files in this format, using --format=old_new option:
#     old names -  new name 

#### default values
my $aliasFormat = "new_old";  ## can also be "old_new"
my $headerToIgnore = "seqID_alignment";

#### script name and usage
my $scriptName = "pw_changenamesinphyliptreefile.pl";

my $usage = "Usage:\n$scriptName --format=new_old treefiletochange fileofaliases\n";
$usage .= "    --format means format of the alias file: can be 'new_old' or 'old_new' (alias file is always tab-delimited)\n";
$usage .= "    --header (optional): sometimes we want to tell the script what a header line looks like for the alias file. Supply the first part of the header line. Default value is '$headerToIgnore'\n";

### get non-default option values
# Using a colon : instead of the equals sign indicates that the option value is optional. 
GetOptions("format=s"  => \$aliasFormat, 
           "header:s"  => \$headerToIgnore) or die "\n\nERROR - terminating in script $scriptName - unknown option(s) specified on command line\n\n$usage\n\n"; 


#################  start script

my $oldnameField;
my $newnameField;
if ($aliasFormat eq "new_old") {
    $newnameField = 0;
    $oldnameField = 1;
}
if ($aliasFormat eq "old_new") {
    $oldnameField = 0;
    $newnameField = 1;
}
if (!defined ($oldnameField) ) {
    die "\n\nERROR - terminating in script $scriptName - the --format option must be either new_old (default) or old_new, but you specified $aliasFormat\n\n$usage\n\n";
}

my $treefile = shift @ARGV || die "\n\nERROR - terminating in script $scriptName\n\n$usage\n\n";
my $aliasfile = shift @ARGV || die "\n\nERROR - terminating in script $scriptName\n\n$usage\n\n";
#print "\nfile $treefile\naliasfile $aliasfile\n";

####### go through aliases:
open (TABLE, "< $aliasfile") || die "\n\nERROR - terminating in script $scriptName - can't open $aliasfile\n\n$usage\n\n";
my @lines1 = <TABLE>;
my %hashnames;
foreach my $line1 (@lines1) {
    chomp $line1;
    #if ($line1 =~ m/^Order/) {next;}
    if ($headerToIgnore ne "") {
        if ($line1 =~ m/^$headerToIgnore/) {next;}
    }
    my $oldname = (split /\t/, $line1)[$oldnameField];
    #$oldname =~ s/_ORF//;
    #$oldname =~ s/\*//;
    my $newname = (split /\t/, $line1)[$newnameField];
    #print "alias old $oldname new $newname\n";
    $hashnames{$oldname} = $newname;
}
close TABLE;
#print "\n\n";

my $newfile = "$treefile.names";
open (OUTFILE, "> $newfile");

open (INFILE, "< $treefile") || die "\n\nERROR - terminating in script $scriptName - can't open treefile $treefile\n\n$usage\n\n";
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

