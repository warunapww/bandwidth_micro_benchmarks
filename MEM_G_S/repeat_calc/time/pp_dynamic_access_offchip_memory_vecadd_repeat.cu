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
#include "pp_dynamic_access_offchip_memory_vecadd_repeat.h"

#include "high_resolution_power.h"

/**
 * This macro checks return value of the CUDA runtime call and exits
 * the application if the call failed.
 */
#define CUDA_CHECK_RETURN(value) {                    \
    cudaError_t _m_cudaStat = value;                    \
    if (_m_cudaStat != cudaSuccess) {                   \
      fprintf(stderr, "Error: %s at line %d in file %s\n",        \
          cudaGetErrorString(_m_cudaStat), __LINE__, __FILE__);   \
          exit(1);        \
    } }




// Variables for host and device vectors.
float* h_A; 
float* h_B; 
float* h_C; 
float* d_A; 
float* d_B; 
float* d_C; 

// Utility Functions
void Cleanup(bool);

void call_gpu_function() {
    dim3 dimGrid(GRID_WIDTH);                    
    dim3 dimBlock(BLOCK_WIDTH);                 
    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, VALUES_PER_THREAD);
}

// Host code performs setup and calls the kernel.
int main(int argc, char** argv)
{
    int N; //Vector size

	// Parse arguments.
/*    if(argc != 2){
     printf("Usage: %s VALUES_PER_THREAD\n", argv[0]);
     printf("VALUES_PER_THREAD is the number of values added by each thread.\n");
     printf("Total vector size is 128 * 60 * this value.\n");
     exit(0);
    } else {
      sscanf(argv[1], "%d", &VALUES_PER_THREAD);
    }      
*/
    // Determine the number of threads .
    // N is the total number of values to be in a vector
    N = VALUES_PER_THREAD * GRID_WIDTH * BLOCK_WIDTH;
    printf("Total vector size: %d\n", N); 
    // size_t is the total number of bytes for a vector.
    size_t size = N * sizeof(float);

    // Tell CUDA how big to make the grid and thread blocks.
    // Since this is a vector addition problem,
    // grid and thread block are both one-dimensional.

    // Allocate input vectors h_A and h_B in host memory
    h_A = (float*)malloc(size);
    if (h_A == 0) Cleanup(false);
    h_B = (float*)malloc(size);
    if (h_B == 0) Cleanup(false);
    h_C = (float*)malloc(size);
    if (h_C == 0) Cleanup(false);

    // Allocate vectors in device memory.
    cudaError_t error;
    CUDA_CHECK_RETURN(cudaMalloc((void**)&d_A, size));
    CUDA_CHECK_RETURN(cudaMalloc((void**)&d_B, size));
    CUDA_CHECK_RETURN(cudaMalloc((void**)&d_C, size));

    // Initialize host vectors h_A and h_B
    int i;
    for(i=0; i<N; ++i){
     h_A[i] = (float)i;
     h_B[i] = (float)(N-i);   
     h_C[i] = (float)0.0;
    }

    // Copy host vectors h_A and h_B to device vectores d_A and d_B
    CUDA_CHECK_RETURN(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice));
    CUDA_CHECK_RETURN(cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice));
	  CUDA_CHECK_RETURN(cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice));

    // Warm up
//    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, VALUES_PER_THREAD);
    call_gpu_function();
    CUDA_CHECK_RETURN(cudaGetLastError());
    CUDA_CHECK_RETURN(cudaThreadSynchronize());


    long long exec_time_nanoseconds = get_exec_time_in_nanoseconds(call_gpu_function); 
    
    //high_resolution_power_profile(call_gpu_function);


    double time = exec_time_nanoseconds/1e6; //in ms

    //high_resolution_power_profile(call_gpu_function);


	// Compute floating point operations per second.
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
    printf( "%d %d %d Time: %f (ms), GFlopsS: %f GBytesS: %f nytes: %f nBytesPerS: %f\n", GRID_WIDTH, BLOCK_WIDTH, VALUES_PER_THREAD,
             time, nGFlopsPerSec, nGBytesPerSec, nBytes, nBytesPerSec);
     
    // Copy result from device memory to host memory
    error = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess) Cleanup(false);

    // Verify & report result
    for (i = 0; i < N; ++i) {
        float val = h_C[i];
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
        CUDA_CHECK_RETURN(cudaFree(d_A));
    if (d_B)
        CUDA_CHECK_RETURN(cudaFree(d_B));
    if (d_C)
        CUDA_CHECK_RETURN(cudaFree(d_C));

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



