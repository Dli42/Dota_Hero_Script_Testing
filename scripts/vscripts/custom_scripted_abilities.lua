function OriannaCommandAttack(keys)
    local target = keys.target_points[1]
    local caster = keys.caster
    local ball = caster.ball
    local damage = keys.Damage

    if ball == nil then
        print("no ball!")
        return
    end

    print(ball.state.." -> attack", ball.target, target, damage)
    ball.state = "attack"
    ball.target = target
    ball.attackDamage = damage
end

function OriannaCommandDissonance(keys)
    local caster = keys.caster
    local ball = caster.ball
    local damage = keys.Damage
    local ability = keys.ability
    if ball == nil then
        print("no ball!")
        return
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball)
    ParticleManager:SetParticleControl(particle, 1, Vector(500,0,0))
    -- ParticleManager:DestroyParticle(particle, true)
    -- ParticleManager:ReleaseParticleIndex(particle)

    local enemiesInRange = FindUnitsInRadius(
    caster:GetTeam(),
    ball:GetOrigin(),
    nil, 
    250,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_CLOSEST,
    false)

    if #enemiesInRange > 0 then
        for k,v in pairs(enemiesInRange) do
            local damageTable = {
                victim = v,
                attacker = caster,
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL}
                                
            ApplyDamage(damageTable)
            ability:ApplyDataDrivenModifier(caster, v, "modifier_dissonance_debuff", {duration = 2})
        end
    end

    local alliesInRange = FindUnitsInRadius(
    caster:GetTeam(),
    ball:GetOrigin(),
    nil, 
    250,
    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_CLOSEST,
    false)

    if #alliesInRange > 0 then
        for k,v in pairs(alliesInRange) do
            print(v:GetUnitName())
            ability:ApplyDataDrivenModifier(caster, v, "modifier_dissonance_buff", {duration = 2})
        end
    end
end

function OriannaCommandProtect(keys)
    local target = keys.target
    local caster = keys.caster
    local ball = caster.ball
    local damage = keys.Damage

    if ball == nil then
        print("no ball!")
        return
    end

    if ball.protectTarget ~= nil then
        ball.protectTarget:RemoveModifierByName("modifier_protect_shield")
    end

    print(ball.state.." -> protect", target, damage)
    ball.state = "protect"
    ball.protectTarget = target
    ball.attackDamage = damage
    ball.abilityProtect = keys.ability
end

function OriannaCommandShockwave(keys)
    local caster = keys.caster
    local ball = caster.ball

    if ball == nil then
        print("no ball!")
        return
    end

    local ballAbility = ball:FindAbilityByName("the_ball_command_shockwave")
    if ballAbility == nil then
        ball:AddAbility("the_ball_command_shockwave")
        ballAbility = ball:FindAbilityByName("the_ball_command_shockwave")
    end

    local level = keys.ability:GetLevel()
    ballAbility:SetLevel(level)
    ball:CastAbilityNoTarget(ballAbility, caster:GetPlayerID())
    print("Trying to cast shockwave")
end

function OriannaCommandShockwaveParticle(keys)
    print("Shockwave!")
    local caster = keys.caster
    local effectName = "particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf"
    local particle = ParticleManager:CreateParticle(effectName, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, Vector(1,0,0))
    ParticleManager:SetParticleControl(particle, 1, Vector(350,0,0))
    ParticleManager:SetParticleControl(particle, 2, Vector(0.25,0,0))
    ParticleManager:SetParticleControl(particle, 3, caster:GetOrigin())
    ParticleManager:SetParticleControl(particle, 4, Vector(90,0,0))
end

function GlobalCooldown(keys)
    local caster = keys.caster
    local cooldownTable = keys.CooldownTable

    for k,v in pairs(cooldownTable) do
        local ability = caster:FindAbilityByName(v[1])
        ability:StartCooldown(v[2])
    end
end



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
		
	--setModel("models/props_structures/bad_ancient_sphere.mdl")
    
    caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst_speed", { duration = dur})
    
end

