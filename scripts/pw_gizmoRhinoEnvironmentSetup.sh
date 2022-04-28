# so we can restore original settings once we're done
export OLD_PATH=$PATH
export OLD_PERL5LIB=$PERL5LIB

# set up for the pamlWrapper scripts:
export PAML_WRAPPER_HOME=/fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper
export PATH=$PAML_WRAPPER_HOME/scripts:$PATH

# add a dir containing codeml and phyml and perl to the PATH:
export PATH=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/bin:$PATH

# load R and bioperl modules
module load fhR/4.1.2-foss-2020b
module load BioPerl/1.7.8-GCCcore-10.2.0

# make sure we can find the other perl modules we need
export TEMP_PL=/fh/fast/malik_h/grp/malik_lab_shared/linux_gizmo/lib
export TEMP_PL=/fh/fast/malik_h/grp/malik_lab_shared/perl/lib/perl5:$TEMP_PL
if [ -z ${PERL5LIB+x} ] 
then
    export PERL5LIB=$TEMP_PL
else
    export PERL5LIB=$TEMP_PL:${PERL5LIB}
fi
unset TEMP_PL

