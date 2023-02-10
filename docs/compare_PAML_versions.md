# Observations:

the nan values in the BEB output occur in ALL (?) the results from the version of the singularity container where I installed paml 4.9a using conda

I think the likelihoods etc are very similar between all versions, but the BEB results from singularity-conda-paml are off (compared to all the rest)

Singularity with v4.9j behaves fine. So I think the issue is with my docker-conda-paml combination, and it's not a singularity thing per se

Speed?  4.9j does seem a bit slower than 4.9a or 4.8 (especially for M8) but it's not terrible. 4.10.6 - it doesn't capture timings for M8 or M2 so I don't know.



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
- `Mx1_PAML25.fasta.names` from Patrick, does have a couple of gap codons removed



# Running PAML

## v4.8

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.8
# first batch
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 

# add Mx (unmasked and CpG-masked)
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```

This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.8, March 2014'
```
head -1 *PAML/M8_*/mlc
```




with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.8 

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```




## v4.9a (installed via conda, run within singularity)


```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a_via_sif1.1.0
### SINCE I RAN THIS I changed the default singularity image. But when I ran it, I used sif 1.1.0, which used PAML v4.9a installed via singularity
runPAML.pl CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

This command shows that ALL six have the nan problem
```
head -2 *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9, March 2015'
```
head -1 *PAML/M8_*/mlc
```

add Mx

```
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```

with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a_via_sif1.1.0 

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3  --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3  --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4  --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```




## v4.9a (installed myself)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa  ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# add Mx (unmasked and CpG-masked)
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```

This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9, March 2015'
```
head -1 *PAML/M8_*/mlc
```

with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a 

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```


## v4.9j (outside singularity)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# add Mx (unmasked and CpG-masked)
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```


This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9j, February 2020'
```
head -1 *PAML/M8_*/mlc
```

with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```



## v4.9j (inside singularity)

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j_via_sif1.2.1
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# add Mx (unmasked and CpG-masked)
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .

../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```

with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j_via_sif1.2.1

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```


## v4.10.6

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.10.6
```
first, just CENPA_primates_aln2a_only5seqs.fa .

I need the `--strict=loose` option, because for this PAML version M2 and M8 don't print 'Time used' at the end of the mlc file.  I think they otherwise worked: there are no obvious errors, and the results are very similar to other PAML versions.  Even if I run PAML directly from the command-line I don't see the cause of the premature stop.
```
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# add Mx (unmasked and CpG-masked)
cp ../testAlignments/Mx1_PAML25.fasta.names .
cp ../testAlignmentsMaskCpG/Mx1_PAML25.fasta.names.removeCpGcodons.fa .
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

```

xxxx one of the jobs ran out of time!
```
more slurm-5017885.out
slurmstepd-gizmok42: error: *** JOB 5017885 ON gizmok42 CANCELLED AT 2022-12-02T23:59:52 DUE TO TIME LIMIT ***
```

with different starting parameters:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.10.6

# default is --codon=2 --omega=0.4
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa

# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml Mx1_PAML25.fasta.names Mx1_PAML25.fasta.names.removeCpGcodons.fa
```


# and CpG masked.

Not biologically relevant for the two Drosophila alignments. Wondering if it will allow the newer PAML versions to show me positive selection for ACE2 once again.

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions
mkdir testAlignmentsMaskCpG
cd testAlignmentsMaskCpG

ln -s ../testAlignments/* .
../../../pamlWrapper/scripts/pw_maskCpGsitesInAlignment.bioperl *

mkdir hide
mv *removeCpGcodons.fa hide/
rm *fa *fasta
mv hide/* .
rmdir hide
```

run PAML using each version

4.8 
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.8 
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml *removeCpGcodons.fa
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml  *removeCpGcodons.fa
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3  --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml  *removeCpGcodons.fa
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml  *removeCpGcodons.fa
```

4.9a installed myself
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml *removeCpGcodons.fa
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml  *removeCpGcodons.fa
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml  *removeCpGcodons.fa
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml  *removeCpGcodons.fa
```

4.9a installed via conda, singularity container
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9a_via_sif1.1.0
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif *removeCpGcodons.fa 
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif *removeCpGcodons.fa 
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif *removeCpGcodons.fa 
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.1.0.sif *removeCpGcodons.fa 
```

4.9j outside singularity (at the time of running I had 4.9j as the default in my PATH)
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j  
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl *removeCpGcodons.fa 
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 *removeCpGcodons.fa 
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 *removeCpGcodons.fa 
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 *removeCpGcodons.fa 
```

