freeslot("MT_S5_MISSILE", 
		 "S_MISSILE_WANDER", "S_MISSILE_LOCK_ON", "S_MISSILE_JUMP", 
	     "SPR2_MJMP");

-- Ability States
states[S_MISSILE_JUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_MJMP,
	tics = 20,
	nextstate = S_PLAY_FALL;
}

states[S_MISSILE_LOCK_ON] = {
	sprite = SPR_RCKT,
-- 	tics = 100,
	nextstate = S_NULL
}

states[S_MISSILE_WANDER] = {
	sprite = SPR_TORP,
	tics = 1000,
	nextstate = S_NULL
}

mobjinfo[MT_S5_MISSILE] = {
	spawnstate = S_MISSILE_WANDER,
	deathstate = MT_TORPEDO,
	speed = 15*FRACUNIT,
	flags = MF_MISSILE|MF_NOGRAVITY	
}

local missMaxDist = 300*FRACUNIT;

local abltyEnbl = {
	MS = true;
}

local function tryResetMissiles(player)
	-- Reset Missile Swarp 
	if(P_IsObjectOnGround(player.mo)) then
		abltyEnbl.MS = true;
	end
end


-- Array mobj_t table of missiles created by missile swarm  
local wanderMissiles = {}


-- Tries to remove missile mobjs from table if they no longer exist in-game
local function tryDumpMobjs(tbl)
	for key in pairs(tbl) do 
		if(not tbl[key].valid) then
			tbl[key] = nil;
		end
	end
end
-- Traverses through existing nonlocked-on missiles to check if they are able lock on
local function tryMissilesLockOn(player)
	for key in pairs(wanderMissiles) do
		if(wanderMissiles[key].valid) then 
			searchBlockmap("objects", 
							function (source, dest)
								-- Make sure missile treats player as the mobj 
								-- that shot with it, not the missile it was spawned from
								-- Make sure missile only targets enemies
								if(dest.flags & MF_ENEMY) then
-- 									print("Found target: " .. dest.type);
									local swndM = P_SpawnMissile(player.mo, dest, MT_S5_MISSILE);
									P_TeleportMove(swndM, source.x, source.y, source.z);
									swndM.state = S_MISSILE_LOCK_ON;
-- 									print("Locking on missile: " .. swndM.type);
									-- Substituting wandering missile for a lock on missile;
									source.state = S_NULL;
									source = nil;
									
								else
-- 									print("Wrong dest: " .. dest.type);
-- 									print("Flags: : " .. dest.flags);
									return;
								end
							end,
							wanderMissiles[key], 
							wanderMissiles[key].x - missMaxDist, 
							wanderMissiles[key].x + missMaxDist, 
							wanderMissiles[key].y - missMaxDist, 
							wanderMissiles[key].y + missMaxDist);
		end
	end
end

-- Double Jumps and shoots missiles in all directions
local function missileSwarm(player) 
	player.mo.state = S_MISSILE_JUMP;
	for i = 0, 7 do
		table.insert(wanderMissiles, P_SPMAngle(player.mo,
										   MT_S5_MISSILE,
										   player.mo.angle + FixedAngle(i*90*FRACUNIT)));
		print("spawning a missile + " .. FixedAngle(i*90*FRACUNIT));
	end
	-- Vertical Boost
	P_SetObjectMomZ(player.mo, FixedMul(10*FRACUNIT, player.mo.scale));

	abltyEnbl.MS = false;
end

addHook("AbilitySpecial", function (player)
	-- If Jump is pressed in air
	if(abltyEnbl.MS) then
		missileSwarm(player);
	end
	
end)

addHook("PlayerThink", function(player)
	-- Stop function if the player is not Subjct5
	if(player.mo.skin ~= "subject5") then
		print("Wrong skin: " .. player.mo.skin);
		return
	end
	tryResetMissiles(player);
	tryDumpMobjs(wanderMissiles);
	tryMissilesLockOn(player);
end);

-- Makes missile ignore some objects
addHook("MobjDamage", -- doesn't work becaues missile doesn't live long enough
		function(target, inflictor, source, damage, damagetype) 
-- 			print("target: " .. target.type);
-- 			print("inflictor: " .. inflictor.type);
-- 			print("source: " .. source.type);
-- 			print("damage: " .. damage);
-- 			print("damagetype: " .. damagetype);
-- 			print("");

-- 			-- Missiles won't damage if these conditions met
-- 			if(inflictor.type == MT_S5_MISSILE
-- 			and target.flags ~= MF_ENEMY) then
-- 				print("Damage should be avoided");
-- 				return true;
-- 			end
			print(inflictor.type .. " damages " .. target.type);
		
		end);