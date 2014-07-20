
#ifndef __pp_dynamic_mem_glob_to_shared_h__
#define __pp_dynamic_mem_glob_to_shared_h__

// Defines
#define GRID_WIDTH 208
#define BLOCK_WIDTH 1024

#define REPS 200
#define SHARED_ARRAY_SIZE 11264
#define SHARED_ARRAY_SIZE_WO_BANK_CONFLICTS SHARED_ARRAY_SIZE+(SHARED_ARRAY_SIZE>>5)

__global__ void reverse_in_chunks(const float* A, float* B, int N, int L);


#endif //__pp_dynamic_mem_glob_to_shared_h__
