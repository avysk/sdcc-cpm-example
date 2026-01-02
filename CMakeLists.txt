cmake_minimum_required(VERSION 3.20)
project(CpmExample C ASM)

find_program(SDCC_EXECUTABLE NAMES sdcc)
if(NOT SDCC_EXECUTABLE)
  message(FATAL_ERROR "SDCC compiler not found.")
endif()
find_program(SDASZ80_EXECUTABLE NAMES sdasz80)
if(NOT SDASZ80_EXECUTABLE)
  message(FATAL_ERROR "SDASZ80 assembler not found.")
endif()
find_program(OBJCOPY_EXECUTABLE NAMES objcopy)
if(NOT OBJCOPY_EXECUTABLE)
  message(FATAL_ERROR "objcopy not found.")
endif()

message(STATUS "Found sdcc: ${SDCC_EXECUTABLE}")
message(STATUS "Found sdasz80: ${SDASZ80_EXECUTABLE}")
message(STATUS "Found objcopy: ${OBJCOPY_EXECUTABLE}")

set(CMAKE_C_FLAGS -mz80 --std-c23)

add_subdirectory(support)
add_subdirectory(src)

add_custom_command(
  OUTPUT main.ihx
  COMMAND ${SDCC_EXECUTABLE} ${CMAKE_C_FLAGS} --no-std-crt0 ${CRT0_REL}
          ${SRC_REL_FILES} -o main.ihx
  DEPENDS crt0_asm src_objects)
add_custom_command(
  DEPENDS main.ihx
  OUTPUT main.com
  COMMAND ${OBJCOPY_EXECUTABLE} -I ihex -O binary main.ihx main.com)

add_custom_target(main ALL DEPENDS main.com)