--[[resets movespeed to original, can't go fast forever]]
function RammusPowerballResetMovespeed(keys)

    local caster = keys.caster  
    caster:SetBaseMoveSpeed(originalMoveSpeed)
	
	--setModel("models/heroes/axe/axe.mdl")
    
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
						
	
	ApplyDamage(damageTable)
	
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

function OldHeimerdingerGrenade(keys)   --Doesn't work
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
    
    -- Table of turret names, one for each level
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
    
    -- Get the number of turrets in the table, including hte one just created
    local count = #turretTable
    
    print(count)
    
    -- If there are 4 turrets kill the oldest one
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
    
    if turretTable ~= nil then
        for key,turret in pairs(turretTable) do 
            callModApplier( turret, "modifier_heimerdinger_turret_upgraded_attack")
            print("applied to turret ", key)
        end
    end
end

function FinalAtomicBuster_part_1 (keys)
    local caster = keys.caster
    local target = keys.target
    
    local targetPos = target:GetAbsOrigin()
    local casterPos = caster:GetAbsOrigin()
 
    local direction = targetPos - casterPos
    local vec = direction:Normalized() * 3.0
 
    args.caster:SetAbsOrigin(casterPos + vec)
    
    --SetAngularVelocity(float pitch, float yaw, float roll)
end

function FinalAtomicBuster_part_2 (keys)
    local caster = keys.caster
    Physics:Unit(caster)
    
    caster:PreventDI(true)
    caster:SetAutoUnstuck(false)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)

    local direction = (Vector(0,0,1) * 500)
    direction = direction:Normalized()
    caster:SetPhysicsFriction(0)
    
    local gravity = -10
    local velocity = 500

    caster:SetPhysicsVelocity(direction * velocity)
    caster:SetPhysicsAcceleration(Vector(0,0,gravity))
    --caster:AddPhysicsVelocity(Vector(0,0,jump))
    
    print("exiting FinalAtomicBuster_part_2")
end

function FinalAtomicBuster_part_3 (keys)
    local caster = keys.caster
    local target = keys.target
    
end

function jump_impulse(move_me, start_pos, end_pos, height, movespeed, gravity)
    
end

function calculate_parabola (start_vector, end_vector, height, num_points)

    local point_table = {}
    local y_distance = math.abs(end_vector.y - start_vector.y)
    local x_distance = math.abs(end_vector.x - start_vector.x)
    local abs_distance = math.sqrt((y_distance^2) + (x_distance^2))

    local a = (4*height)/(abs_distance^2)

    print(y_distance)
    print(x_distance)
    print(abs_distance)
    print(a)

    print ("y = -",a,"x^2 + ",height)

    local x_step_size = x_distance/num_points
    local y_step_size = y_distance/num_points
    local abs_step_size = math.sqrt(x_step_size^2 + y_step_size^2)

    for i = 0, num_points do
        
        local new_x = start_vector.x + i*x_step_size
        local new_y = start_vector.y + i*y_step_size

        local abs_point = i*abs_step_size-(abs_distance/2)
        local new_z = ((-1*a)*((abs_point)^2)) + height

        local new_vector = Vector(new_x, new_y, new_z)
        
        table.insert(point_table, new_vector)
        print(new_x, new_y, new_z)
    end

    return point_table
    
end

function MakeForwardLinearProjectile(keys)
    local caster = keys.caster
    local info = 
    {
        Ability = keys.ability,
        EffectName = keys.EffectName,
        iMoveSpeed = keys.MoveSpeed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        vVelocity = caster:GetForwardVector() * keys.MoveSpeed,
        fDistance = keys.FixedDistance,
        fStartRadius = keys.StartRadius,
        fEndRadius = keys.EndRadius,
        Source = caster, 
        bHasFrontalCone = keys.HasFrontalCone,
        bReplaceExisting = false,
        iUnitTargetTeam = keys.TargetTeams,
        iUnitTargetFlags = keys.TargetFlags,
        iUnitTargetType = keys.argetTypes,
        fExpireTime = GameRules:GetGameTime() + 10.0,
    }
    local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function RiflemanRocketJump(keys)
    
    local target = keys.target_points[1]
    local caster = keys.caster
    
    Physics:Unit(caster)
    
    if target==nil then
      return
    end
    
    caster:PreventDI(true)
    caster:SetAutoUnstuck(false)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)
    
    local distance = target - caster:GetAbsOrigin()
    local direction = target - caster:GetAbsOrigin()
    direction = direction:Normalized()
    caster:SetPhysicsFriction(0)
    
    local gravity = -100
    local velocity = 1000
    local timetotarget = distance:Length() / velocity
    local jump = gravity * (30*timetotarget) * -1
    jump = jump/2
    
    caster:SetPhysicsVelocity(direction * velocity)
    
    caster:AddPhysicsAcceleration(Vector(0,0,gravity))
    caster:AddPhysicsVelocity(Vector(0,0,jump))
    
    Timers:CreateTimer(math.min(timetotarget, .5),
    function()
      local groundpos = GetGroundPosition(caster:GetAbsOrigin(), caster)
      if caster:GetAbsOrigin().z - groundpos.z <= 20 then
          caster:SetPhysicsAcceleration(Vector(0,0,0))
          caster:SetPhysicsVelocity(Vector(0,0,0))
          caster:OnPhysicsFrame(nil)
          caster:PreventDI(false)
          caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
          caster:SetAutoUnstuck(true)
          caster:FollowNavMesh(true)
          caster:SetPhysicsFriction(.05)
          FindClearSpaceForUnit(caster, target, true)
          return nil
      end
      return 0.01
    end)
