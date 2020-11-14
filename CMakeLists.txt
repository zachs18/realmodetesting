cmake_minimum_required(VERSION 3.16.3)
project(test1 C ASM)

set(SOURCES
	src/entry.s
	src/main.s
	src/disk.s
	src/kb.s
	src/draw.s
	src/menu.s
	src/progs/hex_color_prog.s
	src/progs/type_prog.s
	src/progs/print_keycode_prog.s
#	src/font.s
	${CMAKE_CURRENT_BINARY_DIR}/font.s
	src/make_font_s.py
	src/keymap.s
)

add_executable(test1.o ${SOURCES} link-obj.ld)
set_target_properties(test1.o PROPERTIES LINKER_LANGUAGE C)
target_link_options(test1.o PRIVATE -T${CMAKE_SOURCE_DIR}/link-obj.ld)

add_executable(test1 ${SOURCES} link.ld)
set_target_properties(test1 PROPERTIES LINKER_LANGUAGE C)
target_link_options(test1 PRIVATE -T${CMAKE_SOURCE_DIR}/link.ld)

set(OS BAREMETAL)

set(CMAKE_BUILD_TYPE DEBUG)

#set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} --build-id=none -T ${CMAKE_SOURCE_DIR}/link.ld")
#set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

#set(CMAKE_C_COMPILER /usr/bin/gcc-10)
#set(CMAKE_CXX_COMPILER /usr/bin/g++-10)

#set(CMAKE_CXX_FLAGS_DEBUG "-Wall --std=c++20 -O0 -ggdb -DYYDEBUG -fdiagnostics-color=always")
#set(CMAKE_C_FLAGS_DEBUG "-Wall --std=c++20 -O0 -ggdb -fdiagnostics-color=always ")
set(CMAKE_C_FLAGS_DEBUG "-m32 -g -static -nostdlib -nostartfiles -Wl,--build-id=none -Wa,--keep-locals")
set(CMAKE_ASM_FLAGS_DEBUG "-m32 -g -static -nostdlib -nostartfiles -Wl,--build-id=none -Wa,--keep-locals")

#set(CMAKE_CXX_FLAGS_RELEASE "-Wall --std=c++20 -O2")
#set(CMAKE_CXX_FLAGS_RELEASE "-Wall --std=c++20 -O2")

#include_directories(include)
#include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_custom_target(run
	COMMAND qemu-system-i386 -drive format=raw,file=test1
	DEPENDS test1
	WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

add_custom_target(rundebug
	COMMAND qemu-system-i386 -S -s -drive format=raw,file=test1
	DEPENDS test1
	WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

#add_custom_target(link.ld DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/link.ld)
#add_custom_target(link.ld DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/link.ld)

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/font.s
	COMMAND python3 src/make_font_s.py > ${CMAKE_CURRENT_BINARY_DIR}/font.s
	MAIN_DEPENDENCY src/make_font_s.py
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
