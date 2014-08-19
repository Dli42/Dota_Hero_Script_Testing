function callModApplier( caster, modName, abilityLevel)
    if abilityLevel == nil then
        abilityLevel = ""
    else
        abilityLevel = "_" .. abilityLevel
    end
    local applier = modName .. abilityLevel .. "_applier"
    local ab = caster:FindAbilityByName(applier)
    if ab == nil then
        caster:AddAbility(applier)
        ab = caster:FindAbilityByName( applier )
        print("trying to cast ability ", applier)
    end
    caster:CastAbilityNoTarget(ab, -1)
    caster:RemoveAbility(applier)
end