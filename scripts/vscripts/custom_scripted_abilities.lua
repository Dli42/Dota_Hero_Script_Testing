--[[Gets an initial value for the armor to damage buff]]
function RammusSpikedShellInit(keys)

	local caster = keys.caster
	local armorAmount = caster:GetPhysicalArmorValue()
	damageBuff = armorAmount * 0.25

end

--[[ Calculates and adds damage based on 25% of current armor
	First subtracts the previous bonus to avoid counting it twice]]
function RammusSpikedShellBuff(keys)

    local caster = keys.caster
	local armorAmount = caster:GetPhysicalArmorValue()
	local originalDamageMin = caster:GetBaseDamageMin() - damageBuff
	local originalDamageMax = caster:GetBaseDamageMax() - damageBuff
	damageBuff = armorAmount * 0.25
	
    caster:SetBaseDamageMin(originalDamageMin + damagebuff)
	caster:SetBaseDamageMax(originalDamageMin + damagebuff)
    
end

--[[Forces the target to attack the caster
	Doesn't work when target is already disabled and the attack order is invalid, need to fix]]
function RammusPuncturingTaunt(keys)

    local target = keys.target
    local caster = keys.caster

    local attackOrder = {
                            UnitIndex = target:entindex(), 
                            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                            TargetIndex = caster:entindex()
                        }
    ExecuteOrderFromTable(attackOrder)
    
end

--[[Detects whether any enemy units are within 150 aoe of the caster, if there is then knockback, deal damage, and cancel powerball]]
---[[
function RammusPowerballKnockbackTarget(keys)
    
    local caster = keys.caster
    local ABILITY_powerball_knockback = caster:FindAbilityByName("rammus_powerball_knockback")
	
	local enemiesInRange = FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetOrigin(),
        nil, 150,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        0, 0,
        false)
    
    --FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache)
        
	if #enemiesInRange > 0 then
		print( "I HIT THEM!" )
        caster:RemoveModifierByName("modifier_rammus_powerball_attack_disable")
        caster:RemoveModifierByName("rammus_powerball_pseudothinker")
        RammusPowerballResetMovespeed(keys)
        ABILITY_powerball_knockback:CastAbility()
    else
        print( "KEEP ON ROLLIN!!" )
    end
	
end
--]]

function RammusPowerballKnockbackLevelUp(keys)

    local caster = keys.caster
    local ABILITY_powerball_knockback = caster:FindAbilityByName("rammus_powerball_knockback")
    local ABILITY_powerball = caster:FindAbilityByName("rammus_powerball")
    
    local powerball_level = ABILITY_powerball:GetLevel()
    ABILITY_powerball_knockback:SetLevel(powerball_level)    
    
    print( "knockback level: ", ABILITY_powerball_knockback:GetLevel())
end

--[[Adds 3% movespeed to base, called every .127 seconds for a max of +165%]]
function RammusPowerballMovespeedBuff(keys)

    local caster = keys.caster
    local oldMoveSpeed = caster:GetBaseMoveSpeed()
    local newMoveSpeed = oldMoveSpeed + (originalMoveSpeed*.03)
    caster:SetBaseMoveSpeed(newMoveSpeed)   
    
end

--[[sets a global to track the original movespeed of the caster, needed at end of buff]]
function RammusPowerballGetMovespeed(keys)

    local caster = keys.caster
    originalMoveSpeed = caster:GetBaseMoveSpeed() 
		
	--setModel("models\props_structures\bad_ancient_sphere.mdl")
    
    caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst_speed", { duration = dur})
    
end

