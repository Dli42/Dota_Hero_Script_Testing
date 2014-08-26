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
    +
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
    local caster = keys.caster
    local target = keys.target
    local myString = keys.String
    local teamID = target:GetTeamID()
    local playerID = target:GetPlayerOwnerID()
    
    GameRules:SendCustomMessage(myString,teamID,playerID)    
end

