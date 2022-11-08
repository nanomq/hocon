cmake_minimum_required(VERSION 3.21)

project(Hocon VERSION 1.0 LANGUAGES C)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED)
find_package(BISON 3.0 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/scanner.c")
set(PARSER_OUT "${PARSER_DIR}/parser.c")

flex_target(LEXER "scanner.l" "${LEXER_OUT}" DEFINES_FILE "${PARSER_DIR}/scanner.h")
bison_target(PARSER "parser.y" "${PARSER_OUT}" DEFINES_FILE "${PARSER_DIR}/parser.h")
add_flex_bison_dependency(LEXER PARSER)

add_library(hocon SHARED "${LEXER_OUT}" "${PARSER_OUT}" "cJSON.c" "hocon.c")

target_include_directories(hocon PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(hocon PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

add_executable(test ${CMAKE_CURRENT_SOURCE_DIR}/main.c hocon)
target_include_directories(test PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(test PRIVATE hocon)