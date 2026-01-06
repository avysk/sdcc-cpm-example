set(CRT0_REL ${CMAKE_CURRENT_BINARY_DIR}/crt0.rel)

find_program(SDASZ80_EXECUTABLE NAMES sdasz80)
if(NOT SDASZ80_EXECUTABLE)
  message(FATAL_ERROR "SDASZ80 assembler not found.")
endif()
message(STATUS "Found sdasz80: ${SDASZ80_EXECUTABLE}")

add_custom_command(
  OUTPUT ${CRT0_REL}
  COMMAND ${SDASZ80_EXECUTABLE} -g -l -o ${CRT0_REL}
          ${CMAKE_CURRENT_SOURCE_DIR}/crt0.s
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/crt0.s)

add_custom_target(crt0_asm DEPENDS ${CRT0_REL})

set(CRT0_REL
    ${CRT0_REL}
    PARENT_SCOPE)
