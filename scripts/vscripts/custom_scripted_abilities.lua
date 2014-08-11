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
    
end

--[[resets movespeed to original, can't go fast forever]]
function RammusPowerballResetMovespeed(keys)

    local caster = keys.caster  
    caster:SetBaseMoveSpeed(originalMoveSpeed)
	
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

