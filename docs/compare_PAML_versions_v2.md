Running tests again now that I added `--verbose` and made a singularity container that includes 5 versions of paml.   Running all 5 versions with and without singularity, all with a check for robustness

## via sif1.3.0

4.9a_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sif1.3.0 (first run). Gives a core dump on M8 for every single run, but I THINK it still ran fine.

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sif1.3.0 (second run). Remove core dump files, remove parsed output files, run with strict=loose

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sif1.3.0

# remove output 
rm *L/*tsv *L/*pdf

# remove core dump files
rm *L/*/core

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --strict=loose ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --strict=loose --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --strict=loose --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --strict=loose --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9h_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9h_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9h ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9j_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9j_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9j ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.10.6_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.10.6 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```




## via sbatch

4.9a_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sbatch (first run). Gives a core dump on M8 for every single run.

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sbatch (second run). Remove old output and re-parse

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sbatch

# remove output 
rm *L/*tsv *L/*pdf
# remove core dump files
rm *L/*/core

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --add=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.9h_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9h_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9j_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9j_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.10.6_via_sbatch - first time I ran it I failed to add the --strict=loose param, to make sure it doesn't think PAML failed. 
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

test_codeml_4.10.6_via_sbatch - remove final outputs and reparse now that the script forces --strict=loose for 10.4.6

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch

# remove old output:
rm *L/*tsv *L/*pdf

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add=1 --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add=1 --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add=1 --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add=1 --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

# try cc compiled versions

4.9a_via_sif1.3.2_cc_compiled
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sif1.3.2_cc_compiled

# --codon=2 --omega=0.4 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.9a_cc ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.9a_cc --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.9a_cc --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.9a_cc --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.10.6_via_sif1.3.2_cc_compiled
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sif1.3.2_cc_compiled

# --codon=2 --omega=0.4 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.10.6cc --strict=loose --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.10.6cc --strict=loose --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.10.6cc --strict=loose --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
~/FH_fast_storage/paml_screen/pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --verboseTable=1 --version=4.10.6cc --strict=loose --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.10.6_via_sbatch_cc_compiled
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch_cc_compiled

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.10.6_via_sbatch_cc_compiled_changeSmallDiff
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch_cc_compiled_changeSmallDiff

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
```

4.9a_via_sbatch_cc_compiled

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sbatch_cc_compiled

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.9a_via_sbatch_cc_compiled_changeSmallDiff

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sbatch_cc_compiled_changeSmallDiff

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=2 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=0.4 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=3 --add=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
```

## combine results 

Just codonModel2_initOmega0.4_cleandata0 results to start

```

cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9

# ACE2_primates_aln1_NT.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/ACE2_primates_aln1_NT.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2_cod2omeg3clean0.PAMLsummaries.tsv 

# CENPA_primates_aln2a_NT.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_cod2omeg3clean0.PAMLsummaries.tsv 

# CG31882_sim.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/CG31882_sim.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882_cod2omeg3clean0.PAMLsummaries.tsv 

# Abo - Dmel_22_aln.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/Dmel_22_aln.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22_cod2omeg3clean0.PAMLsummaries.tsv 

# Mx1_PAML25.names.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/Mx1_PAML25.names.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Mx1_cod2omeg3clean0.PAMLsummaries.tsv 

# TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*codonModel2_initOmega0.4_cleandata0.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_TRIM5_cod2omeg3clean0.PAMLsummaries.tsv 
```

now with ALL params

```
# ACE2_primates_aln1_NT.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/ACE2_primates_aln1_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2_allParams.PAMLsummaries.tsv 

# CENPA_primates_aln2a_NT.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA_allParams.PAMLsummaries.tsv 

# CG31882_sim.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/CG31882_sim.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882_sim_allParams.PAMLsummaries.tsv 

# Dmel_22_aln.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/Dmel_22_aln.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22_allParams.PAMLsummaries.tsv 

# Mx1_PAML25.names.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/Mx1_PAML25.names.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Mx1_allParams.PAMLsummaries.tsv 

# TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
pw_combineParsedOutfilesLong.pl test_codeml_*/TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_TRIM5_allParams.PAMLsummaries.tsv 
```


Use 4.9a!    4.9g and later often fail to find a good p1/w combination for the positively selected class in M8 and M2. See my [github issue](https://github.com/abacus-gene/paml/issues/27).


I also tried cc-compiled versions of 4.10.6 and 4.9a.  Again, for 4.10.6, it gives unstable results (meaning sometimes the low-p1/high-omega/bad-p-value outcome, sometimes the reasonable-p1/reasonable-omega/good-p-value outcome):  depends on whether I run via singularity or sbatch, depends whether I compile with gcc or cc


# use Ziheng's first suggestion

[Ziheng says](https://github.com/abacus-gene/paml/issues/27): 
There has been no change to the optimization routine, so i think it is just a matter of the overall difficulty of the optimisation routine, and the choice of some parameters/settings, rather than a systematic difference between versions. you can check and change some of the following control variables.
SmallDiff = 1e-8 # use a valle between 1e-6 and 1e-9
method = 1 or 0

I've been using 
```
Small_Diff = .5e-6
    method = 1   * 0: simultaneous; 1: one branch at a time
```

I added an option to the script to change smallDiff - it works.

Test again.  Use Small_Diff = 1e-8

Just 4.10.6 and 4.9a, all four parameter choices.  Just sbatch.   Try on Mac?  Compiler does seem to make a difference


On rhino - get a fasta file that matches the tree file I'm going to provide:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sbatch/ACE2_primates_aln1_NT.fa_phymlAndPAML
paml2fastaformat.pl ACE2_primates_aln1_NT.fa.phy
```


On Mac, providing a tree:

v4.9a
```
cd /Users/jayoung/testPAMLversions/2023_Feb27/test_4.9a_mac

# default params (--codon=2 --omega=0.4):
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=2 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=2 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=3 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=3 --omega=0.4
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=0.4 --codeml=/Users/jayoung/source_codes/paml/compiled/paml4.9a/src/codeml --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

```

v4.10.6
```
cd /Users/jayoung/testPAMLversions/2023_Feb27/test_4.10.6_mac

# default params (--codon=2 --omega=0.4):
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=2 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=2 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=3 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa

# --codon=3 --omega=0.4
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=0.4 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
```

```
cd /Users/jayoung/testPAMLversions/2023_Feb27/
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_combineParsedOutfilesLong.pl test*/*_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2.PAMLsummaries.tsv 
```


making a package of files to send to Ziheng

```
cd /Users/jayoung/testPAMLversions
cp -R 2023_Feb27/ testPAMLversions_2023_Feb27
cd testPAMLversions_2023_Feb27

# remove some unneeded files (and remove M0 results from xlsx file):
rm -r tes*/*L/M0*
rm -r tes*/*L/*pdf
rm -r tes*/*L/*tsv

rm -r tes*/*L/ACE2_primates_aln1_NT.fa.phy.fa
rm -r tes*/*L/ACE2_primates_aln1_NT.fa.phy.fa.aliases.txt
rm -r tes*/*L/*treeorder*
rm -r tes*/*L/*nolen
rm -r tes*/*L/plotOmegaDistributions.logfile.Rout

rm -r tes*/ACE2_primates_aln1_NT.fa.phy.fa
rm -r tes*/ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen

cd test_4.10.6_mac/
mv ACE2_primates_aln1_NT.fa.phy.fa_phymlAndPAML/* .
rmdir ACE2_primates_aln1_NT.fa.phy.fa_phymlAndPAML/

cd ../test_4.9a_mac/
mv ACE2_primates_aln1_NT.fa.phy.fa_phymlAndPAML/* .
rmdir ACE2_primates_aln1_NT.fa.phy.fa_phymlAndPAML/

# after editing xlsx file:
cp test_codeml_ACE2.PAMLsummaries.xlsx ../2023_Feb27/test_codeml_ACE2.PAMLsummaries.shortened.xlsx
```

