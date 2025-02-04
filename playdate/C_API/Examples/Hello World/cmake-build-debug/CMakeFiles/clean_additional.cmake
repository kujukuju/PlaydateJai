# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "C:\\Program Files\\PlaydateSDK\\C_API\\Examples\\Hello World\\Source\\pdex.elf"
  "C:\\Program Files\\PlaydateSDK\\C_API\\Examples\\Hello World\\hello_world.pdx"
  )
endif()
