
# the usual git updates:
```
git add --verbose --all .
git commit
git push
```

# pushing the docker image to the hub

first we add a new tag to the local docker image - this tag includes my hub.docker user name
```
docker tag paml_wrapper jayoungfhcrc/paml_wrapper
```
then we push the local image up to docker hub, using default tag 'latest'. This is a bit slow.
```
docker push jayoungfhcrc/paml_wrapper
```
I could also have given it a tag of my own, if I want to name certain versions:
```
# docker push jayoungfhcrc/paml_wrapper:version1
```

I can test my container using the [Play with Docker](https://labs.play-with-docker.com) site - it seems to work
```
docker run -it jayoungfhcrc/paml_wrapper
cd pamlWrapper/testData/
pw_makeTreeAndRunPAML.pl CENPA_primates_aln2a_NT.fa
```
