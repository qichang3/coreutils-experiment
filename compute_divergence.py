import json
import sys
import os
import math
import re

argvs = sys.argv[1:]
gcov_path = argvs[0]
cov_path = argvs[1]
file_name = argvs[2]

gcov_covered_line = []
non_executable_line = []
klee_cov_line = []
divergence = False

# special handle for goto
goto_pattern = r'goto (\w+);';

with open(str(gcov_path),'r') as f:
  lines = f.readlines()
  analysis_flag = False
  
  goto_flag = False
  goto_label = [] #maybe more than one goto label

  
  for line in lines:
    if line.strip().startswith("-:"):
        temp = line.split(':')[1].strip()
        #non_executable_line contains all the non-executable lines
        non_executable_line.append(temp)  
    elif not line.strip().startswith("#####:"): #可执行且被覆盖的行
        match = re.search(goto_pattern, line)
        if match:
            goto_flag = True
            goto_label.append(match.group(1))
        temp = line.split(':')[1].strip()
        #special handle for echo defualt statement
        if temp == "166":
          non_executable_line.append(temp)
        else:
          gcov_covered_line.append(temp)
    else: #可执行但未被覆盖的行, 对goto需要特殊处理
        temp = line.split(':')[2].strip()
        line_num = line.split(':')[1].strip()
        if(goto_flag and temp in goto_label):
            gcov_covered_line.append(line_num)
    # compute not coverd line in total


with open(str(cov_path),'r') as f_cov:
  lines = f_cov.readlines()
  for line in lines:
    temp = line.strip()
    #temp is related to filename
    if file_name in temp:
      temp =  temp.split(':')[1].strip()
      # temp is not in non_executable_line
      if non_executable_line.count(temp) == 0:
        klee_cov_line.append(temp)

print(klee_cov_line)
print(gcov_covered_line)
if not gcov_covered_line == klee_cov_line:
    divergence = True
print(divergence)