end

function SpinHero(keys)
    local caster = keys.caster
    local total_degrees = keys.Angle
    print("Spinning ", total_degrees, "degrees about center")
    caster:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0,total_degrees,0), caster:GetForwardVector()))
end

function SpinHeroTEST(keys)
    local caster = keys.Caster
    local target = keys.Target
    local center = keys.Center
    if type(center) == "string" then
        if center == "CASTER" then
            center = target:GetAbsOrigin() - caster:GetAbsOrigin()
        elseif center == "TARGET" then
            center = target:GetAbsOrigin()- target:GetAbsOrigin()
        else
            print("invalid center")
            return nil
        end
    else
        center = target:GetAbsOrigin() - center
    end
    local total_degrees = keys.Angle
    print("Spinning ", total_degrees, "degrees", "about", center)
    caster:SetForwardVector(RotatePosition(center, QAngle(0,total_degrees,0), target:GetForwardVector()))
end

function BloodTest(keys)
    local target = keys.target
    if target:HasModifier("modifier_infected_blood") then
        ShowMessage("This person is the Thing!")
    else
        ShowMessage("No reaction...")
    end    
end

function WhisperToTarget(keys)
    PrintTable(keys)
    local caster = keys.caster
    local target = keys.target
    local myString = keys.String
    local teamID = target:GetTeam()
    local playerID = target:GetPlayerOwnerID()
    
    print(caster, target, teamID, playerID)
    
    GameRules:SendCustomMessage(myString,teamID,playerID)    
end

function PingItemInRange(keys)
    PrintTable(keys)
    local caster = keys.caster
    local range = keys.Range    
    local itemTable = keys.ItemTable
    
    for itemName,itemColor in pairs(itemTable) do
        if itemColor == nil then
            itemColor = "255 255 255"
        end
        
        local stringParse = string.gmatch(itemColor, "%d+")
    
        --need to divide by 255 to convert to 0-1 scale
        local redVal = tonumber(stringParse())/255
        local greenVal = tonumber(stringParse())/255
        local blueVal = tonumber(stringParse())/255        
        
        print("caster info", caster:GetTeam(), caster:GetOrigin(),range)
        --FindInSphere(handle startFrom, Vector origin, float maxRadius)
        local ent = Entities:FindInSphere(nil, caster:GetOrigin(), range)

        while ent ~= nil do
            if ent:GetName() == itemName then
                print("pinging", ent, "at", ent:GetAbsOrigin().x, ent:GetAbsOrigin().y, ent:GetAbsOrigin().z)
                --maybe use CreateParticleForPlayer(string particleName, int particleAttach, handle owningEntity, handle owningPlayer)
                local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, ent)
                ParticleManager:SetParticleControl(thisParticle, 0, ent:GetAbsOrigin())
                ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
                print(itemName, redVal, greenVal, blueVal)
                ParticleManager:ReleaseParticleIndex(thisParticle)
                ent:EmitSound("sounds/ui/ping.vsnd")
            end
            ent = Entities:FindInSphere(ent, caster:GetOrigin(), range)
        end
    end
