# general notes

While working on scripts, use `pw_makeTreeAndRunPAML.pl` (uses current scripts) rather than `runPAML.pl` (uses Docker container)

Run without any wrapper:
```
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```

Wun with sbatch wrapper but without using singularity container:
```
pw_makeTreeAndRunPAML_sbatchWrapper.pl ACE2_primates_aln1_NT.fa
```

# tests

```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/testData

# ordinary PAML runs:
pw_makeTreeAndRunPAML_sbatchWrapper.pl ACE2_primates_aln1_NT.fa  CENPA_primates_aln2a_NT.fa Mx1_PAML25.fa

# supply user tree:
pw_makeTreeAndRunPAML.pl --usertree CENPA_primates_aln2a_only5seqs.fa.phy.usertree CENPA_primates_aln2a_only5seqs.fa
```

# issue 17

https://github.com/jayoung/pamlWrapper/issues/17

pw_annotateAlignmentWithSelectedSites.pl - M8 output varies depending on parameters, so we should record params in output file name


```

cd ~/FH_fast_storage/paml_screen/pamlWrapper/testData
module purge
module load fhR/4.4.0-foss-2023b 

# to force re-parsing: 

rm ACE2_primates_aln1_NT.fa_phymlAndPAML/ACE2_primates_aln1_NT.codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv

pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa

```

