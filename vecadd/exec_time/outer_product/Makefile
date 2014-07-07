CC := nvcc
CUDA_CC :=  $(COMPUTE_CAPABILITY)
OPTIONS := -O3 --maxrregcount=124 -Xptxas -v -arch=${CUDA_CC}
LIB := -L/s/chopin/e/proj/AlphaZ/waruna/lib -L/s/chopin/e/proj/AlphaZ/waruna/papi/installation/5.3.0/lib -lnvidia-ml -lpapi -lcublas
EXES := pp_dynamic_access_offchip_memory

OBJECTS :=  high_resolution_power.o pp_dynamic_access_offchip_memory_vecadd_kernel.o

all: ${EXES}

EXECS :=  vecmultCodeGen vecmult00
all:$(EXECS)

vecmultCodeGen : vecmultCodeGen.c
	gcc -o $@ $<

vecmultMaxAddCodeGen : vecmultMaxAddCodeGen.c
	gcc -o $@ $<
#######################################################################
vecmultKernel00.o : vecmultKernel00.cu
	nvcc $< -c -o $@ $(OPTIONS)
#	nvcc $< -c -o $@ $(OPTIONS) -arch=sm_13
#	nvcc $< -c -o $@ $(OPTIONS) -ext=all -dir=a.out.devcode

vecmult00 : vecmult.cu vecmultKernel.h vecmultKernel00.o
	nvcc $< vecmultKernel00.o -o $@ $(LIB) $(INCLUDES) $(OPTIONS)
#nvcc $< vecmultKernel00.o -o $@ $(LIB) $(INCLUDES) $(OPTIONS) -arch=sm_13

clean : 
	rm *.o $(EXECS)

version : 
	nvcc --version

ptxx	:	vecmultKernel00.cu
	nvcc -ptx $<
