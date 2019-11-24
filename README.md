# DMproject

### Group project
- [Fabio Colella](https://www.linkedin.com/in/fabio-colella-099858162/)
- [Michele Vantini](https://www.linkedin.com/in/michele-vantini-9825bb42/)

## Environment

The project has been tested on Ubuntu 16.04 Xenial and 18.04 Bionic. While the
project is cross platform in its nature, there might be some problems while using
different systems.

Please, run each script from the folder in which the file is.

If using jupyter notebook, run it from the folder in which the file is.

Example:
```
cd DMproject/dmproject/exact
jupyter notebook
```


## General setup

Please, run the following commands in order to get the project set up on your
system:
```shell
git clone https://github.com/michelevantini/DMproject.git
wget https://www.dropbox.com/s/0yf5jeov2ahe12k/Wiki-Vote.txt
wget https://www.dropbox.com/s/2af1d1d86wvf3xx/soc-Epinions1.txt
wget https://www.dropbox.com/s/prunxyqfxabk2u8/gplus_combined.txt
wget https://www.dropbox.com/s/pqptlgakyno0dc1/soc-pokec-relationships.txt
mv Wiki-Vote.txt DMproject/dmproject/dataset/wiki_vote
mv soc-Epinions1.txt DMproject/dmproject/dataset/epinions
mv gplus_combined.txt DMproject/dmproject/dataset/gplus
mv soc-pokec-relationships.txt DMproject/dmproject/dataset/soc_pokec
```

## Python setup

This project requires Python >= 3.4. You can install the required dependencies
with the following command:
```
pip3 install --user networkx numpy
```


## Julia setup

This project requires Julia 0.6 (it might work with future versions but API are
not set in stone). 

```shell
wget https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.2-linux-x86_64.tar.gz
tar -xzf julia-0.6.2-linux-x86_64.tar.gz
```

This will download and extract the Julia compiler. You can run Julia from
```shell
julia-d386e40c17/bin/julia  # the name of the folder may change!
```

Example of how to run the exact computation in Julia:
```shell
julia-d386e40c17/bin/julia DMproject/dmproject/dataset/exact/exact_diam.jl | tee julia_log.txt
```

You can as well run Julia as a Jupyter Notebook:

```shell
julia-d386e40c17/bin/julia  # the name of the folder may change!
```

```Julia
Pkg.add("IJulia")
using IJulia
IJuia.notebook()
```

Then select the appropriate notebook. Please, note that the Python environment
from IJulia might not be the same as you would expect.


