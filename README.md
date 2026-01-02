# Example: Using Small Device C Compiler to Create CP/M Programs

**Warning** This example assumes that CP/M runs on Z80 CPU.

This example demonstrates how to use the
[Small Device C Compiler (sdcc)](http://sdcc.sourceforge.net/) to
compile and link multiple source files into a CP/M executable.

## The Problems

I see the following problems when trying to create CP/M programs
using sdcc:

1. The sdcc can compile only one source file at a time.
2. The sdcc creates Intel Hex files, but CP/M needs a binary
   executable.
3. The sdcc provides startup code not compatible with CP/M.

### The Solutions

1. To bypass the one-file-at-a-time limitation, we can compile each
   source file separately into object file and then link all of them
   together.
2. To convert Intel Hex files to binary executables, we can use
   the `objcopy` utility from the LLVM project.
3. To provide CP/M-compatible startup code, we can write our own
   startup assembly file (`crt0.s`).

## The Usage

Clone the repository and run `make`. You should have `cmake` installed. The
resulting `main.com` will be produced in the root directory. You can run it,
for example, using the [YAZE-AG Emulator](https://agl.yaze-ag.de/).

You can remove both the `build` directory and the `main.com` file by running
`make clean`.
