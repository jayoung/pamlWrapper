# the usual git updates:
```
git add --verbose --all .
git commit
git push
```

# updating the docker image:

My mac has docker installed, gizmo/rhino do not. But I am keeping the master copy of the repo on gizmo/rhino.

On the mac, first we make sure we have the latest version of the pamlWrapper git repo:

```
cd /Users/jayoung/gitProjects/pamlWrapper
git pull
```

Then we re-build the docker image and push it to [docker hub](https://hub.docker.com/repository/docker/jayoungfhcrc/paml_wrapper).  I update the version number each time:
```
docker build -t paml_wrapper -f buildContainer/Dockerfile .
docker tag paml_wrapper jayoungfhcrc/paml_wrapper:version1.0.1
docker push jayoungfhcrc/paml_wrapper:version1.0.1
```

I then test my container in a totally different environment using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work. Once I have an instance running there:
```
docker run -it jayoungfhcrc/paml_wrapper:version1.0.1
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```

# convert docker image to singularity

On gizmo/rhino:
```
cd ~/FH_fast_storage/paml_screen/pamlWrapper/buildContainer
module purge
module load Singularity/3.5.3
singularity build paml_wrapper-v1.0.1.sif docker://jayoungfhcrc/paml_wrapper:version1.0.1
    # the paml_wrapper-v1.0.1.sif file appears

# for a shell:
cd ~/FH_fast_storage/paml_screen/pamlWrapperTestAlignments
singularity shell ../pamlWrapper/buildContainer/paml_wrapper-v1.0.1.sif 
    # I get a shell, but I get this error a lot: 
    #  bash: k5start: command not found

```

Now run some code using the singularity image:
```


singularity exec paml_wrapper-v1.0.1.sif xxxx

module purge
```