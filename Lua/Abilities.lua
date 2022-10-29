freeslot("S_MISSLE_JUMP")

--Ability States
states[S_MISSLE_JUMP] = {
	sprite = SPR_PLAY,
	tics = 20,
	nextstate = S_PLAY_FALL
}


local abltyEnbl = {
	MS = true;
}


-- Tries to perform Slash Attack, returns true if succedes, false if not
local function slash(player)

end


local function missleSwarm(player) 
	player.mo.state = S_MISSLE_JUMP;
	local enemyMobj = P_LookForEnemies(player);
	local missiles = {}
	for i = 0, 4 do
		missiles[i] = P_SPMAngle(player.mo,
								MT_ROCKET,
								FixedAngle(i * 90 * FRACUNIT));
	end
	-- Vertical Boost
	P_SetObjectMomZ(player.mo, FixedMul(10*FRACUNIT, player.mo.scale));
	
	abltyEnbl.MS = false;
end



local function abilityReset(player)
	-- Reset Missle Swarp
	if(P_IsObjectOnGround(player.mo)) then
		abltyEnbl.MS = true;
	end
end

addHook("AbilitySpecial", function (player)
	-- If Jump is pressed in airPF_JUMPDOWN
	if(abltyEnbl.MS) then
		missleSwarm(player);
	end
end)

addHook("PlayerThink", function(player)
	-- Stop function if the player is not Subjct5
	if(player.mo.skin ~= "subject5") then
		print("Wrong skin: " .. player.mo.skin);
		return
	end
	abilityReset(player);
end);