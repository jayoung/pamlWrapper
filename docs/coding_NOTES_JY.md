# the usual git updates:
```
git add --verbose --all .
git commit
git push
```

# updating the docker image:

My mac has docker installed, gizmo/rhino do not. But I am keeping the master copy of the repo on gizmo/rhino.  Make sure that's synced to github, then:

On the mac, first we make sure we have the latest version of the pamlWrapper git repo:

```
cd /Users/jayoung/gitProjects/pamlWrapper
git pull
```

Then we re-build the docker image
```
docker build -t paml_wrapper -f buildContainer/Dockerfile .
```
To get a shell for a quick look:
```
docker run -v `pwd`:/workingDir -it paml_wrapper
```

When I know it's working I add a new tag and push it to [docker hub](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper).  I update the version number each time:
```
docker tag paml_wrapper jayoungfhcrc/paml_wrapper:version1.0.3
docker push jayoungfhcrc/paml_wrapper:version1.0.3
```

I then test my container in a totally different environment using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work. Once I have an instance running there:
```
docker run -it jayoungfhcrc/paml_wrapper:version1.0.3
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```

# convert docker image to singularity

On gizmo/rhino:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/buildContainer
module purge
module load Singularity/3.5.3
singularity build paml_wrapper-v1.0.3.sif docker://jayoungfhcrc/paml_wrapper:version1.0.3
module purge
```


a file called paml_wrapper-v1.0.3.sif appears. 

I could get a shell in the singularity container like this:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
module load Singularity/3.5.3
singularity shell --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages
module purge
```

And within the shell, this works.
```
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
```

Or, I can run some code using the singularity image without entering a shell:
```
module load Singularity/3.5.3
singularity exec --cleanenv /fh/fast/malik_h/grp/malik_lab_shared/singularityImages pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa 
module purge
```

and when we're done:
```
module purge
```

The `pw_makeTreeAndRunPAML_singularityWrapper.pl` script will run pw_makeTreeAndRunPAML.pl on each alignment

I want a copy of the singularity image file, and a script that uses it, in a more central place, for use by others:
```
cp paml_wrapper-v1.0.3.sif /fh/fast/malik_h/grp/malik_lab_shared/singularityImages
cp ../scripts/pw_makeTreeAndRunPAML_singularityWrapper.pl /fh/fast/malik_h/grp/malik_lab_shared/bin/runPAML.pl
```