freeslot("S_MISSLE_JUMP", "SPR2_MJMP");

-- Ability States
states[S_MISSLE_JUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_MJMP,
	tics = 100,
	nextstate = S_PLAY_FALL;
}

local function stateFunc(p1)
	print(p1);
end


local abltyEnbl = {
	MS = true;
}

local function abilityReset(player)
	-- Reset Missle Swarp
	if(P_IsObjectOnGround(player.mo)) then
		abltyEnbl.MS = true;
	end
end

-- Tries to perform Slash Attack, returns true if succedes, false if not
local function slash(player)

end

-- Double Jumps and shoots missiles in all directions
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



addHook("AbilitySpecial", function (player)
	-- If Jump is pressed in air
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
	if(player.mo.state == S_MISSLE_JUMP) then
		print("S_MISSLE_JUMP: " .. S_MISSLE_JUMP);
-- 		print(states[S_MISSLE_JUMP].tics);
	end
	print(player.mo.tics);
	abilityReset(player);
end);