4.9j inside singularity
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.9j_via_sif1.2.1  
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif *removeCpGcodons.fa 
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif *removeCpGcodons.fa
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=2 --omega=3 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif *removeCpGcodons.fa
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --add=1 --codon=3 --omega=0.4 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.1.sif *removeCpGcodons.fa
```

4.10.6
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.10.6
cp ../testAlignmentsMaskCpG/* .
# default is --codon=2 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml *removeCpGcodons.fa 
# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml *removeCpGcodons.fa 
# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=2 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml *removeCpGcodons.fa 
# --codon=3 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --codon=3 --omega=0.4 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml *removeCpGcodons.fa 
```




## combining results across different versions:

### first set of results
The PAMLsummaries.tsv files are from BEFORE I added tests for conversion and I'm not looking at CpG masked for now

```
# CG31882_sim
pw_combineParsedOutfilesLong.pl test_codeml_*/CG31882_sim.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882_sim_PAMLsummaries.tsv 

# Abo
pw_combineParsedOutfilesLong.pl test_codeml_*/Dmel_22_aln.fasta_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22_aln_PAMLsummaries.tsv 

# CENPA just 5 seqs
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_only5seqs.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_primates_aln2a_only5seqs_PAMLsummaries.tsv 

# TRIM5
pw_combineParsedOutfilesLong.pl test_codeml_*/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_TRIM5_PAMLsummaries.tsv 

# CENPA all seqs
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_primates_aln2a_NT_PAMLsummaries.tsv 

# ACE2
pw_combineParsedOutfilesLong.pl test_codeml_*/ACE2_primates_aln1_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2_PAMLsummaries.tsv 

# Mx - I'm doing this after running a bunch of other things, so I add more to the * to help pick out only the comparable results

pw_combineParsedOutfilesLong.pl test_codeml_*/Mx1_PAML25.fasta.names_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Mx1_PAMLsummaries.tsv 
```


### second set of results
AFTER I added tests for conversion and Mx. Still not looking at CpG masked results here

### deal with some failed PAMLs.   Likely ran out of walltime

When I first tried to do the parsing, there were some weird failures. Systematically check for them - the `*PAMLsummary.tsv` files should have 8 lines in them.  Find the ones that don't

```
wc test_*/*PAML/*ry.tsv | grep -v ' 8 '
     1     28    322 test_codeml_4.10.6/ACE2_primates_aln1_NT.fa_phymlAndPAML/ACE2_primates_aln1_NT.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     1     28    322 test_codeml_4.10.6/CENPA_primates_aln2a_NT.fa_phymlAndPAML/CENPA_primates_aln2a_NT.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     4     82   1008 test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/ACE2_primates_aln1_NT.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     4     82   1008 test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/ACE2_primates_aln1_NT.codonModel3_initOmega3_cleandata0.PAMLsummary.tsv
     4     82   1023 test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/CENPA_primates_aln2a_NT.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     4     82   1021 test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/CENPA_primates_aln2a_NT.codonModel3_initOmega3_cleandata0.PAMLsummary.tsv
     7    146   1602 test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/CG31882_sim.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     7    146   1602 test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/CG31882_sim.codonModel3_initOmega3_cleandata0.PAMLsummary.tsv
     6    121   1402 test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/Dmel_22_aln.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     6    121   1402 test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/Dmel_22_aln.codonModel3_initOmega3_cleandata0.PAMLsummary.tsv
     7    146   2741 test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.codonModel2_initOmega3_cleandata0.PAMLsummary.tsv
     6    121   1922 test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.codonModel3_initOmega3_cleandata0.PAMLsummary.tsv
```

Remove the corresponding outputs:
```
rm -r test_codeml_4.10.6/ACE2_primates_aln1_NT.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.10.6/ACE2_primates_aln1_NT.fa_phymlAndPAML/*initOmega3_codonModel2  
rm -r test_codeml_4.10.6/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.10.6/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*initOmega3_codonModel2 
rm -r test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/*initOmega3_codonModel2 
rm -r test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/*codonModel3_initOmega3_cleandata0* test_codeml_4.9j/ACE2_primates_aln1_NT.fa_phymlAndPAML/*initOmega3_codonModel3
rm -r test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*initOmega3_codonModel2
rm -r test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*codonModel3_initOmega3_cleandata0* test_codeml_4.9j/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*initOmega3_codonModel3
rm -r test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/*initOmega3_codonModel2
rm -r test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/*codonModel3_initOmega3_cleandata0* test_codeml_4.9j/CG31882_sim.fa_phymlAndPAML/*initOmega3_codonModel3
rm -r test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/*initOmega3_codonModel2
rm -r test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/*codonModel3_initOmega3_cleandata0* test_codeml_4.9j/Dmel_22_aln.fasta_phymlAndPAML/*initOmega3_codonModel3
rm -r test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*codonModel2_initOmega3_cleandata0* test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*initOmega3_codonModel2 
rm -r test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*codonModel3_initOmega3_cleandata0* test_codeml_4.9j/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*initOmega3_codonModel3
```

