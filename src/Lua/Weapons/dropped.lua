local dropped_mobjs = {}
addHook("NetVars", function(n) dropped_mobjs = n($) end)

mobjinfo[freeslot "MT_MM_DROPPEDWEAPON"] = {
	radius = 32*FU,
	height = 16*FU,
	spawnstate = S_THOK,
	flags = MF_SPECIAL
}

function MM:spawnDroppedWeapon(x, y, z, name)
	if not self.weapons[name] then return end

	local wpn_t = self.weapons[name]

	local wpn = P_SpawnMobj(x, y, z, MT_MM_DROPPEDWEAPON)
	wpn.state = wpn_t.state
	wpn.restrict = wpn_t.restrict
	wpn.give = name

	if not (dropped_mobjs[name]) then
		dropped_mobjs[name] = {}
	end

	table.insert(dropped_mobjs[name], wpn)

	return wpn
end

addHook("MobjThinker", function(d_wpn)
	d_wpn.angle = $+(ANG1*3/2)
	
	if d_wpn.timealive == nil
		d_wpn.timealive = 0
	else
		d_wpn.timealive = $+1
	end
end, MT_MM_DROPPEDWEAPON)

addHook("TouchSpecial", function(d_wpn, toucher)
	if not (toucher
	and toucher.health
	and toucher.player
	and toucher.player.mm
	and not toucher.player.mm.spectator
	and not (toucher.player.mm.weapon and toucher.player.mm.weapon.valid)
	and not d_wpn.restrict[toucher.player.mm.role])
	or (d_wpn.timealive < 10) then
		return true
	end

	MM:giveWeapon(toucher.player, d_wpn.give)
end, MT_MM_DROPPEDWEAPON)

addHook("PostThinkFrame", do
	-- manage weapons
	for _,class in pairs(dropped_mobjs) do
		for k,wpn in pairs(class) do
			if not (wpn and wpn.valid) then
				table.remove(class, k)
				continue
			end
		end
	end
end)

function MM:isWeaponOnMap(name)
	if not dropped_mobjs[name] then return false end

	if #dropped_mobjs[name] then
		return dropped_mobjs[name]
	end
end