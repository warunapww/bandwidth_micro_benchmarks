#include "pp_dynamic_access_offchip_memory_vecadd_repeat.h"

__global__ void AddVectors(const float* A, const float* B, float* C, int N)
{
  int blockStartIndex  = blockIdx.x * BLOCK_WIDTH * VALUES_PER_THREAD;
  int threadStartIndex = blockStartIndex;
  //int threadStartIndex = blockStartIndex + threadIdx.x;
  int threadEndIndex   = threadStartIndex + VALUES_PER_THREAD*BLOCK_WIDTH;
  //int threadEndIndex   = threadStartIndex + VALUES_PER_THREAD*blockDim.x;
  int i,t,s;
 
  __shared__ float shared_C[SHARED_ARRAY_SIZE]; 

  for (t = 0; t < REPS; t++) {
    //BLOCK_WIDTH*VALUES_PER_THREAD should be divicible by SHARED_ARRAY_SIZE
    for (s = threadStartIndex; s < threadEndIndex; s=s+SHARED_ARRAY_SIZE) {
      //SHARED_ARRAY_SIZE should be divicible by BLOCK_WIDTH
      //for( i=s ; i<s+SHARED_ARRAY_SIZE; i=i+BLOCK_WIDTH ){
      for( i=s+threadIdx.x ; i<s+SHARED_ARRAY_SIZE; i=i+BLOCK_WIDTH ){
          shared_C[i-s] = A[i] + B[i];
      }
      __syncthreads();

      for( i=s+threadIdx.x ; i<s+SHARED_ARRAY_SIZE; i=i+BLOCK_WIDTH ){
          C[i] = shared_C[i-s];
      }
    }
  }
}
