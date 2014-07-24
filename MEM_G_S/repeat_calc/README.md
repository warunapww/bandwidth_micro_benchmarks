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

