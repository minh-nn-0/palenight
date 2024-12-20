local collectible = {}

function collectible.update()
	for _, cl in ipairs(pn.get_entities_with_tags({"collectible"})) do
		if pn.colliding_with(cl, PEID) and pn.get_state(PEID) ~= "hurt" then

		end
	end
end

return collectible
