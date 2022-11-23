#!/bin/bash
source /app/lmod/lmod/init/profile
module load Singularity/3.5.3
singularity exec --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages/paml_wrapper-v1.2.0.sif pw_makeTreeAndRunPAML.pl  --omega=0.4 --codon=2 --clean=0 --BEB=0.9 CENPA_primates_aln2a_NT.fa &>> CENPA_primates_aln2a_NT.fa.codon2_omega0.4_clean0_runPAML.log.txt
echo
module purge
