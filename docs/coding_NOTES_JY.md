# the usual git updates:
```
git add --verbose --all .
git commit
git push
```

# pushing the docker image to the hub

first we add a new tag to the local docker image - this tag includes my hub.docker user name
```
docker tag paml_wrapper jayoungfhcrc/paml_wrapper:version1.0.1
```
then we push the local image up to docker hub. If I hadn't supplied ':version1.0.0' it would gave used the default tag 'latest'. This is a bit slow.
```
docker push jayoungfhcrc/paml_wrapper:version1.0.1
```

I can test my container using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work
```
docker run -it jayoungfhcrc/paml_wrapper:version1.0.1
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl ACE2_primates_aln1_NT.fa
```
