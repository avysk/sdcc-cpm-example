set(SOURCES main.c greet.c)

set(REL_FILES "")
foreach(SOURCE ${SOURCES})
  get_filename_component(BASENAME ${SOURCE} NAME_WE)
  set(REL_FILE ${CMAKE_CURRENT_BINARY_DIR}/${BASENAME}.rel)

  add_custom_command(
    OUTPUT ${REL_FILE}
    COMMAND ${SDCC_EXECUTABLE} ${CMAKE_C_FLAGS} -c
            ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE} -o ${REL_FILE}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE})

  list(APPEND REL_FILES ${REL_FILE})
endforeach()

add_custom_target(src_objects DEPENDS ${REL_FILES})

set(SRC_REL_FILES
    ${REL_FILES}
    PARENT_SCOPE)
