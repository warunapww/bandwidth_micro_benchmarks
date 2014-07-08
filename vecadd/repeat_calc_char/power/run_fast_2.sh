#!/bin/bash

set -o nounset
#set -o errexit

export NVML_REPS=30
export NVML_SLEEP_TIME=25

CONFIG_FILE=configs.info

FILE_NAME="pp_dynamic_access_offchip_memory_vecadd_repeat.h"

EXE_NAME=pp_dynamic_access_offchip_memory
LOG_PREFIX=pp_dynamic_access_offchip_memory_vecadd_repeat_

LOG=${LOG_PREFIX}.run.log

echo "=================================================================================================================" >> $LOG


while read TB TPB X TIME REPS
do
#    name=$line
    echo "Text read from file - ${TB} : ${TPB} : ${REPS} : ${X}"
    LOG_PREFIXX=$LOG_PREFIX.${TB}.${TPB}.${REPS}.${X}

    cp $FILE_NAME.P $FILE_NAME
    
    sed -i "s/__REPS__/${REPS}/g" $FILE_NAME
    sed -i "s/__GridWidth__/${TB}/g" $FILE_NAME
    sed -i "s/__BlockWidth__/${TPB}/g" $FILE_NAME

    echo "4"
    make clean
    echo "building"
    make  &> $LOG_PREFIXX.compile.log
    echo "build done"

    ${EXE_NAME} ${X} &> $LOG_PREFIXX.exec.log
    
done < ${CONFIG_FILE}


