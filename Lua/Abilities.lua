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

-- Tries to replace a wandering missile with lock-on missile
local function tryMissileLock(wMissile)
	if(wMissile.valid and wMissile.state == S_MISSILE_WANDER) then 
		searchBlockmap("objects", 
						-- source: wandering missile mobj to be replaced 
						-- dest: a mobj that was found
						function (source, dest) 
							-- if any of it is true, don't lock-on 
							if(dest.type == MT_S5_MISSILE
							or source.target == dest
							or not (dest.lock == nil)
							or not P_CheckSight(source, dest)
							or not (dest.flags & MF_ENEMY)) then
								return;
							end
							-- Creates a lock on missile
							local swndM = P_SpawnMissile(source, dest, MT_S5_MISSILE);
							if(swndM == nil) then
								return;
							end
							swndM.target = source.target;
							swndM.lock = dest;
							dest.lock = swndM;
							-- Replacing wandering missile for a lock on missile
							swndM.state = S_MISSILE_LOCK_ON;
							P_RemoveMobj(source);
						end,
						wMissile, 
						wMissile.x - missMaxDist, 
						wMissile.x + missMaxDist, 
						wMissile.y - missMaxDist, 
						wMissile.y + missMaxDist);
	end
end

local function ignoreMissileDmg(target, inflictor, source, damage, damagetype)
	local shouldDmg = not (target.type == MT_PLAYER and inflictor.type == MT_S5_MISSILE);
	print("Should damage? "..tostring(shouldDmg));
	return shouldDmg;
end;

local function removeLockOn(mobj)
	if(not !mobj.lock) then
		print("lock was nil?");
		return;
	end;
	local mobj1 = mobj.lock;
	mobj.lock = nil;
	if(not !mobj.lock) then
		print("another lock was nil");
		return;
	end;
	mobj1.lock = nil;
end

-- Double Jumps and shoots missiles in all directions
local function missileSwarm(player) 
	player.mo.state = S_MISSILE_JUMP;
	for i = 0, 7 do
		 P_SPMAngle(player.mo, MT_S5_MISSILE, player.mo.angle + FixedAngle(i*45*FRACUNIT))
	end
	
	-- Vertical Boost for player
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
		return
	end
	tryResetMissiles(player);
end);

addHook("MobjCollide", 
		function(collidingWith, missile)
			removeLockOn(missile);
		end,
		MT_S5_MISSILE);
addHook("MobjDeath", 
		function(missile, p1, p2, p3) 
			removeLockOn(missile);
		end,
		MT_S5_MISSILE)
		
-- Tries to replace a wandering missile with lock-on missile
addHook("MobjThinker", tryMissileLock, MT_S5_MISSILE);
-- Ignores specific missile targets
addHook("ShouldDamage", ignoreMissileDmg, MS_S5_MISSILE);