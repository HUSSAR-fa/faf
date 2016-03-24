local oldDamageArea = DamageArea

-- Trying to mimic DamageArea as good as possible, used for nukes to bypass the bubble damage absorbation of shields.
DamageArea = function(instigator, location, radius, damage, type, damageAllies, damageSelf, brain, army)
    local rect = Rect(location[1]-radius, location[3]-radius, location[1]+radius, location[3]+radius)
    local units = GetUnitsInRect(rect) or {}

    for _, u in units do
        if VDist3(u:GetPosition(), location) > radius then continue end
        if instigator == u then
            if damageSelf then
                local vector = import('/lua/utilities.lua').GetDirectionVector(location, u:GetPosition())
                -- need this ugliness due to Damage() refuse to damage when instigator == u
                instigator:OnDamage(instigator, damage, vector, type)
            end
        elseif damageAllies or not IsAlly(army, u:GetArmy()) then
            Damage(instigator, location, u, damage, type)
        end
    end
    
    local reclaim = GetReclaimablesInRect(location[1]-radius, location[3]-radius, location[1]+radius, location[1]+radius) or {}
    for _, r in reclaim do
        if IsProp(r) and VDist3(r:GetPosition(), location) <= radius then
            Damage(instigator, location, r, damage, type)
        end
    end

     -- Get rid of trees
     oldDamageArea(instigator, location, radius, 1, 'Force', false, false)
end
