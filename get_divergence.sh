export KLEE_REPLAY_TIMEOUT=10

FILE_NAME=$1
GCOV_PATH="/home/user/coreutils-test/coreutils-9.4-src"
GCDA_PATH=${GCOV_PATH}"/src"
KLEE_PATH="/home/user/recolossus/build/bin"
KLEE_EXE_PATH=${KLEE_PATH}"/klee"
KLEE_REPLAY_PATH=${KLEE_PATH}"/klee-replay"
KLEE_OUT_DIR=${PWD}"/result_all/"${FILE_NAME}"_output"
GET_GCOV_INFO_PY=${PWD}"/compute_divergence.py"
DIVERGENCE_LIST=${PWD}"/divergence_list.txt"
rm ${DIVERGENCE_LIST}
touch ${DIVERGENCE_LIST}
echo "======  Divergence List  ======" >> ${DIVERGENCE_LIST}

FILE_NAME=$1
FILE_C_NAME=${FILE_NAME}".c"
KTEST_LIST=${KLEE_OUT_DIR}"/*.ktest"
COV_LIST=${KLEE_OUT_DIR}"/*.cov"
# echo ${KTEST_LIST[@]}
# echo ${COV_LIST[@]}
# echo ${NUM_KTEST}
# echo ${NUM_COV}
NUM_KTEST=0
NUM_DIVERGENCE=0
for ktest_file in ${KTEST_LIST}
do
    NUM_KTEST=$((NUM_KTEST+1))
    rm ${GCDA_PATH}/*.gcda ${GCOV_PATH}/*.gcov
    cov_file_path="${KLEE_OUT_DIR}/$(basename "$ktest_file" .ktest).cov"
    export KTEST_FILE=${ktest_file}
    ${KLEE_REPLAY_PATH} ${GCDA_PATH}/${FILE_NAME} ${ktest_file}
    cd ${GCOV_PATH}
    gcov "src/"${FILE_NAME}
    gcov_res_path=${PWD}"/"${FILE_C_NAME}".gcov"

    divergence=$(python3 ${GET_GCOV_INFO_PY} ${gcov_res_path} ${cov_file_path} ${FILE_C_NAME}) 
    if [[ ${divergence} == "True" ]]; then
        NUM_DIVERGENCE=$((NUM_DIVERGENCE+1))
        echo ${ktest_file} >> ${DIVERGENCE_LIST}
    fi
done
echo >> ${DIVERGENCE_LIST}
echo "======  STATISTICS  ======" >> ${DIVERGENCE_LIST}
echo "NUM_KTEST: "${NUM_KTEST} >> ${DIVERGENCE_LIST}
echo "NUM_DIVERGENCE: "${NUM_DIVERGENCE} >> ${DIVERGENCE_LIST}