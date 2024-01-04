cd /home/user/coreutils-test/coreutils-9.4-src
export FORCE_UNSAFE_CONFIGURE=1
CC=gcc ./configure --disable-nls CFLAGS="-g -fprofile-arcs -ftest-coverage"
CC=gcc make