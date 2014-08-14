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
    
    local hero = player.hero
    local caster = keys.caster
    local numTargets = keys.numTargets
    local ABILITY_powerball_knockback = caster:FindAbilityByName("rammus_powerball_knockback")
	
	local enemiesInRange = FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetOrigin(),
        nil, 1100,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP,
        0, 
        FIND_CLOSEST,
        false)
    
    --FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache)
        
	if #enemiesInRange > 0 then
		for i = 1, 3 do
            --create a projectile and hit each of the three(five) closest enemies
            local targetEntity = enemiesInRange[i]            
            local info = {
                          EffectName = "tinker_heat_seeking_missile", --"obsidian_destroyer_arcane_orb", --,
                          Ability = caster:getAbilityByName(hero, "old_heimerdinger_rockets"),
                          vSpawnOrigin = hero:GetOrigin(),
                          fDistance = 5000,
                          fStartRadius = 125,
                          fEndRadius = 125,
                          Target = targetEntity,
                          Source = hero,
                          iMoveSpeed = 500,
                          bReplaceExisting = false,
                          bHasFrontalCone = false,
                          --fMaxSpeed = 5200,
                        }
            
            ProjectileManager:CreateTrackingProjectile(info)
        end
    end
	
end

