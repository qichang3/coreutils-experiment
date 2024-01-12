import json
import sys
import os
import math

argvs = sys.argv[1:]
gcov_path = argvs[0]
cov_path = argvs[1]
file_name = argvs[2]

gcov_covered_line = []
non_executable_line = []
klee_cov_line = []
divergence = False

with open(str(gcov_path),'r') as f:
  lines = f.readlines()
  analysis_flag = False
  
  target_line = 0 #可执行的行数

  #这里计算覆盖率是忽略那些注释行的
  #可能gcov原来统计覆盖率没有忽略注释，在这里返回重新计算的覆盖率covered_rate和gcov的数据算出来的被执行行数all_line_count
  for line in lines:
    if line.strip().startswith("-:"):
        lineNumber = line.split(':')[1].strip()
        temp = file_name + ":" + lineNumber
        non_executable_line.append(temp)  
    elif not line.strip().startswith("#####:"): #可执行且被覆盖的行
        lineNumber = line.split(':')[1].strip()
        temp = file_name + ":" + lineNumber
        gcov_covered_line.append(temp)


with open(str(cov_path),'r') as f_cov:
  lines = f_cov.readlines()
  for line in lines:
    temp = line.strip()
    if non_executable_line.count(temp) == 0:
      klee_cov_line.append(temp)


if not gcov_covered_line == klee_cov_line:
    divergence = True
print(divergence)