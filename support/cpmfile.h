#pragma once

#include <stdint.h>

uint8_t f_open(uint8_t file_number);
uint8_t f_close(uint8_t file_number);
uint8_t f_delete(uint8_t file_number);
uint8_t f_make(uint8_t file_number);
