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


while read TB TPB X SHARED_MEM_ARRAY_SIZE REPS
do
#    name=$line
    echo "Text read from file - ${TB} : ${TPB} : ${REPS} : ${X} : ${SHARED_MEM_ARRAY_SIZE}"
    LOG_PREFIXX=$LOG_PREFIX.${TB}.${TPB}.${REPS}.${X}.${SHARED_MEM_ARRAY_SIZE}

    cp $FILE_NAME.P $FILE_NAME
    
    sed -i "s/__REPS__/${REPS}/g" $FILE_NAME
    sed -i "s/__GRID_WIDTH__/${TB}/g" $FILE_NAME
    sed -i "s/__BLOCK_WIDTH__/${TPB}/g" $FILE_NAME
    sed -i "s/__VALUES_PER_THREAD__/${X}/g" $FILE_NAME
    sed -i "s/__SHARED_ARRAY_SIZE__/${SHARED_MEM_ARRAY_SIZE}/g" $FILE_NAME

    echo "4"
    make clean
    echo "building"
    make  &> $LOG_PREFIXX.compile.log
    echo "build done"

    ${EXE_NAME} &> $LOG_PREFIXX.exec.log
    
done < ${CONFIG_FILE}


