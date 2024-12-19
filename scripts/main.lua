local gamestate = require "gamestate"

function LOAD()
	beaver.new_image(pn.gamepath() .. "/assets/images/endlessrunner_dog.png", "spritesheet_dog")
	beaver.new_image(pn.gamepath() .. "/assets/images/endlessrunner_tileset.png", "tileset")

	beaver.new_font(pn.gamepath() .. "/assets/fonts/mago1.ttf", 16, "mago")
	beaver.new_font(pn.gamepath() .. "/assets/fonts/mago1.ttf", 100, "mago100")
	beaver.new_font(pn.gamepath() .. "/assets/fonts/mago1.ttf", 50, "mago50")

	beaver.new_sound(pn.gamepath() .. "/assets/audios/pnhit.wav", "hurt")
	beaver.new_sound(pn.gamepath() .. "/assets/audios/pnattack.wav", "attack")
	beaver.new_sound(pn.gamepath() .. "/assets/audios/pnjump.wav", "jump")
	beaver.new_music(pn.gamepath() .. "/assets/audios/man-is-he-mega.mp3", "bgm1")

	beaver.set_render_logical_size(config.logical_size[1], config.logical_size[2])

	gamestate.load()
end
function UPDATE(dt)
	return gamestate.update(dt)
end
function DRAW()
	beaver.set_draw_color(25,29,30,255)
	beaver.clear()
	gamestate.draw()
end





