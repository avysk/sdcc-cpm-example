#include <stdio.h>

#include "../support/cpmfile.h"

/* function defined in another translation unit */
void greet(void);

int main(void) {

  f_close(0);
  f_delete(0);
  f_make(0);

  f_close(1);
  f_delete(1);
  f_make(1);

  greet();
  return 0;
}
