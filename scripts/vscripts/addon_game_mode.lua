require('util')
require('action_test')

-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]    

    PrecacheUnitByNameSync('npc_dota_hero_axe', context)
    PrecacheResource( "soundfile", "*.vsndevts", context )
    PrecacheResource( "particle_folder", "particles/frostivus_gameplay", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_venomancer/venomancer_plague_ward_projectile.vpcf", context )
    PrecacheUnitByNameSync('npc_precache_everything', context)
    PrecacheModel("models/heroes/venomancer/venomancer_ward.mdl", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end