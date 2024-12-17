cmake_minimum_required(VERSION 3.25)

project(palenight)

add_executable(palenight 
	${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/game.cpp
)

target_compile_definitions(palenight PRIVATE
	GAMEPATH="${CMAKE_CURRENT_SOURCE_DIR}"
)
#set(CMAKE_CXX_FLAGS "-O3 -Wall -Wextra") #Stimulate release mode, does work
#target_link_libraries(palenight PRIVATE "-Wl,--stack,80000000")

target_link_libraries(palenight PRIVATE beaver)

install(FILES $<TARGET_RUNTIME_DLLS:palenight> DESTINATION bin/palenight)

# Install the executable
install(TARGETS palenight RUNTIME DESTINATION bin/palenight)
