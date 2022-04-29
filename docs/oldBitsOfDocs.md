# To run these scripts on rhino/gizmo, before I figured out singularity

Unlikely: if your gizmo/rhino environment IS set up like mine (only true for a few people in the lab - I've been moving away from doing this) - I think you may be able to run the scripts after loading an R module. Try it and let me know what happens:
```
module load fhR/4.1.2-foss-2020b
pw_makeTreeAndRunPAML.pl myAln.fa
module purge
```

More likely: if your gizmo/rhino environment is NOT set up like mine, you should first do this, so that the necessary programs are available to you.  This hasn't been tested yet (and I can't test it myself, so please give it a try and let me know what happens. There may be errors at first but I would love to get this working).
```
source /fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper/scripts/pw_gizmoRhinoEnvironmentSetup.sh
```
I think you should be able to run the scripts now. After you've finished your PAML work, you probably want to restore your environment to it's original state:
```
source /fh/fast/malik_h/user/jayoung/paml_screen/pamlWrapper/scripts/pw_gizmoRhinoEnvironmentRestore.sh
```
