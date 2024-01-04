## ATTENTION: This shell script runs on klee/klee:3.0 with LLVM version 13.0.0 and clang version 13.0.0.
## ATTENTION: This shell script is also just a test to see if our compilation runs with klee 3.0. No relation to the project recolossus under development.

## KLEE : Sometimes must be defined by user ####
KLEE_EXE_PATH="/home/user/recolossus/build/bin/klee"
# LIBM_PATH="/home/user/tmp/klee-uclibc-130/lib/libm.a"
#### running config ####
MAX_EXE_TIME=10
SEARCH="bfs"

#########################################

# remove pre running result info
KLEE_OUT_DIR_ALL=${PWD}/"result_all"
rm -rf ${KLEE_OUT_DIR_ALL}
mkdir ${KLEE_OUT_DIR_ALL}

cd bcfiles

# get worklist from cmdline
dirvers=$*

ARGS="--sym-args 0 1 10 --sym-args 0 2 2 --sym-files 1 8 --sym-stdin 8 --sym-stdout"

# extract the names of all files in the current directory without the dot and suffix
# dirvers=""
# for file in *; do
#   dirvers+="$(basename "$file" .bc) "
# done
# dirvers="${dirvers}"| sed 's/[[:space:]]*$//'

# # remove trailing whitespaces from the string
# dirvers="${dirvers%"${dirvers##*[![:space:]]}"}"

# dirvers="echo ls pwd who whoami"
dirvers="cksum wc"
for dirv in ${dirvers}:
do
  # get absolute driver.c path
  reg_dirv=`echo ${dirv%%:*}`
  driver_name=`echo ${reg_dirv%.*}`

  #if [ ${driver_name} = "echo" ];then
  echo "     Running ======== > "${driver_name}

  if [ ${driver_name} = "dd" ];then
	ARGS="--sym-args 0 3 10 --sym-files 1 8 --sym-stdin 8 --sym-stdout"
  elif [ ${driver_name} = "dircolors" ];then
	ARGS="--sym-args 0 3 10 --sym-files 2 12 --sym-stdin 12 --sym-stdout"
  elif [ ${driver_name} = "echo" ];then
	ARGS="--sym-args 0 4 300 --sym-files 2 30 --sym-stdin 30 --sym-stdout"
  elif [ ${driver_name} = "expr" ];then
	ARGS="--sym-args 0 1 10 --sym-args 0 3 2 --sym-stdout"
  elif [ ${driver_name} = "mknod" ];then
	ARGS="--sym-args 0 1 10 --sym-args 0 3 2 --sym-files 1 8 --sym-stdin 8 --sym-stdout"
  elif [ ${driver_name} = "od" ];then
	ARGS="--sym-args 0 3 10 --sym-files 2 12 --sym-stdin 12 --sym-stdout"
  elif [ ${driver_name} = "pathchk" ];then
	ARGS="--sym-args 0 1 2 --sym-args 0 1 300 --sym-files 1 8 --sym-stdin 8 --sym-stdout"
  elif [ ${driver_name} = "printf" ];then
	ARGS="--sym-args 0 3 10 --sym-files 2 12 --sym-stdin 12 --sym-stdout"	
  fi

  KLEE_OUT_DIR=${KLEE_OUT_DIR_ALL}/${driver_name}"_output"
  TIME_LOG_TXT=${KLEE_OUT_DIR}/"execute_time.txt"
    
  # remove pre running info
  rm -rf ${KLEE_OUT_DIR}

  # run klee to get Ktest inputs
  start_second=$(date +%s)

  ${KLEE_EXE_PATH}  --max-solver-time=30 \
        --search=${SEARCH} \
        --libc=uclibc --posix-runtime \
        -watchdog -max-time=${MAX_EXE_TIME}  \
        -output-dir=${KLEE_OUT_DIR} \
        --external-calls=all \
        --only-output-states-covering-new \
        ${driver_name}".bc" ${ARGS}

  end_second=$(date +%s)
  touch ${TIME_LOG_TXT}
  echo " "$((end_second-start_second))" " > ${TIME_LOG_TXT}

  # delete 'assembly.ll','run.istats' in klee-output, because their size are too large
  rm -f ${KLEE_OUT_DIR}/assembly.ll  ${KLEE_OUT_DIR}/run.istats

  #fi

done