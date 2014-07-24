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
#include "pp_dynamic_mem_glob_to_shared_repeat.h"

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
float* d_A; 
float* d_B; 
int ValuesPerThread; // number of values per thread
int N; //Vector size

// Utility Functions
void Cleanup(bool);
void checkCUDAError(const char *msg);

void call_gpu_function() {
    dim3 dimGrid(GRID_WIDTH);                    
    dim3 dimBlock(BLOCK_WIDTH);                 
    reverse_in_chunks<<<dimGrid, dimBlock>>>(d_A, d_B, ValuesPerThread, N);
}

// Host code performs setup and calls the kernel.
int main(int argc, char** argv)
{

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
    N = ValuesPerThread * GRID_WIDTH * BLOCK_WIDTH;
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

    // Allocate vectors in device memory.
    cudaError_t error;
    CUDA_CHECK_RETURN(cudaMalloc((void**)&d_A, size));
    CUDA_CHECK_RETURN(cudaMalloc((void**)&d_B, size));

    // Initialize host vectors h_A and h_B
    int i;
    for(i=0; i<N; ++i){
     h_A[i] = (float)i;
    }

    // Copy host vectors h_A and h_B to device vectores d_A and d_B
    CUDA_CHECK_RETURN(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice));

    // Warm up
//    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ValuesPerThread);
    call_gpu_function();
    CUDA_CHECK_RETURN(cudaGetLastError());
    CUDA_CHECK_RETURN(cudaThreadSynchronize());


    // Invoke kernel
//    AddVectors<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ValuesPerThread);
    call_gpu_function();
    CUDA_CHECK_RETURN(cudaGetLastError());

	// Compute elapsed time 
    CUDA_CHECK_RETURN(cudaThreadSynchronize());

    long long exec_time_nanoseconds = get_exec_time_in_nanoseconds(call_gpu_function); 
    
    //high_resolution_power_profile(call_gpu_function);


    double time = exec_time_nanoseconds/1e6; //in ms

	// Compute floating point operations per second.
/*    double nFlops = (double)N*(double)REPS ;
    double nFlopsPerSec = 1e3*nFlops/time;
    double nGFlopsPerSec = nFlopsPerSec*1e-9;
    //double nGFlopsPerSec = (1e3*N/(exec_time_nanoseconds/1e9))*1e-9;
    //double nGFlopsPerSec = 1e3*N/exec_time_nanoseconds;
*/
	// Compute transfer rates.
    double nBytes =2*4*(double)N*(double)REPS; // N words in, N word out
    double nBytesPerSec = 1e3*nBytes/time;
    double nGBytesPerSec = nBytesPerSec*1e-9;
    //double nGBytesPerSec = (1e3*nBytes/(exec_time_nanoseconds/1e9))*1e-9;
    //double nGBytesPerSec = 1e3*nBytes/exec_time_nanoseconds;

	// Report timing data.
    printf( "GRID_WIDTH: %d BLOCK_WIDTH: %d ValuesPerThread: %d REPS: %d Time: %f (ms), GBytesS: %f\n", GRID_WIDTH, BLOCK_WIDTH, ValuesPerThread, REPS,
             time, nGBytesPerSec);
     
    // Copy result from device memory to host memory
    error = cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess) Cleanup(false);

    // Verify & report result
   /* //for (t = 0; t < REPS; t++) {
      for (j = 0; j < times; j++) {
        int threadStartIndex = blockStartIndex + 12288*j;
        int threadEndIndex   = threadStartIndex + 12288;
        for( i=threadStartIndex; i<threadEndIndex; i=i+BLOCK_WIDTH){
          int k = i+tId;
          //sharedA[tId] = A[k];
          sharedA[k-threadStartIndex] = A[k];
        }
        __syncthreads();

        for( i=threadStartIndex; i<threadEndIndex; i=i+BLOCK_WIDTH){
          int k = i+tId;
          B[L-k-12288] = sharedA[k-threadStartIndex];
        }

      
      }
    //}

    for (i = 0; i < N; ++i) {
        float val = h_A[i];
        if (fabs(val - h_B[N-(i/12288)*12288 + i%12288]) > 1e-5)
            break;
    }
    printf("Test %s \n", (i == N) ? "PASSED" : "FAILED");
*/
	// Clean up and exit.
    Cleanup(true);
}

void Cleanup(bool noError) {  // simplified version from CUDA SDK
    cudaError_t error;
        
    // Free device vectors
    if (d_A) {
        CUDA_CHECK_RETURN(cudaFree(d_A));
    }
    if (d_B) {
        CUDA_CHECK_RETURN(cudaFree(d_B));
    }

    // Free host memory
    if (h_A)
        free(h_A);
    if (h_B)
        free(h_B);
        
    error = cudaThreadExit();
    
    if (!noError || error != cudaSuccess)
        printf("cuda malloc or cuda thread exit failed \n");
    
    fflush( stdout);
    fflush( stderr);

    exit(0);
}



