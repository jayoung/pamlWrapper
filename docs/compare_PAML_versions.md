# Observations:


the nan values in the BEB output occur in ALL (?) the results from the version of the singularity container where I installed paml 4.9a using conda

I think the likelihoods etc are very similar between all versions, but the BEB results from singularity-conda-paml are off (compared to all the rest)

xxx does singularity-new-paml work OK?  i.e. is it a singularity issue or a singularity-conda-paml issue?

xxx timings?  is the BEB module slower with some versions?



## Test alignments
Various test cases (found in `~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments`)

Smaller alignments:
- `CENPA_primates_aln2a_only5seqs.fa`: 5 species, 141 codons
- `CG31882_sim.fa` CG31882 (Ching-Ho): 8 species, 122 codons (the one where Ching-Ho noticed the nans)

Medium sized alignments, potential positive selection but less clear-cut
- `CENPA_primates_aln2a_NT.fa`: 18 species, 141 codons
- `Dmel_22_aln.fasta` Abo (Risa): 22 species, 547 codons

Big alignments, more likely to show positive selection:
- `ACE2_primates_aln1_NT.fa`: (from my paml pipeline list9) 24 species, 806 codons
- `TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa` TRIM5 (from my paml pipeline list9): 36 species, 518 codons. SHOULD have a bunch of selected sites.



# Running PAML

## v4.8

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.8
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 
```

This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.8, March 2014'
```
head -1 *PAML/M8_*/mlc
```

## v4.9a (installed via conda, run within singularity)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.9a_via_sif1.1.0
runPAML.pl CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

This command shows that ALL five have the nan problem
```
head  -2 *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9, March 2015'
```
head  -1 *PAML/M8_*/mlc
```


## v4.9a (installed myself)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.9a 
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa  ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9, March 2015'
```
head -1 *PAML/M8_*/mlc
```

## v4.9j (outside singularity)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.9j
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa
```

This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9j, February 2020'
```
head -1 *PAML/M8_*/mlc
```

## v4.9j (inside singularity)

```
cd test_codeml_4.9j_via_sif1.2.0

../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.0.sif CENPA_primates_aln2a_only5seqs.fa 
    xx 4562336
ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa


```

## v4.10.6

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.10.6
```
first, just CENPA_primates_aln2a_only5seqs.fa .

I need the `--strict=loose` option, because for this PAML version M2 and M8 don't print 'Time used' at the end of the mlc file.  I think they otherwise worked?  No obvious errors. Same output if I run via command-line and not within the sbatch job.
```
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa 
     xxx running 

```
It got MOST of the way there - the BEB section looks complete. I think it IS there except that it didn't print 'Time used' at the end.

Try the other alignments. Same issue with 'Time used' for all, I think?  although I'm still waiting for some to complete
```
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl  --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
     xxx running 
```

## combining results across different versions:

```
pw_combinedParsedOutfilesLong.pl test_codeml_*/CG31882_sim.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882_sim_PAMLsummaries.tsv 

pw_combinedParsedOutfilesLong.pl test_codeml_*/Dmel_22_aln.fasta_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22_aln_PAMLsummaries.tsv 

pw_combinedParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_only5seqs.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_primates_aln2a_only5seqs_PAMLsummaries.tsv 

pw_combinedParsedOutfilesLong.pl test_codeml_*/xxx.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_xxx_PAMLsummaries.tsv 

pw_combinedParsedOutfilesLong.pl test_codeml_*/xxx.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_xxx_PAMLsummaries.tsv 

```

xxx compare results.

xxx also run newer version?