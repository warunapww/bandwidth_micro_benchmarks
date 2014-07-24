
#ifndef __pp_dynamic_access_offchip_memory_int_vecadd_h__
#define __pp_dynamic_access_offchip_memory_int_vecadd_h__

// Defines
#define GridWidth 208
#define BlockWidth 928

#define REPS 185

__global__ void AddVectors(const int* A, const int* B, int* C, int N);


#endif //__pp_dynamic_access_offchip_memory_int_vecadd_h__