added to the [git issue](https://github.com/abacus-gene/paml/issues/27#), Feb 28, 2023

# use Ziheng's second suggestion

I got a new suggestion from Ziheng (March 7, 2023) via github:
```
In codeml.c, there is a line of code
int getdistance = 0, i, j, k, idata, nc, nUVR, cleandata0;
if you change the number from 0 to 1, codeml will generate better branch lengths as initial values.
i think this is the major difference between the two versions.
```

I did that (see compilation notes on my Mac: /Users/jayoung/source_codes/paml/paml_MAC_installNOTES_JY.txt).  Now re-test:

v4.10.6_changeGetDist
```
cd /Users/jayoung/testPAMLversions/2023_Feb27
mkdir test_4.10.6_mac_changeGetDist/
cd test_4.9a_mac/
cp ACE2_primates_aln1_NT.fa.phy.fa ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ../test_4.10.6_mac_changeGetDist/
cd ../test_4.10.6_mac_changeGetDist/

# default params (--codon=2 --omega=0.4):
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6_changeGetDist/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
# --codon=2 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=2 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6_changeGetDist/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
# --codon=3 --omega=3
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=3 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6_changeGetDist/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
# --codon=3 --omega=0.4
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_makeTreeAndRunPAML.pl --verboseTable=1 --smallDiff=1e-8 --codon=3 --omega=0.4 --codeml=/Users/jayoung/source_codes/paml/compiled/paml-4.10.6_changeGetDist/src/codeml --strict=loose --usertree=ACE2_primates_aln1_NT.fa.phy_phyml_tree.nolen ACE2_primates_aln1_NT.fa.phy.fa
```

```
cd /Users/jayoung/testPAMLversions/2023_Feb27/
/Users/jayoung/gitProjects/pamlWrapper/scripts/pw_combineParsedOutfilesLong.pl test*/*_phymlAndPAML/*PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2.PAMLsummaries_addChangeGetDist.tsv 
```




Also test on server: 

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023mar14

### test_4.9a
cd ../test_4.9a
# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=2 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=0.4 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a_cc/codeml --codon=3 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

### test_4.10.6
cd ../test_4.10.6
# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=2 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=0.4 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc/codeml --codon=3 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa


### test_4.10.6_changeGetDist
cd ../test_4.10.6_changeGetDist
# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc_changeGetDist/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc_changeGetDist/codeml --codon=2 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc_changeGetDist/codeml --codon=3 --omega=0.4 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6cc_changeGetDist/codeml --codon=3 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa

### test_4.10.6_github (cloned and compiled Mar 14, 2023)
cd ../test_4.10.6_github
# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6_github/codeml CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6_github/codeml --codon=2 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6_github/codeml --codon=3 --omega=0.4 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --smallDiff=1e-8 --verboseTable=1 --strict=loose --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6_github/codeml --codon=3 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa


### test_4.10.6_github_apptainer (cloned and compiled Mar 14, 2023)

cd ../test_4.10.6_github_apptainer
# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --smallDiff=1e-8 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.5.sif --version=4.10.6github --verboseTable=1 --strict=loose CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --smallDiff=1e-8 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.5.sif --version=4.10.6github --verboseTable=1 --strict=loose --codon=2 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --smallDiff=1e-8 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.5.sif --version=4.10.6github --verboseTable=1 --strict=loose --codon=3 --omega=0.4 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl --smallDiff=1e-8 --sif=/fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.3.5.sif --version=4.10.6github --verboseTable=1 --strict=loose --codon=3 --omega=3 --add=1 CENPA_primates_aln2a_only5seqs.fa ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.v1.fa
```

Check for errors:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023mar14/
grep -v 'Bind mount overlaps container' */*log.txt | grep -i 'error'
```

Combine results (all alignments, all parameters) 

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023mar14
# just ACE2
pw_combineParsedOutfilesLong.pl test_*/ACE2_*_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_ACE2.PAMLsummaries.tsv 
# just CENPA
pw_combineParsedOutfilesLong.pl test_*/CENPA_primates_aln2a_NT.fa_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CENPA.PAMLsummaries.tsv 
# just CG31882
pw_combineParsedOutfilesLong.pl test_*/CG31882*_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_CG31882.PAMLsummaries.tsv 
# just Dmel_22 (abo)
pw_combineParsedOutfilesLong.pl test_*/Dmel_22*_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Dmel_22.PAMLsummaries.tsv 
# just TRIM5
pw_combineParsedOutfilesLong.pl test_*/TRIM5*_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_TRIM5.PAMLsummaries.tsv 
# just Mx1
pw_combineParsedOutfilesLong.pl test_*/Mx1_PAML25*_phymlAndPAML/*.PAMLsummary.tsv
mv allAlignments.PAMLsummaries.tsv test_codeml_Mx1.PAMLsummaries.tsv 
```

Results:

ACE2 - test_4.10.6_github_apptainer and test_4.10.6_github both give very similar results to what I expected from old PAML.  (the non-true test_4.10.6 does not, until I change the getdist line as suggested by Ziheng)
Mx1 - same as ACE2
CENPA - no positive selection with ANY version, ANY parameter
CG31882 - no positive selection with ANY version, ANY parameter
Dmel_22 - inconsistent positive selection across models. ALL versions and parameter choices act the same
TRIM5alpha - robust positive selection with ALL versions

