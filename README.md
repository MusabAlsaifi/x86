# x86
## General Info: 
void fadecircle(void *image, int width, int height, int xc, int yc, int radius, 
unsigned int color)
The program contains two source files: main program written in C and assembly module 
callable from C. Use NASM assembler (nasm.sf.net) to assemble the assembly module. 
Use C compiler driver to compile C module and link it with the output of assembler. 
The C program uses command line arguments to supply the parameters to an assembly 
routine and perform all I/O operations. No system functions nor C library functions 
are called from assembly code.

## Setup:
```
$ make
```
```
$ ./test test.bmp output.bmp
```
