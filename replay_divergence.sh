export KLEE_REPLAY_TIMEOUT=10

KLEE_PATH="/home/user/recolossus/build/bin"
KLEE_EXE_PATH=${KLEE_PATH}"/klee"
KLEE_REPLAY_PATH=${KLEE_PATH}"/klee-replay"
KLEE_OUT_DIR=${PWD}"/klee-last"
GET_GCOV_INFO_PY=${PWD}"/get_coverage_line.py"
DIVERGENCE_LIST=${PWD}"/divergence_list.txt"
rm ${DIVERGENCE_LIST}
touch ${DIVERGENCE_LIST}
echo "======  Divergence List  ======" >> ${DIVERGENCE_LIST}

FILE_NAME=$1
FILE_C_NAME=${FILE_NAME}".c"
${KLEE_EXE_PATH} --max-solver-time=30 --search=bfs --external-calls=all --write-cov ${FILE_NAME}.bc
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
    rm *.gcda *.gcov
    cov_file_path="${KLEE_OUT_DIR}/$(basename "$ktest_file" .ktest).cov"
    export KTEST_FILE=${ktest_file}
    ${KLEE_REPLAY_PATH} ${FILE_NAME} ${ktest_file}
    gcov ${FILE_NAME}
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