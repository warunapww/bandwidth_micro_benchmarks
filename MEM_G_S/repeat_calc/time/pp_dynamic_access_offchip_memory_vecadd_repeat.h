
#ifndef __pp_dynamic_access_offchip_memory_vecadd_h__
#define __pp_dynamic_access_offchip_memory_vecadd_h__

// Defines
#define GRID_WIDTH 260
#define BLOCK_WIDTH 1024

#define REPS 362
#define VALUES_PER_THREAD 168
#define SHARED_ARRAY_SIZE 12288

__global__ void AddVectors(const float* A, const float* B, float* C, int N);


#endif //__pp_dynamic_access_offchip_memory_vecadd_h__