--[[resets movespeed to original, can't go fast forever]]
function RammusPowerballResetMovespeed(keys)

    local caster = keys.caster  
    caster:SetBaseMoveSpeed(originalMoveSpeed)
	
	--setModel("models\heroes\axe\axe.mdl")
    
    caster:RemoveModifierByName("modifier_bloodseeker_thirst_speed")
	
end

--[[Damages anyone attacking the caster based on multiplier to armor 
	Applied as seperate damage instance to base return damage]]
function RammusDefensiveBallCurlReturnDamage(keys)

	local caster = keys.caster
	local target = keys.target
	
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetPhysicalArmorValue()*.3,
		damage_type = DAMAGE_TYPE_MAGICAL}
						
	
	target:ApplyDamage(damageTable)
	
end

function OldHeimerdingerRocketsTarget(keys)
    
    local caster = keys.caster
    local numTargets = keys.numTargets
    local ABILITY_old_heimerdinger_rockets = caster:FindAbilityByName("old_heimerdinger_rockets")
	
	local enemiesInRange = FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetOrigin(),
        nil, 1100,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
        FIND_CLOSEST,
        false)
    
    --FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache)
        
    if caster:HasModifier("old_heimerdinger_upgrade_modifier") then
        numTargets = 5
    end
    
    print(numTargets)
        
	if #enemiesInRange > 0 then
		for i = 1, numTargets do
            --create a projectile and hit each of the three(five) closest enemies
            local targetEntity = enemiesInRange[i]            
            local info = {
                          EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf", --"obsidian_destroyer_arcane_orb", --,
                          Ability = ABILITY_old_heimerdinger_rockets,
                          vSpawnOrigin = caster:GetOrigin(),
                          fDistance = 5000,
                          fStartRadius = 125,
                          fEndRadius = 125,
                          Target = targetEntity,
                          Source = caster,
                          iMoveSpeed = 2000,
                          bReplaceExisting = false,
                          bHasFrontalCone = false,
                          --fMaxSpeed = 5200,
                        }
            
            ProjectileManager:CreateTrackingProjectile(info)
        end
    end	
end

function OldHeimerdingerGrenade(keys)
    local caster = keys.caster
    local target = keys.target
    local ABILITY_old_heimerdinger_grenade = caster:FindAbilityByName("old_heimerdinger_concussion_grenade")
    local movespeed = 1250
    if caster:HasModifier("old_heimerdinger_upgrade_modifier") then
        movespeed = 2500
    end
    
    local info = {
                EffectName = "particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf",
                Ability = ABILITY_old_heimerdinger_grenade,
                vSpawnOrigin = caster:GetOrigin(),
                fDistance = 5000,
                fStartRadius = 125,
                fEndRadius = 125,
                Source = caster,
                iMoveSpeed = movespeed,
                bReplaceExisting = false,
                bHasFrontalCone = false,                  			
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
                }
    
    ProjectileManager:CreateLinearProjectile(info)
    print(movespeed)
end

function OldHeimerdingerSpawnTurret(keys)
    
    local caster = keys.caster
    local ABILITY_turret = caster:FindAbilityByName("old_heimerdinger_turret")    
    local turretLevel = ABILITY_turret:GetLevel()
    
    local npcTable = {
    "npc_old_heimerdinger_turret_1",
    "npc_old_heimerdinger_turret_2",
    "npc_old_heimerdinger_turret_3",
    "npc_old_heimerdinger_turret_4",
    "npc_old_heimerdinger_turret_5"
    }
    
    local turretName = npcTable[turretLevel]
    
    print(turretName)
  
    if turretTable == nil then
        turretTable = {}
    end        

     -- Create the unit around the caster and find free space for it to prevent getting suck
     local unit = CreateUnitByName(turretName, keys.target_points[1], true, nil, nil, keys.caster:GetTeam())
     -- Set the owner of the new unit to the owner of the old unit
     unit.vOwner = keys.caster:GetOwner()
     -- Set the new owner as the controlling player
     unit:SetControllableByPlayer(keys.caster:GetOwner():GetPlayerID(), true )
        -- Note: Only heroes will return the correct value for keys.caster:GetPlayerOwnerID()
        -- Using keys.caster:GetOwner():GetPlayerID() will allow created units to create more units
        -- For example having builder make a building and that building create units
    table.insert(turretTable, unit)
    
    local count = 0 
    for key,value in pairs(turretTable) do 
        count = count + 1 
    end
    
    print(count)
    
    if turretTable[4] ~= nil then
        turretTable[1]:ForceKill(true)
        table.remove(turretTable, 1)
    end
    
end

function OldHeimerdingerUpgrade(keys)
    local caster = keys.caster
    local ABILITY_turret = caster:FindAbilityByName("old_heimerdinger_turret")
    local ABILITY_rockets = caster:FindAbilityByName("old_heimerdinger_rockets")
    local ABILITY_grenade = caster:FindAbilityByName("old_heimerdinger_concussion_grenade")
    ABILITY_turret:EndCooldown()
    ABILITY_rockets:EndCooldown()
    ABILITY_grenade:EndCooldown()
end

