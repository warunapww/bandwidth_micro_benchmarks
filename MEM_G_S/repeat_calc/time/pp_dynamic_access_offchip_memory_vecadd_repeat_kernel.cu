/*
This kernel does the vector addition and repeat the same addition for REP times.

The computations are repeated inorder to have a considerable execution time (few seconds).
The aim is to find the energy to transfer data between registers and shared memory

Egs - Energy to transfer an element between global memory and shared memory
Egr - Energy to transfer an element between global memory and registers
Esr - Energy to transfer an element between registers and shared memory

Egs = Egr + Esr

Dynanic energy = Egs*(#global-shared transfers) + Esr*(#shared-register transfers)

Known params:
  Egr from preveous experiment
  #global-shared transfers
  #shared-register transfers
  Dynanic energy - Energy for the program - static energy
Unknown params:
  Esr (Egs can be represented using Egr and Esr using the above equation)

*/
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
