#
# CMake include file for Playdate libraries
#

cmake_minimum_required(VERSION 3.19)

set(CMAKE_VERBOSE_MAKEFILE TRUE)

include_directories("${SDK}/C_API")
message(STATUS "SDK Path: " ${SDK})

set(PDC "${SDK}/bin/pdc" -sdkpath "${SDK}")

add_compile_definitions(TARGET_EXTENSION=1)

if (TOOLCHAIN STREQUAL "armgcc")
	# Device-only

	# Glue code
	target_sources(${PLAYDATE_GAME_DEVICE} PRIVATE ${SDK}/C_API/buildsupport/setup.c)

	set(HEAP_SIZE 8388208)
	set(STACK_SIZE 61800)
	set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -x assembler-with-cpp -D__HEAP_SIZE=${HEAP_SIZE} -D__STACK_SIZE=${STACK_SIZE}")

	set(MCFLAGS -mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1)

	target_compile_definitions(${PLAYDATE_GAME_DEVICE} PUBLIC TARGET_PLAYDATE=1)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -Wall -Wno-unknown-pragmas -Wdouble-promotion)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC $<$<CONFIG:DEBUG>:-O2>)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC $<$<CONFIG:RELEASE>:-O2>)

	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC ${MCFLAGS})
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -falign-functions=16 -fomit-frame-pointer)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -gdwarf-2)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -fverbose-asm)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -ffunction-sections -fdata-sections)
	target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC -mword-relocations -fno-common)

    target_compile_options(${PLAYDATE_GAME_DEVICE} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)

	target_link_options(${PLAYDATE_GAME_DEVICE} PUBLIC -nostartfiles)
	target_link_options(${PLAYDATE_GAME_DEVICE} PUBLIC ${MCFLAGS})
	target_link_options(${PLAYDATE_GAME_DEVICE} PUBLIC -T${SDK}/C_API/buildsupport/link_map.ld)
	target_link_options(${PLAYDATE_GAME_DEVICE} PUBLIC "-Wl,-Map=game.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs")
	target_link_options(${PLAYDATE_GAME_DEVICE} PUBLIC --entry eventHandlerShim)

else ()
	# Simulator-only
	target_compile_definitions(${PLAYDATE_GAME_NAME} PUBLIC TARGET_SIMULATOR=1)
	if (MSVC)
		target_compile_definitions(${PLAYDATE_GAME_NAME} PUBLIC _WINDLL=1)
		target_compile_options(${PLAYDATE_GAME_NAME} PUBLIC /W3)
		target_compile_options(${PLAYDATE_GAME_NAME} PUBLIC $<$<CONFIG:DEBUG>:/Od>)
	else()
		target_compile_options(${PLAYDATE_GAME_NAME} PUBLIC -Wall -Wstrict-prototypes -Wno-unknown-pragmas -Wdouble-promotion)
		target_compile_options(${PLAYDATE_GAME_NAME} PUBLIC $<$<CONFIG:DEBUG>:-ggdb -O0>)
	endif()

endif ()
