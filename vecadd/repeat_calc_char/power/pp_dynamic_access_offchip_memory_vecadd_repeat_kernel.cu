#include "pp_dynamic_access_offchip_memory_vecadd_repeat.h"

__global__ void AddVectors(const float* A, const float* B, float* C, int N)
{
  int blockStartIndex  = blockIdx.x * blockDim.x * N;
  int threadStartIndex = blockStartIndex + threadIdx.x;
  int threadEndIndex   = threadStartIndex + N*blockDim.x;
  int i,t;

  for (t = 0; t < REPS; t++) {
    for( i=threadStartIndex; i<threadEndIndex; i=i+blockDim.x ){
        C[i] = A[i] + B[i];
    }
  }
}
