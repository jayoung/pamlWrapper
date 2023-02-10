Running tests again now that I added `--verbose` and made a singularity container that includes 5 versions of paml.   Running all 5 versions with and without singularity, all with a check for robustness

## via sif1.3.0

4.9a_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9g --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9h_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9h_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9h ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9h --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9j_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9j_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9j ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.9j --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.10.6_via_sif1.3.0
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sif1.3.0

# --codon=2 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.10.6 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=2 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=3 --omega=0.4 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
runPAML.pl --verboseTable=1 --version=4.10.6 --add=1 --codon=3 --omega=3 ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


## via sbatch

4.9a_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9a_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9a/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9g_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9g_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9g/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9h_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9h_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9h/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```

4.9j_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.9j_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.9j/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```


4.10.6_via_sbatch
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments/testPAMLversions_new2023feb9/test_codeml_4.10.6_via_sbatch

# --codon=2 --omega=0.4 
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=2 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=2 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=0.4
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=0.4 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa

# --codon=3 --omega=3
../../../pamlWrapper/scripts/pw_makeTreeAndRunPAML_sbatchWrapper.pl --verboseTable=1 --codeml=/home/jayoung/malik_lab_shared/linux_gizmo/bin/old/paml/v4.10.6/codeml --codon=3 --omega=3 --add ACE2_primates_aln1_NT.fa CENPA_primates_aln2a_NT.fa CENPA_primates_aln2a_only5seqs.fa CG31882_sim.fa Dmel_22_aln.fa Mx1_PAML25.names.fa TRIM5_primates_aln2_NT.treeorder.noPseudsPartials.fa
```