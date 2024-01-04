# coreutils-experiment
Shell scripts about running coreutils experiment with KLEE

# How to build coreutils
## Step 1: Build coreutils with gcov

let's build a version of coreutils with gcov support. We will use this later to get coverage information on the test cases produced by KLEE.

From inside the coreutils directory, we'll do the usual configure/make steps inside a subdirectory (obj-gcov). Here are the steps:

> the `configure` script is being run as the root user. This is generally not recommended for security reasons, as it can lead to inadvertent changes to system files.
>
> However, if we understand the risks and still want to proceed, we can bypass this check by setting the `FORCE_UNSAFE_CONFIGURE` environment variable to `1`

```shell
scoreutils-9.4-src# export FORCE_UNSAFE_CONFIGURE=1
scoreutils-9.4-src# CC=gcc ./configure --disable-nls CFLAGS="-g -fprofile-arcs -ftest-coverage"
scoreutils-9.4-src# CC=gcc make
```

> We build with `--disable-nls` because this adds a lot of extra initialization in the C library which we are not interested in testing. Even though these aren’t the executables that KLEE will be running on, we want to use the same compiler flags so that the test cases KLEE generates are most likely to work correctly when run on the uninstrumented binaries.

We should now have a set of `coreutils` in the `objc-gcov/src` directory, and we can use them to get the precise ICov because `gcov` is only considering lines in that one file, not the entire application.

## Step 2: Run a KLEE evaluation

A script, `run_klee_coreutils.sh`, has been provided to reproduce the results over the coreutils bcfiles which have already been compiled.

```shell
coreutils-9.4-bc# ./run_klee_coreutils.sh
...
coreutils-9.4-bc# ls result_all/
...
```

We can see the outputs over the `coreutils-9.4-bc/result_all`.

## Step 3: Replay KLEE generated test cases

We can use the `klee-replay` tool to run a set of test cases at once, one after the other. Now change directory to the `coreutils-9.4-src/obj-gcov/src`, we are going to use `gcov` to see exactly what lines were covered and which weren't.

Let's take `echo` as an example:

```shell
src# rm -f *.gcda # Get rid of any stale gcov files
src# klee-replay ./echo /home/user/coreutils-test/coreutils-9.4-bc/result_all/echo_output/*.ktest
...
src# gcov echo
...
Lines executed: xx.xx % of xxx
...
```
The echo.c.gcov file will be generated at directory coreutils-9.4-src

As `gcov` is only considering lines in that one file, not the entire application, we should finally have reasonable coverage of `echo.c`.

# experiment
run ```multi_run.sh``` to generate test cases and run ```replay_coreutils.sh``` to get coverage report