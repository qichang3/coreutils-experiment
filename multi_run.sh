work_dic1="base64     df        mknod         tac"
work_dic2="cat        echo      mktemp        tail"
work_dic3="chgrp      expand    nl            tee"
work_dic4="chown      fmt       numfmt        tr"
work_dic5="cksum      fold      od            uname"
work_dic6="comm       head      pinky         unexpand"
work_dic7="cp         id        printf        uniq"
work_dic8="csplit     ls        sort          users"
work_dic9="cut        mkdir     split         wc"
work_dic10="date      mkfifo    sum           who"

agent_shell=run_klee_coreutils.sh

nohup ./${agent_shell} ${work_dic1} > nohup_sh1.txt 2>&1 &
nohup ./${agent_shell} ${work_dic2} > nohup_sh2.txt 2>&1 &
nohup ./${agent_shell} ${work_dic3} > nohup_sh3.txt 2>&1 &
nohup ./${agent_shell} ${work_dic4} > nohup_sh4.txt 2>&1 &
nohup ./${agent_shell} ${work_dic5} > nohup_sh5.txt 2>&1 &
nohup ./${agent_shell} ${work_dic6} > nohup_sh6.txt 2>&1 &
nohup ./${agent_shell} ${work_dic7} > nohup_sh7.txt 2>&1 &
nohup ./${agent_shell} ${work_dic8} > nohup_sh8.txt 2>&1 &
nohup ./${agent_shell} ${work_dic9} > nohup_sh9.txt 2>&1 &
nohup ./${agent_shell} ${work_dic10} > nohup_sh10.txt 2>&1 &