Check I removed all the 'bad' outputs - I did
```
wc test_*/*PAML/*ry.tsv | grep -v ' 8 '
```

Rerun them, using more walltime this time (`--walltime=7-0`)
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions/test_codeml_4.10.6
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --walltime=7-0 --add --codon=2 --omega=3 --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa 
    xxxx 9951857 and 9951858

cd ../test_codeml_4.9j
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --walltime=7-0 --add --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fasta TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 
    xxx 9952938 - 9952942
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --walltime=7-0 --add --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fasta TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa 
    xx 9952943 - 9952947
```

xxxx once they have run, parse the output

```
# CG31882_sim
pw_combineParsedOutfilesLong.pl test_codeml_*/CG31882_sim.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882_sim_PAMLsummaries_2.tsv 

# Abo
pw_combineParsedOutfilesLong.pl test_codeml_*/Dmel_22_aln.fasta_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22_aln_PAMLsummaries_2.tsv 

# CENPA just 5 seqs
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_only5seqs.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_primates_aln2a_only5seqs_PAMLsummaries_2.tsv 

# TRIM5
pw_combineParsedOutfilesLong.pl test_codeml_*/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_TRIM5_PAMLsummaries_2.tsv 

# CENPA all seqs
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_primates_aln2a_NT_PAMLsummaries_2.tsv 

# ACE2
pw_combineParsedOutfilesLong.pl test_codeml_*/ACE2_primates_aln1_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2_PAMLsummaries_2.tsv 

# Mx
pw_combineParsedOutfilesLong.pl test_codeml_*/Mx1_PAML25.fasta.names_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Mx1_PAMLsummaries_2.tsv 
```

### results - the NAN problem

Check for 'nan' - version 4.9 run via singularity gives 'nan' in the rst file for ALL input files. None of the other PAML versions give the 'nan' values.
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions
grep -l 'nan' test*/*/M8_*/rst
    # the only stuff that comes up is in the test_codeml_4.9a_via_sif1.1.0 folder
```

### results - actual PAML results

ACE2 results look VERY different for v4.9j and later.  
v4.8 and v4.9a - positive selection
v4.9j and v4.10.6 - NO support for positive selection

Try running with different starting parameters??  The dN/dS of the positively selected class is VERY high for v4.9j and v4.10.6 (999 or 781) with VERY few pos sel sites (0.0005 or 0.0003) but more like dN/dS=4.7 for 0.03 of the sites for the versions that DID show positive selection.

Mx1 results 
v4.8 and v4.9a - positive selection
v4.9j - NO support for positive selection if I run via singularity, but DOES support positive selection when run OUTSIDE singularity (M8 tests only, NOT M2vsM1). I probably should double-check I didn't mess anything up.
v4.10.6 - (run via command line) NO support for positive selection

Similar finding to ACE2 (newer PAMLs M8 gives VERY small proportion of sites with VERY high dN/dS)

xxxx I have RUN paml with the other starting parameters but have not yet looked at the results

For these other alns - results are very similar across PAML versions (p-values, proportion and dN/dS of selected site)
- TRIM5
- CENPA  (no positive selection with this alignment, with any of the PAML versions. That's OK)
- Abo (Dmel_22)  
- CG31882 (Ching-Ho gene, I think?) 
xxx compare results.

xxx also run newer version?

Mx - xxx what does that look like?

xxx are the sites it thinks have dN/dS=999 sites with CpG residues?
xxx are the rst dN/dS estimates similar?



on Feb 9 2023 (and before) the version of PAML that's in my path (/home/jayoung/malik_lab_shared/linux_gizmo/bin/codeml) is paml version 4.9j, February 2020 and for Mx and ACE2 that version does NOT give me results I like as much.   AND for M2 it can take a very long time.

Feb 9 2023 - I will revert to 4.9a!

# pamlHistory.txt 

These bits of text come from [pamlHistory.txt](https://github.com/abacus-gene/paml/blob/master/doc/pamlHistory.txt)

Version 4.9g, December 2017

(*) codeml.  A bug caused the BEB calculation under the site model M8
(NSsites = 8) to be incorrect, with the program printing out warming
messages like "strange: f[ 5] = -0.0587063 very small."  This bug was
introduced in version 4.9b and affects versions 4.9b-f.  A different
bug was introduced in version 4.9f that causes the log likelihood
function under the site model M8 (NSsites = 8) to be calculated
incorrectly.  These are now fixed.






