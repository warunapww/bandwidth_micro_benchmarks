
#ifndef __pp_dynamic_access_offchip_memory_int_vecadd_h__
#define __pp_dynamic_access_offchip_memory_int_vecadd_h__

// Defines
#define GridWidth 208
#define BlockWidth 1024

#define REPS 1000

__global__ void AddVectors(const float* A, const float* B, float* C, int N);


#endif //__pp_dynamic_access_offchip_memory_int_vecadd_h__
