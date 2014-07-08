///
/// vecadd.cu
/// For CSU CS575 Spring 2011
/// Instructor: Wim Bohm
/// Based on code from the CUDA Programming Guide
/// Modified by Wim Bohm and David Newman
/// Created: 2011-02-03
/// Last Modified: 2011-03-03 DVN
///
/// Add two Vectors A and B in C on GPU using
/// a kernel defined according to vecAddKernel.h
/// Students must not modify this file. The GTA
/// will grade your submission using an unmodified
/// copy of this file.
/// 

// Includes
#include <stdio.h>
#include "pp_dynamic_access_offchip_memory_int_vecadd_repeat.h"

#include "high_resolution_power.h"


// Variables for host and device vectors.
int* h_A; 
int* h_B; 
int* h_C; 
int* d_A; 
int* d_B; 
int* d_C; 
int ValuesPerThread; // number of values per thread

// Utility Functions
void Cleanup(bool);
void checkCUDAError(const char *msg);

void call_gpu_function() {
    dim3 dimGrid(GridWidth);                    
    dim3 dimBlock(BlockWidth);                 
    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ValuesPerThread);
}

// Host code performs setup and calls the kernel.
int main(int argc, char** argv)
{
    int N; //Vector size

	// Parse arguments.
    if(argc != 2){
     printf("Usage: %s ValuesPerThread\n", argv[0]);
     printf("ValuesPerThread is the number of values added by each thread.\n");
     printf("Total vector size is 128 * 60 * this value.\n");
     exit(0);
    } else {
      sscanf(argv[1], "%d", &ValuesPerThread);
    }      

    // Determine the number of threads .
    // N is the total number of values to be in a vector
    N = ValuesPerThread * GridWidth * BlockWidth;
    printf("Total vector size: %d\n", N); 
    // size_t is the total number of bytes for a vector.
    size_t size = N * sizeof(int);

    // Tell CUDA how big to make the grid and thread blocks.
    // Since this is a vector addition problem,
    // grid and thread block are both one-dimensional.

    // Allocate input vectors h_A and h_B in host memory
    h_A = (int*)malloc(size);
    if (h_A == 0) Cleanup(false);
    h_B = (int*)malloc(size);
    if (h_B == 0) Cleanup(false);
    h_C = (int*)malloc(size);
    if (h_C == 0) Cleanup(false);

    // Allocate vectors in device memory.
    cudaError_t error;
    error = cudaMalloc((void**)&d_A, size);
    if (error != cudaSuccess) Cleanup(false);
    error = cudaMalloc((void**)&d_B, size);
    if (error != cudaSuccess) Cleanup(false);
    error = cudaMalloc((void**)&d_C, size);
    if (error != cudaSuccess) Cleanup(false);

    // Initialize host vectors h_A and h_B
    int i;
    for(i=0; i<N; ++i){
     h_A[i] = (int)i;
     h_B[i] = (int)(N-i);   
	 h_C[i] = (int)0.0;
    }

    // Copy host vectors h_A and h_B to device vectores d_A and d_B
    error = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    if (error != cudaSuccess) Cleanup(false);
    error = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
	if (error != cudaSuccess) Cleanup(false);
	error = cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);
    if (error != cudaSuccess) Cleanup(false);

    // Warm up
//    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ValuesPerThread);
    call_gpu_function();
    error = cudaGetLastError();
    if (error != cudaSuccess) Cleanup(false);
    cudaThreadSynchronize();


    // Invoke kernel
//    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ValuesPerThread);
    call_gpu_function();
    error = cudaGetLastError();
    if (error != cudaSuccess) Cleanup(false);

	// Compute elapsed time 
    cudaThreadSynchronize();

    long long exec_time_nanoseconds = get_exec_time_in_nanoseconds(call_gpu_function); 
    
    //high_resolution_power_profile(call_gpu_function);


    double time = exec_time_nanoseconds/1e6; //in ms

    //high_resolution_power_profile(call_gpu_function);


	// Compute inting point operations per second.
    double nFlops = (double)N*(double)REPS ;
    double nFlopsPerSec = 1e3*nFlops/time;
    double nGFlopsPerSec = nFlopsPerSec*1e-9;
    //double nGFlopsPerSec = (1e3*N/(exec_time_nanoseconds/1e9))*1e-9;
    //double nGFlopsPerSec = 1e3*N/exec_time_nanoseconds;

	// Compute transfer rates.
    double nBytes = 3*4*(double)N*(double)REPS; // 2N words in, 1N word out
    double nBytesPerSec = 1e3*nBytes/time;
    double nGBytesPerSec = nBytesPerSec*1e-9;
    //double nGBytesPerSec = (1e3*nBytes/(exec_time_nanoseconds/1e9))*1e-9;
    //double nGBytesPerSec = 1e3*nBytes/exec_time_nanoseconds;

	// Report timing data.
    printf( "%d %d %d Time: %f (ms), GOPS: %f GBytesS: %f nytes: %f nBytesPerS: %f\n", GridWidth, BlockWidth, ValuesPerThread,
             time, nGFlopsPerSec, nGBytesPerSec, nBytes, nBytesPerSec);
     
    // Copy result from device memory to host memory
    error = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess) Cleanup(false);

    // Verify & report result
    for (i = 0; i < N; ++i) {
        int val = h_C[i];
        if (fabs(val - N) > 1e-5)
            break;
    }
    printf("Test %s \n", (i == N) ? "PASSED" : "FAILED");

	// Clean up and exit.
    Cleanup(true);
}

void Cleanup(bool noError) {  // simplified version from CUDA SDK
    cudaError_t error;
        
    // Free device vectors
    if (d_A)
        cudaFree(d_A);
    if (d_B)
        cudaFree(d_B);
    if (d_C)
        cudaFree(d_C);

    // Free host memory
    if (h_A)
        free(h_A);
    if (h_B)
        free(h_B);
    if (h_C)
        free(h_C);
        
    error = cudaThreadExit();
    
    if (!noError || error != cudaSuccess)
        printf("cuda malloc or cuda thread exit failed \n");
    
    fflush( stdout);
    fflush( stderr);

    exit(0);
}

void checkCUDAError(const char *msg)
{
  cudaError_t err = cudaGetLastError();
  if( cudaSuccess != err) 
    {
      fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString(err) );
      exit(-1);
    }                         
}


