export KLEE_REPLAY_TIMEOUT=10
# Basic tools path
KLEE_PATH="/home/user/recolossus"
SRC_PATH="/home/user/coreutils-test/coreutils-9.4-src"
GCOV_PATH="/home/user/coreutils-test/coreutils-9.4-src/src"
# GCOV_PATH="/home/user/coreutils-test/coreutils-9.4-bc/gcov"


## KLEE : Sometimes must be defined by user ####
KLEE_EXE_PATH=${KLEE_PATH}"/build/bin/klee"
KLEE_REPLAY_PATH=${KLEE_PATH}"/build/bin/klee-replay"
KLEE_HEADFILE_PATH=${KLEE_PATH}"/include"

##
GET_GCOV_INFO_PY=${PWD}"/get_gcov_info.py"

####################################

gcov_base_path=${PWD}/gcovfiles
KLEE_OUT_DIR_ALL=${PWD}/"result_all"
BASE_PATH=${PWD}
BCFILE_PATH=${PWD}/bcfiles
REPORT_PATH=${PWD}/report
rm -rf ${REPORT_PATH}
mkdir ${REPORT_PATH}

# touch new replay result file
result_file=${PWD}/res_all.txt
cover_trend_file=${PWD}/cov_trend.txt
rm -f ${result_file} ${cover_trend_file}
touch ${result_file} ${cover_trend_file}
#删除上一次循环生成的gcda文件和gcov文件
  # remove pre run .gcov .gcda
  rm ${GCOV_PATH}/*.gcda  ${SRC_PATH}/*.gcov

cd ${KLEE_OUT_DIR_ALL}
dirvers=""
for file in *; do
  dirvers+="$(basename "$file" _without_stdin_out_output) "
done
dirvers="${dirvers}"| sed 's/[[:space:]]*$//'

# remove trailing whitespaces from the string
dirvers="${dirvers%"${dirvers##*[![:space:]]}"}"
# dirvers=`ls *.bc`
# dirvers="echo ls pwd who whoami"

# This line should be deleted when running complete experiment
dirvers="echo fold"
for dirv in ${dirvers}
do
  # get absolute driver.c path
  driver_name=`echo ${dirv%.*}`

  echo "     Running ==== > "${driver_name}

  KLEE_OUT_DIR=${KLEE_OUT_DIR_ALL}/${driver_name}"_klee_without_stdin_out_output"
  TIME_LOG_TXT=${KLEE_OUT_DIR}/"execute_time.txt"
  echo "KLEE_OUT_DIR is "${KLEE_OUT_DIR}
  echo "====  Replay Ktest ===="
  KTEST_LIST=${KLEE_OUT_DIR}"/*.ktest"
  KTEST_CHECK_EXIST=${KLEE_OUT_DIR}"/test000001.ktest"

  # output driver name into coverage trendency file
  echo "=== TestCase : "${driver_name} >> ${cover_trend_file}

  # check there is any input Ktest generated ?
  if [ -f ${KTEST_CHECK_EXIST} ];then
    echo "CHECK:  KTests have been generated !"    
  else
    echo "CHECK:  KTest not exists, continue !"

    # output end flag into coverage trendency file
    echo "=== End" >> ${cover_trend_file}

    # get execution time 
    read -d "_" execution_time < ${TIME_LOG_TXT}

    # output driver function coverage into txt file 
    dirv_result=${driver_name}" , 0, 0, "${execution_time}
    echo ${dirv_result} >> ${result_file}

    continue
  fi

  # get driver function belong to which file
  # /home/user/coreutils-test/coreutils-9.4-src/src/echo
  gcov_target_path=${GCOV_PATH}/${driver_name}
  if [ ${driver_name} == "base64" ];then
    gcda_target_path=${gcov_target_path}"-basenc.gcda"
    gcov_res_path=${SRC_PATH}/"basenc.c.gcov"
  elif [ ${driver_name} == "sum" ];then
    gcda_target_path=${gcov_target_path}"-sum.gcda"
    gcov_res_path=${SRC_PATH}/${driver_name}".c.gcov"
  else
    gcda_target_path=${gcov_target_path}  
    gcov_res_path=${SRC_PATH}/${driver_name}".c.gcov"
  fi

  #/home/user/coreutils-test/coreutils-9.4-src/echo.c.gcov
  
  
  cd ${SRC_PATH}
  for ktest in ${KTEST_LIST}
  do
    echo "KTest : "${ktest}
    # give a ktest file to activate replay tool
    ${KLEE_REPLAY_PATH} ${gcov_target_path} ${ktest} #gcov_target_path是目标程序的二进制文件路径

    touch temp.out

    gcov_res=`gcov ${gcda_target_path}`

    echo "======= "${gcov_res} > temp.out

    cover_res=$(python3 ${GET_GCOV_INFO_PY} ${gcov_res_path}) 

    rm temp.out
    
    # now_trend_info=${generate_time}", "${cover_res}
    echo ${cover_res} >> ${cover_trend_file}
  done

  # output end flag into coverage trendency file
  echo "=== End" >> ${cover_trend_file}
  # get final.gcov report
  touch temp.out
  gcov_res=`gcov ${gcda_target_path}`
  echo "======= "${gcov_res} > temp.out
  fin_cover_res=$(python3 ${GET_GCOV_INFO_PY} ${gcov_res_path})
  rm temp.out
  # get execution time 
  read -d "_" execute_time < ${TIME_LOG_TXT}
      
  # output driver function coverage and excution time into txt file 
  dirv_result=${driver_name}" , "${fin_cover_res}", "${execute_time}
  echo ${dirv_result} >> ${result_file}
 
  #fi
done
# generate gcovr report on whole coreutils in /home/user/coreutils-test/coreutils-9.4-bc/report
gcovr  -r . --gcov-ignore-errors=no_working_dir_found --html-details=main.html  --html-self-contained
cp *.html ${REPORT_PATH}
rm *.html