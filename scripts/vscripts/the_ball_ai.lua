function Spawn(entityKeyValues)
	thisEntity:SetContextThink("theballthink" .. thisEntity:GetEntityIndex(), theballthink, 0.05)
	thisEntity.state = "follow"		--possible states = follow, attack, protect, protectfollow, stay
	local owner = thisEntity:GetOwner()
	thisEntity.target = owner:GetOrigin()
	thisEntity.hitTable = {}
	--FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache)
	--find the nearest enemy in 200 range of the player controlling the skellies

	print("starting ball ai")

	thisEntity.spawnTime = GameRules:GetGameTime()
end

function theballthink()
	local owner = thisEntity:GetOwner()
	local target = thisEntity.target
	local protectTarget = thisEntity.protectTarget
	if protectTarget == nil then
		protectTarget = owner
	end
	local protectPosition = protectTarget:GetOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,90,0), owner:GetForwardVector()) * 50
	local followPosition = owner:GetOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,90,0), owner:GetForwardVector()) * 50
	
	if not thisEntity:IsAlive() then
		return nil
	end

	if (thisEntity.state == "follow") then
		thisEntity:MoveToPosition(followPosition)
    elseif (thisEntity.state == "attack") then
    	protectTarget:RemoveModifierByName("modifier_protect_shield")
    	if (thisEntity:GetOrigin() ~= target) then
    		thisEntity:MoveToPosition(target)

    		local enemiesInRange = FindUnitsInRadius(
	        thisEntity:GetTeam(),
	        thisEntity:GetOrigin(),
	        nil, 
	        175,
	        DOTA_UNIT_TARGET_TEAM_ENEMY,
	        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
	        DOTA_UNIT_TARGET_FLAG_NONE,
	        FIND_CLOSEST,
	        false)

			if #enemiesInRange > 0 then
	            for k,v in pairs(enemiesInRange) do
	            	if thisEntity.hitTable[v:GetEntityIndex()] == nil then
	            		print("hit!", v, v:GetEntityIndex())
	            		thisEntity.hitTable[v:GetEntityIndex()] = 1
	            		local damageTable = {
							victim = v,
							attacker = owner,
							damage = thisEntity.attackDamage,
							damage_type = DAMAGE_TYPE_MAGICAL}
											
						
						ApplyDamage(damageTable)
            		end
	            end
		    end
	    elseif (thisEntity:GetOrigin() == target) then
	    	thisEntity.state = "stay"
	    	print("attack -> stay")
	    	thisEntity.hitTable = {}
    	end
	elseif (thisEntity.state == "protect") then
		protectTarget:RemoveModifierByName("modifier_protect_shield")
		if (thisEntity:GetOrigin() ~= protectTarget:GetOrigin()) then
    		thisEntity:MoveToPosition(protectTarget:GetOrigin())

    		local enemiesInRange = FindUnitsInRadius(
	        thisEntity:GetTeam(),
	        thisEntity:GetOrigin(),
	        nil, 
	        175,
	        DOTA_UNIT_TARGET_TEAM_ENEMY,
	        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
	        DOTA_UNIT_TARGET_FLAG_NONE,
	        FIND_CLOSEST,
	        false)
			if #enemiesInRange > 0 then
	            for k,v in pairs(enemiesInRange) do
	            	if thisEntity.hitTable[v:GetEntityIndex()] == nil then
	            		print("hit!", v, v:GetEntityIndex())
	            		thisEntity.hitTable[v:GetEntityIndex()] = 1
	            		local damageTable = {
							victim = v,
							attacker = owner,
							damage = thisEntity.attackDamage,
							damage_type = DAMAGE_TYPE_MAGICAL}
											
						
						ApplyDamage(damageTable)
            		end
	            end
		    end
	    elseif (thisEntity:GetOrigin() == protectTarget:GetOrigin()) then
	    	thisEntity.state = "protectFollow"
	    	print("protect -> protectFollow")
	    	thisEntity.hitTable = {}
	    	--apply shield
	    	thisEntity.abilityProtect:ApplyDataDrivenModifier(owner, protectTarget, "modifier_protect_shield", {duration = -1})
    	end
	elseif (thisEntity.state == "protectFollow") then
		thisEntity:MoveToPosition(protectPosition)
		if ((owner:GetOrigin() - thisEntity:GetOrigin()):Length2D() > 1225) then
			thisEntity:SetOrigin(followPosition)
			thisEntity.state = "follow"
			print("protectFollow-> follow")
			protectTarget:RemoveModifierByName("modifier_protect_shield")
		end
	elseif (thisEntity.state == "stay") then
		if ((owner:GetOrigin() - thisEntity:GetOrigin()):Length2D() > 1125) then
			thisEntity:SetOrigin(followPosition)
			thisEntity.state = "follow"
			print("stay-> follow")
		end
		if ((owner:GetOrigin() - thisEntity:GetOrigin()):Length2D() < 100)  then
			thisEntity.state = "follow"
			print("stay-> follow")
		end
	end
	return 0.05
end