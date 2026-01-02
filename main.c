#include <stdio.h>

/* function defined in another translation unit */
void greet(void);

int main(void) {
  greet();
  __asm
	ld c, #0
	call 5
  __endasm;
  return 0;
}

