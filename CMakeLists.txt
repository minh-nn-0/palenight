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

if (EMSCRIPTEN)
	target_link_options(palenight PRIVATE --preload-file=assets --preload-file=scripts --preload-file=config.lua -sUSE_SDL=2 -sUSE_SDL_IMAGE=2 -sUSE_SDL_TTF=2 -sUSE_SDL_MIXER=2) 
	set_target_properties(palenight PROPERTIES SUFFIX ".html")
endif()
# Install the executable
install(FILES $<TARGET_RUNTIME_DLLS:palenight> DESTINATION bin/palenight)
install(TARGETS palenight RUNTIME DESTINATION bin/palenight)
