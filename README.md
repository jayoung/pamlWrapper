# pamlWrapper
starting with an in-frame alignment, this repo has code that will run PAML's codeml (various models) and parse output

[git repo](https://github.com/jayoung/pamlWrapper)

on my mac: `/Users/jayoung/gitProjects/pamlWrapper`  



# docker stuff

Dockerfile contains instructions to install a bunch of stuff using conda. I copied some of it from [Rasi](https://github.com/rasilab/bottorff_2022/blob/main/Dockerfile)


Building my container seems to work fine on my work Mac:
```
cd /Users/jayoung/gitProjects/pamlWrapper/buildContainer
docker build -t paml_wrapper .
```

test my docker image for vulnerabilities: not sure I really need to do this. It DOES find various problems, I think all with the base debian system. None are labeled 'critical'. See [here](https://docs.docker.com/get-started/09_image_best/). I think I'll just proceed.
```
docker scan paml_wrapper
```

show how the build layers were added:
```
docker image history paml_wrapper
```

Open a shell in that core:
```
docker run -it paml_wrapper
```

That gives me a new command line within the container. From there, I try some stuff, and I think I have it working:
```
which codeml
    /opt/conda/bin/codeml
which phyml
    /opt/conda/bin/phyml
phyml
R
```

Open a shell in that core, mounting a folder as a volume. This does create a folder called testData in the container but it does not pass in the file that's in testData

The local path must be an ABSOLUTE path for this to work right (at least on my mac)
```
docker run -v /Users/jayoung/gitProjects/pamlWrapper/buildContainer/testData:/testData2 -it paml_wrapper
```

or mount the entire current dir:
```
docker run -v `pwd`:/testData2 -it paml_wrapper
```




# the usual git updates:
```
git add --verbose --all .
git commit
git push
```