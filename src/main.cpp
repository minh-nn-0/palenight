#include "game.hpp"
#ifdef __EMSCRIPTEN__
#include "/home/minhmacg/.cache/emscripten/sysroot/include/emscripten.h"
#endif
int main(int argc, char** argv)
{
	pn::game maingame;
	maingame.run();
	std::println("exiting main");
};
