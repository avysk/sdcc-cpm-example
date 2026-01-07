#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "../support/cpmfile.h"

/* function defined in another translation unit */
void greet(void);

int main(void) {

  char data[128] = {0};

  char *msg = "Hello, CP/M World!\r\n";
  for (size_t i = 0; i < strlen(msg); i++) {
    data[i] = msg[i];
  }

  f_close(0);
  f_delete(0);
  f_make(0);
  f_open(0);
  int res = f_write(0, data);
  assert(res == 0);
  data[0] = 'h';
  res = f_write(0, data);
  assert(res == 0);
  f_close(0);

  f_close(1);
  f_delete(1);
  f_make(1);
  f_open(1);
  res = f_write(1, data);
  assert(res == 0);
  f_close(1);

  puts("Reading files back:\n\r");
  puts("------------------\n\r");
  f_open(0);
  char (*read_data)[128] = f_read(0);
  printf("%s", (char *)read_data);
  read_data = f_read(0);
  printf("%s", (char *)read_data);
  f_close(0);
  puts("------------------\n\r");
  f_open(1);
  read_data = f_read(1);
  printf("%s", (char *)read_data);
  f_close(1);
  puts("------------------\n\r");

  greet();
  return 0;
}
