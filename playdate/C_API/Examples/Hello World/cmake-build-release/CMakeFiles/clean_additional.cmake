# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Release")
  file(REMOVE_RECURSE
  "C:\\Program Files\\PlaydateSDK\\C_API\\Examples\\Hello World\\Source\\pdex.dll"
  "C:\\Program Files\\PlaydateSDK\\C_API\\Examples\\Hello World\\hello_world.pdx"
  )
endif()
