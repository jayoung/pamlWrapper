xxx how different are results from paml4.9j (new docker) compared to 4.9a (old docker)?  and compare to v4.8 (old runs outside docker)?

compare overall M8 pvalue as well as BEB results

Ching-Ho's alignment that gives all the nans: CG31882_sim.fa


# Abo, with user tree

This was a case where there were NANs in the BEB output.

4.9j versus 4.9a:  the maximum likelihood and p-values are the same. The BEB is different - 4.9j did find one site where BEB>0.9 and 4.9a found none



xxxx there are MORE RECENT versions of PAML on github


# Run PAML 

## v4.8

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.8
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.8/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa
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
runPAML.pl CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa
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
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml CENPA_primates_aln2a_only5seqs.fa  ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa
```


This command shows there is NO nan problem:
```
grep 'nan' *PAML/M8_*/rst.BEB.tsv 
```

This command confirms that I am running 'version 4.9, March 2015'
```
head -1 *PAML/M8_*/mlc
```

## v4.9j

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

## v4.10.6

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/test_codeml_4.10.6
```
first, just CENPA_primates_aln2a_only5seqs.fa .

I need the `--strict=loose` option, because for this PAML version M2 and M8 don't print 'Time used' at the end of the mlc file.  I think they otherwise worked?  No obvious errors. Same output if I run via command-line and not within the sbatch job.
```
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml CENPA_primates_aln2a_only5seqs.fa 

     xxxx
```
It got MOST of the way there - the BEB section looks complete. I think it IS there except that it didn't print 'Time used' at the end.

Try the other alignments. Does M8 work for ANY of them?
```
../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl  --strict=loose --codeml=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa Dmel_22_aln.fasta CG31882_sim.fa
     xxx running 
```


xxx compare results.

xxx also run newer version?