end

function EnsnareUnit(keys)
    print("Ensare!")
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = 8.0
    if (string.find(targetName,"hero") ~= nil) then --if the target's name includes "hero"
        dur = 3.5
    end
    
    target:AddNewModifier(caster, nil, "modifier_meepo_earthbind", { duration = dur})    
end

function TrackUnit(keys)
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = keys.duration
    if (string.find(targetName,"hero") == nil) then --if the target's name does not include "hero", ie an animal
        dur = 30.0
    end
    
    caster:SetThink(SpotterFollowThink(trackSpotter, target))
    
    target:AddNewModifier(caster, nil, "modifier_track_hero", { duration = dur})
end

--[[function SpotterFollowThink(trackSpotter, targetToFollow)
    
    trackSpotter:SetAbsOrigin() = targetToFollow:GetAbsOrigin()
    
    if trackSpotter == nil then
        return nil
    else if targetToFollow == nil then
        return nil
    end
    
    return 0.2
end--]]

--[[Checks unit inventory for matching recipes. If there's a match, remove all items and add the corresponding potion
    Matches must have the exact number of each ingredient
    Used for both the Mixing Pot and the Herb Telegatherer]]
function MixHerbs(keys)
    print("MixHerbs")
    local caster = keys.caster
    --Table to identify ingredients
    local herbTable = {"item_river_stem", "item_river_root", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_herb_blue"}
    local specialTable = {"item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_herb_blue"}
    --Table used to look up herb recipes, can move this if other functions need it
    local recipeTable = {
        {"item_spirit_wind", {item_river_stem = 2}},
        {"item_spirit_water", {item_river_root = 2}},
        {"item_potion_anabolic", {item_river_stem = 6}},
        {"item_potion_cure_all", {item_herb_butsu = 6}},
        {"item_potion_drunk", {item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_healingi", {item_river_root = 1, item_herb_butsu = 1}},
        {"item_potion_healingiii", {item_river_root = 2, item_herb_butsu = 2}},
        {"item_potion_healingiv", {item_river_root = 3, item_herb_butsu = 3}},
        {"item_potion_manai", {item_river_stem = 1, item_herb_butsu = 1}},
        {"item_potion_manaiii", {item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_manaiv", {item_river_stem = 3, item_herb_butsu = 3}},
        {"item_rock_dark", {item_river_root = 2, item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_twin_island", {item_herb_orange = 3, item_herb_purple = 3}},
        {"item_potion_twin_island", {item_herb_yellow = 3, item_herb_blue = 3}},
        {"item_essence_bees", {item_herb_orange = 1, item_herb_purple = 1, item_herb_yellow = 1, item_herb_blue = 1}},
        {"item_gem_of_knowledge", {item_herb_blue = 1, item_herb_orange = 3, item_herb_yellow}},
        {"item_gem_of_knowledge", {item_herb_blue = 1, item_herb_orange = 3, item_herb_purple}},
        {"item_potion_anti_magic", {special_1 = 6}},
        {"item_potion_fervor", {special_1 = 3, item_herb_butsu = 1}},
        {"item_potion_elemental", {special_1 = 1, item_river_stem = 3, item_river_root = 1}},
        {"item_potion_disease", {special_1 = 2,special_2 = 2, item_river_root = 1}},
        {"item_potion_nether", {special_1 = 1, item_river_stem = 2, item_herb_butsu = 2}},
        {"item_essence_bees", {special_1 = 2, special_2 = 1, special__3 = 1}},
        {"item_potion_acid", {special_1 = 2, special_2 = 2, item_river_stem = 2}}
    }
    
    --recipes that use special herbs. A bit more complicated
    --[[

    --]]
    
    local myMaterials = {}
    local itemTable = {}
    
    --loop through inventory slots
    for i = 0,5 do
        local item = caster:GetItemInSlot(i)    --get the item in the slot
        if item ~= nil then --if the slot is not empty
            local itemName = item:GetName() --get the item's name
            print(i, itemName)  --debug
            --loop through list of possible ingredients to see if the inventory item is one
            for i,herbName in pairs(herbTable) do
                if itemName == herbName then  --if the item is an herb ingredient
                    print("Adding to table", itemName)
                    if myMaterials[itemName] == nil then  --add it to our internal list
                        myMaterials[itemName] = 0
                    end
                    myMaterials[itemName] = myMaterials[itemName] + 1   --increment the count
                    table.insert(itemTable, item)
                end                
            end
        else
            print(i, "empty")  --more debug, print empty slot
        end
    end
    
    print("Check for match")
    --check if player materials matches any recipes
    for i,value in pairs(recipeTable) do  --loop through the recipe table
        local recipeName = recipeTable[i][1]    --get the name of the recipe
        local recipeIngredients = recipeTable[i][2] --get the items needed for the recipe
        if CompareTables(recipeIngredients, myMaterials) then    --if a recipe matches
            print("Match!", i)
            local newItem = CreateItem(recipeName, nil, nil)   --create the resulting item
            for i,removeMe in pairs(itemTable) do   --delete the materials
                caster:RemoveItem(removeMe)
            end
            caster:AddItem(newItem) --add the new item
            return  --end the function, only one item per mix
        end
    end   
    
    
    print("Check for special match")
    local specialTable = {
        {"item_herb_orange", 0},
        {"item_herb_purple", 0},
        {"item_herb_yellow", 0},
        {"item_herb_blue", 0}
    }
    
        specialTable[1][2] = myMaterials["item_herb_orange"]
        specialTable[2][2] = myMaterials["item_herb_purple"]
        specialTable[3][2] = myMaterials["item_herb_yellow"]
        specialTable[4][2] = myMaterials["item_herb_blue"]
    
    for key,val in pairs (specialTable) do
        print(val[1], val[2])
        if val[2] == nil then
            specialTable[key][2] = 0
        end
    end
    
    print("sort it!")            
    table.sort(specialTable, CompareHelper)
    
    for key,val in pairs (specialTable) do
        print(val[1], val[2])
    end
    
    --replace herb names with special_X
    myMaterials["special_1"] = specialTable[1][2]
    myMaterials[specialTable[1][1]] = nil
    myMaterials["special_2"] = specialTable[2][2]
    myMaterials[specialTable[2][1]] = nil
    myMaterials["special_3"] = specialTable[3][2]
    myMaterials[specialTable[3][1]] = nil
    myMaterials["special_4"] = specialTable[4][2]
    myMaterials[specialTable[4][1]] = nil
    
    for key,val in pairs (myMaterials) do
        if val == 0 then
            myMaterials[key] = nil
        end
    end
    
    print("Check for match")
    --check if player materials matches any recipes
    for i,value in pairs(recipeTable) do  --loop through the recipe table
        local recipeName = recipeTable[i][1]    --get the name of the recipe
        local recipeIngredients = recipeTable[i][2] --get the items needed for the recipe
        if CompareTables(recipeIngredients, myMaterials) then    --if a recipe matches
            print("Match!", i)
            local newItem = CreateItem(recipeName, nil, nil)   --create the resulting item
            for i,removeMe in pairs(itemTable) do   --delete the materials
                caster:RemoveItem(removeMe)
            end
            caster:AddItem(newItem) --add the new item
            return  --end the function, only one item per mix
        end
    end   
    
    Msg("Mix Failed")
    
end

--Compares two tables to see if they have the same values
function CompareTables(table1, table2)
    print("Comparing tables")
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end
    
    for key,value in pairs(table1) do
        print(key, table1[key], table2[key])
        if table2[key] == nil then
            return false
        elseif table2[key] ~= table1[key] then
            return false
        end
    end
    
    print("check other table, just in case")    

    for key,value in pairs(table2) do
        print(key, table2[key], table1[key])
        if table1[key] == nil then
            return false
        elseif table1[key] ~= table2[key] then
            return false
        end
    end
    
    print("Match!")
    return true
end

function CompareHelper(a,b)
    return a[2] > b[2]
end

function SwapAbilities(unit, ability1, ability2, enable1, enable2)
    
    --swaps ability1 and ability2, disables 1 and enables 2
    print("swap", ability1:GetName(), ability2:GetName() )
    unit:SwapAbilities(ability1:GetName(), ability2:GetName(), enable1, enable2)
    ability1:SetHidden(enable2)
    ability2:SetHidden(enable1)
end

function RadarManipulations(keys)
    local caster = keys.caster
    local isOpening = (keys.isOpening == "true")
    local ABILITY_radarManipulations = caster:FindAbilityByName("ability_gatherer_radarmanipulations")
    
    local abilityLevel = ABILITY_radarManipulations:GetLevel()
    print("abilityLevel", abilityLevel)
    local unitName = caster:GetUnitName()
    print(unitName)
    
    local tableDefaultSkillBook ={
        "ability_gatherer_itemradar",
        "ability_gatherer_radarmanipulations", 
        "ability_empty3", 
        "ability_empty4",  
        "ability_empty5", 
        "ability_empty6", 
        "ability_empty7"}
        
    local tableRadarBook ={
        "ability_gatherer_findmushroomstickortinder",
        "ability_gatherer_findhide",
        "ability_gatherer_findclayballcookedmeatorbone",
        "ability_gatherer_findmanacrystalorstone",
        "ability_gatherer_findflint",
        "ability_gatherer_findmagic"
    }

    local numAbilities = abilityLevel

    for i=1,numAbilities do
        print(tableDefaultSkillBook[i], tableRadarBook[i])
        local ability1 = caster:FindAbilityByName(tableDefaultSkillBook[i])
        local ability2 = caster:FindAbilityByName(tableRadarBook[i])
        if ability2:GetLevel() == 0 then
            ability2:SetLevel(1)
        end
        print("isopening",isOpening)
        if isOpening == true then
            print("ability1:", ability1:GetName(), "ability2:", ability2:GetName())
            SwapAbilities(caster, ability1, ability2, false, true)
            caster:FindAbilityByName("ability_gatherer_radarmanipulations"):SetHidden(true)
        else
            SwapAbilities(caster, ability1, ability2, true, false)
            caster:FindAbilityByName("ability_gatherer_radarmanipulations"):SetHidden(false)
            caster:FindAbilityByName("ability_empty3"):SetHidden(true)
            caster:FindAbilityByName("ability_empty4"):SetHidden(true)
            caster:FindAbilityByName("ability_empty5"):SetHidden(true)
            caster:FindAbilityByName("ability_empty6"):SetHidden(true)
        end
    end
end

function RadarTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target
    
    keys.caster.targetFire = target
    
end

function RadarTelegather (keys)
        local hero = EntIndexToHScript( keys.HeroEntityIndex )
        local hasTelegather = hero:HasModifier("modifier_telegather")
        local targetFire = hero.targetFire
        
        local originalItem = EntIndexToHScript(keys.ItemEntityIndex)
        local newItem = CreateItem(originalItem:GetName(), nil, nil)
        
        local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom"}
        for key,value in pairs(itemList) do
            if value == originalItem:GetName() then
                print( "Teleporting Item", originalItem:GetName())
                hero:RemoveItem(originalItem)
                CreateItemOnPositionSync(targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150)),newItem)
            end
        end
end
