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

4.9g_via_sif1.3.0 (first run). Gives a core dump on M8 for every single run.

xxx make strict=loose for 4.9g as well

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
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sbatch (first run). Gives a core dump on M8 for every single run.

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sbatch (second run). Remove old output and re-parse

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sbatch

# remove output 
rm *L/*tsv *L/*pdf
# remove core dump files
rm *L/*/core

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --add --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.9h_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9h_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9j_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9j_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.10.6_via_sbatch - first time I ran it I failed to add the --strict=loose param, to make sure it doesn't think PAML failed. 
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

test_codeml_4.10.6_via_sbatch - remove final outputs and reparse now that the script forces --strict=loose for 10.4.6

```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch

# remove old output:
rm *L/*tsv *L/*pdf

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --add --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

xxx

## combine results 

Just codonModel2_initOmega0.4_cleandata0 results to start

```
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


Furthermore, I haven't dug into this more