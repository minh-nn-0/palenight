cmake_minimum_required(VERSION 3.25)

project(palenight)

add_executable(palenight 
	${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/game.cpp
)

target_compile_definitions(palenight PRIVATE
	GAMEPATH="${CMAKE_CURRENT_SOURCE_DIR}"
)
target_link_libraries(palenight PRIVATE beaver)
