freeslot("S_FIRE_MISSILE")

--Ability States
states[S_FIRE_MISSILE] = {
	sprite = S_PLAY_STND,
	tics = 20,
	nextstate = S_NULL
}


-- Tries to perform Slash Attack, returns true if succedes, false if not
local function slash(player)

end

local function missleSwarm(player) 
	player.mo.state = S_FIRE_MISSILE;
	
	local enemyMobj = P_LookForEnemies(player);
	local missileObj;
	if(enemyMobj == nil) then
		missileObj = P_SPMAngle(player.mo, MT_ROCKET, 180);
	else	
		missileObj = P_SpawnMissile(player.mo, enemyMobj, MT_ROCKET);
	end
		print("Missle Fire State: ".. S_FIRE_MISSILE);
		print("Player state: " .. player.mo.state);
		print("Player tics: " .. player.mo.tics);
end

local prevstate = 0;
local function abilityCall(player)
	-- Stop if the player is not Subjct5
	if(player.mo.skin ~= "subject5") then
		print("Wrong skin: " .. player.mo.skin);
		return
	end
	
	if(player.mo.state ~= prevstate) then
		prevstate = player.mo.state;
		print(prevstate);
	end

	if(player.cmd.buttons == BT_SPIN) then
		print("spin");
		if(player.mo.state ~= S_FIRE_MISSILE) then
			missleSwarm(player);
		end
	end
	if(player.cmd.buttons == BT_JUMP) then
		print("jump");
	end
end

addHook("PlayerThink", abilityCall);