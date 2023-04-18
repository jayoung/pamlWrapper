# Locations and paths

My git repo is [here](https://github.com/jayoung/pamlWrapper).   

On my work mac I'm working in `/Users/jayoung/gitProjects/pamlWrapper`.  
On gizmo/rhino I'm working in `/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper`

# Testing a new feature - allow user-supplied tree

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testUserTree

## an example where the seqnames and the tree names DO match up:
pw_makeTreeAndRunPAML.pl --usertree=Dmel22genome_tree.nwk Dmel_22_aln.fasta
    # works

## an example where the seqnames and the tree names DO NOT match up:
pw_makeTreeAndRunPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
    # stops before it gets to running PAML - good.
# via sbatch wrapper:
pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
   # stops before it gets to running PAML - good. (it does go through sbatch to do it - that's OK)
## example of how I would fix up the tree file
# created CENPA_primates_aln2a_only5seqs.userTreeNameTable.txt via minimal edits from the file produced by checkSeqs. Then I fix the names:
../../pamlWrapper/scripts/pw_changenamesinphyliptreefile.pl CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.userTreeNameTable.txt 
# rerun after fixing names in tree - it works
pw_makeTreeAndRunPAML.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames.names CENPA_primates_aln2a_only5seqs.fa 
# via sbatch wrapper:
pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=CENPA_primates_aln2a_only5seqs.fa.phy.usertree.badNames CENPA_primates_aln2a_only5seqs.fa 
```

## retest user tree, after updating PAML version

PAML version 4.10.6 requires an extra first line in the treefile: that line messed up some of the other scripts in the pipeline.

On April 17, 2023, my scripts hadn't fully taken that extra line into account.
- if the tree DID NOT have the first line, paml fails totally. The pw_checkUserTree.pl script now checks for that extra line, and doesn't proceed if it's absent.
- if the tree DID have the first line, my checking script failed to parse it. I've fixed that now.  Then it failed a bit further along, in `pw_reorderseqs_treeorder.pl`.  I'm trying to fix that now.

Checking: tree DOES have first line:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testUserTree/tree_withFirstLine
runPAML.pl --usertree=Dmel22genome_tree.withFirstLine.nwk Dmel_22_aln.fasta
 
# use non-containerized
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=Dmel22genome_tree.withFirstLine.nwk Dmel_22_aln.fasta
    xxx 19057650
```


xx do lots of checks!  if they pass, rebuild the container and bump version number

xx I COULD make the script flexible to using tree in STANDARD newick format without that extra line
xx I COULD make the script flexible to using alignment that's already in PAML format

Check Sophie's input files:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testUserTree/sophie

~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --usertree=cenpa_primate_species_trees_scientificnames_nobranch.nh cenpa_primate_aln3_scinames_v2.fasta

    xxx running
```

# Testing the --verbose=1 option 

added Feb 9, 2023

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testVerboseOutput/verbose0_sbatch
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl Mx1_PAML25.fasta.names Dmel_22_aln.fasta CENPA_primates_aln2a_NT.fa

cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testVerboseOutput/verbose1_sbatch
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verbose=1 Mx1_PAML25.fasta.names Dmel_22_aln.fasta CENPA_primates_aln2a_NT.fa
```


# Actually USING the scripts on my Mac (desktop), without using docker

I installed a few PAML versions (see /Users/jayoung/source_codes/paml/paml_MAC_installNOTES_JY.txt)

1. pull an up-to-date copy of the repo  
```
cd /Users/jayoung/gitProjects/pamlWrapper
git pull
```

2. fix permissions
because I'm not syncing permissions to github
```
pushd /Users/jayoung/gitProjects/pamlWrapper/scripts/
chmod u+x *l
popd
```

3. fix the shebang lines for all perl scripts so I use my Mac's preferred perl installation
```
pushd /Users/jayoung/gitProjects/pamlWrapper/scripts/
# mac needs -e (and makes a backup file called file-e)
sed -i -e 's/\/usr\/bin\/perl/\/usr\/bin\/env perl/' *.pl *.bioperl
rm *-e 
popd
```

It works if I supply the user tree, but I haven't worked through installing phyml, so I won't be able to run the whole thing:
```
cd /Users/jayoung/testPAMLversions/2023_Feb27/test_4.9a_mac

/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
```

