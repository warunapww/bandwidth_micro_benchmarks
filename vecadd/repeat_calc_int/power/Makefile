CC := nvcc
CUDA_CC	:=	$(COMPUTE_CAPABILITY)
OPTIONS := -O3 -Xptxas -v -arch=${CUDA_CC}
LIB := -L/s/chopin/e/proj/AlphaZ/waruna/lib -L/s/chopin/e/proj/AlphaZ/waruna/papi/installation/5.3.0/lib -lnvidia-ml -lpapi -lcublas
EXES := pp_dynamic_access_offchip_memory_int

OBJECTS	:=	high_resolution_power.o pp_dynamic_access_offchip_memory_int_vecadd_repeat_kernel.o

all: ${EXES}

#-------------------------------------------------------
pp_dynamic_access_offchip_memory_int: pp_dynamic_access_offchip_memory_int_vecadd_repeat.cu pp_dynamic_access_offchip_memory_int_vecadd_repeat_kernel.o pp_dynamic_access_offchip_memory_int_vecadd_repeat.h high_resolution_power.o
	 ${CC}  $< ${OBJECTS} ${LIB} ${OPTIONS} -o $@

high_resolution_power.o:	high_resolution_power.cu high_resolution_power.h
	$(CC) $< ${OPTIONS} -c -o $@

pp_dynamic_access_offchip_memory_int_vecadd_repeat_kernel.o:	pp_dynamic_access_offchip_memory_int_vecadd_repeat_kernel.cu pp_dynamic_access_offchip_memory_int_vecadd_repeat.h
	$(CC) $< ${OPTIONS} -c -o $@

#-------------------------------------------------------

clean: 
	rm -f *.o ${EXES}
