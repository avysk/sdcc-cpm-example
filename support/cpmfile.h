#pragma once

#include <stdint.h>

uint8_t f_open(uint8_t file_number);
uint8_t f_close(uint8_t file_number);

// Not harmful to delete a non-existing file
uint8_t f_delete(uint8_t file_number);
uint8_t f_make(uint8_t file_number);

// CP/M reads/writes 128-byte records
char (*f_read(uint8_t file_number))[128];
uint8_t f_write(uint8_t file_number, const char record[static 128]);
// Always make sure that the file exists before writing to it!
// Always close the file after writing is done!
