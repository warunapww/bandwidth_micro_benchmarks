#!/bin/bash



TW_STEP_SCALE=16
BLOCK_STEP_SCALE=16

T_STEP_SCALE=2


FILE_NAME="pp_dynamic_access_offchip_memory_vecadd.h"

EXE_NAME=pp_dynamic_access_offchip_memory

COUNT=0


LOG=run.log
LOG_PREFIX=pp_dynamic_access_offchip_memory_vecadd_


echo "=================================================================================================================" >> $LOG
#192 560 1664

#for ((ts=16; ts<=256; ts=ts+$TW_STEP_SCALE))
for ((ts=192; ts<=256; ts=ts+$TW_STEP_SCALE))
do 
	for ((bs=16; bs<=1024; bs=bs+$BLOCK_STEP_SCALE))
	do 
      LOG_PREFIXX=$LOG_PREFIX.$ts.$bs
      rm $FILE_NAME
      cp $FILE_NAME.P $FILE_NAME

      sed -i "s/__GridWidth__/$ts/g" $FILE_NAME
      sed -i "s/__BlockWidth__/$bs/g" $FILE_NAME

      make clean
      echo "building"

      make all &> $LOG_PREFIXX.compile.log
      echo "build done"

      ((input_start=4*1024*1024*1024/($ts*$bs*4*3*8)))
      echo "input start:  ${input_start}"

			for ((tt=input_start; tt<=input_start*8; tt=tt*$T_STEP_SCALE))
			do 
				echo "$ts $bs $tt" >> $LOG
				echo "$ts $bs $tt" 

        LOG_PREFIXX=$LOG_PREFIX.$ts.$bs.$tt
    
				${EXE_NAME} $tt &> $LOG_PREFIXX.exec.log
				echo "exe done"
   
			done 
	done
done

TW_STEP_SCALE=13

for ((ts=13; ts<=260; ts=ts+$TW_STEP_SCALE))
do 
	for ((bs=16; bs<=1024; bs=bs+$BLOCK_STEP_SCALE))
	do 
      LOG_PREFIXX=$LOG_PREFIX.$ts.$bs
      rm $FILE_NAME
      cp $FILE_NAME.P $FILE_NAME
      
      sed -i "s/__GridWidth__/$ts/g" $FILE_NAME
      sed -i "s/__BlockWidth__/$bs/g" $FILE_NAME
      
      make clean
      echo "building"
      make all &> $LOG_PREFIXX.compile.log
      echo "build done"

      ((input_start=4*1024*1024*1024/($ts*$bs*4*3*8)))
      echo "input start:  ${input_start}"

			for ((tt=input_start; tt<=input_start*8; tt=tt*$T_STEP_SCALE))
			do 
				echo "$ts $bs $tt" >> $LOG
				echo "$ts $bs $tt" 

        LOG_PREFIXX=$LOG_PREFIX.$ts.$bs.$tt
    
				${EXE_NAME} $tt &> $LOG_PREFIXX.exec.log
				echo "exe done"
   
			done 
	done
done


