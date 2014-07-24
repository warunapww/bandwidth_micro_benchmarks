#include "pp_dynamic_mem_glob_to_shared_repeat.h"

__global__ void reverse_in_chunks(const float* A, float* B, int N, int L)
{
  int blockStartIndex  = blockIdx.x * BLOCK_WIDTH * N;
  int i,j,t;

  int tId = threadIdx.x; 
  int times = BLOCK_WIDTH*N/SHARED_ARRAY_SIZE;


  __shared__ float sharedA[SHARED_ARRAY_SIZE];
  //__shared__ float sharedA[SHARED_ARRAY_SIZE_WO_BANK_CONFLICTS];


  for (t = 0; t < REPS; t++) {
    for (j = 0; j < times; j++) {
      int threadStartIndex = blockStartIndex + SHARED_ARRAY_SIZE*j;
      int threadEndIndex   = threadStartIndex + SHARED_ARRAY_SIZE;
      for( i=threadStartIndex; i<threadEndIndex; i=i+BLOCK_WIDTH){
          int k = i+tId;
          int shared_k = k-threadStartIndex;
          //int shared_k = k-threadStartIndex + ((k-threadStartIndex)>>5);
          //sharedA[tId] = A[k];
          sharedA[shared_k] = A[k];
      }
      __syncthreads();

      for( i=threadStartIndex; i<threadEndIndex; i=i+BLOCK_WIDTH){
          int k = i+tId;
          int shared_k = k-threadStartIndex;
          //int shared_k = k-threadStartIndex + ((k-threadStartIndex)>>5);
          B[L-k-SHARED_ARRAY_SIZE] = sharedA[shared_k];
      }

      
    }
  }
}
