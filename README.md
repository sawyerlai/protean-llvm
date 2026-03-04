# HOW TO RUN PROTEAN:
(or, at least, this is what worked for me)

`$CLANG=llvm/build/bin/clang`

`$CLANG -O2 -S -emit-llvm protean_ex.c -o protean_ex.ll`

Then, create a copy of the .ll file to hold the annotated version (I called my annotated_protean_ex.ll). Annotate the file with void declarations (see annotated_protean_ex.ll for examples).

Then, run the protean pass over the unedited and the annotated .ll files:

`/protean/llvm/build/bin/clang -O2   -mllvm -x86-ptex=ct   protean_ex.ll -o out_ct`

`/protean/llvm/build/bin/clang   -O2   -no-pie   -mllvm -x86-ptex=cts   annotated_protean_ex.ll -o out_cts_annotated`

The two outputs can be dumped with `objdump -d file_name`

# OTHER HELPFUL THINGS:

build & compile a program with the following commands:

CLANG=llvm/build/bin/clang

# ARCH (no-op effectively)
$CLANG -O2 -mllvm -x86-ptex=arch simple_example.c -o out_arch

# Static constant-time
$CLANG -O2 -mllvm -x86-ptex=cts simple_example.c -o out_cts

# Constant-time
$CLANG -O2 -mllvm -x86-ptex=ct simple_example.c -o out_ct

# Unrestricted (maximum protection)
$CLANG -O2 -mllvm -x86-ptex=unr simple_example.c -o out_unr



# The Protean Spectre Defense
This repository contains the source code for a prototype of Protean,
as presented in the HPCA'26 paper _Protean: A Programmalbe Spectre Defense_.

Artifact evaluators: please see [this section](#Artifact-Evaluation).

## Artifact Evaluation
Use the following commands to run the artifact evaluation (where `/host/path/to/cpu2006.iso` points to your copy of the SPEC CPU2006 benchmarks ISO image
and `$`/`#` denotes a shell command executed on the host / in the Docker container):
```
$ curl -L https://zenodo.org/records/17857896?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImQzYTlhMjE3LWFjNzEtNGJiNC1iZWNkLTg1Y2Y1ZmE4NmE3MyIsImRhdGEiOnt9LCJyYW5kb20iOiJjMzBjZGFiZjg3NGJlMzUxZTFmNmEwMzI4MDIxNTRhZiJ9._yZvid8Wm9o7c3d5jar_f0t90myhGMcDTu0U7-MWacq3uWci7Wo6QKp2fOTpIFkD3qCNyTjV0F2peKokd74rTg | docker load
$ docker run --name protean-container -it protean:latest
$ docker cp /host/path/to/cpu2006.iso protean-container:/protean/cpu2006.iso
$ docker exec -it protean-container /bin/bash
# ./extract-spec-cpu2006-iso.sh
# ./table-v.py --bench={lbm,hacl.poly1305,bearssl,ossl.bnexp,nginx.c1r1}
# ./table-ii.py --instrumentation=rand
```

## Building with Docker
To build Protean with Docker, run the following commands:
```
$ git clone https://github.com/StanfordPLArchSec/protean.git
$ cd protean
$ git submodule update --init --recursive --depth=1
$ ./docker/build.sh
$ ./docker/run.sh
# ./build.sh
```
Note that building everything will take a _long_ time.

## Extending Protean's Evaluation Infrastructure
We implemented an extensive Snakemake-based infrastructure for 
evaluating the performance and security of Protean.
Luckily, this infrastructure can be easily extended to 
[add new benchmarks](https://github.com/StanfordPLArchSec/protean-bench/blob/main/example/README.md)
and evaluate the [performance](https://github.com/StanfordPLArchSec/protean-bench/blob/main/HW-SW.md) and [security](https://github.com/StanfordPLArchSec/protean-amulet/blob/protean/HW-SW.md) of new hardware-software codesigns.
