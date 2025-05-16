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
