require ("Bandit.lua")

function Bandit.AddVisualDamage(bandit, handWeapon)
    
	--#	#	#	#	#	#	# DISALLOW GORE OPTION
	if not SandboxVars.Bandits_AddOptions.AllowGore then return true end
	
    if handWeapon then
        local itemVisual
        local weaponType = WeaponType.getWeaponType(handWeapon)
        if weaponType == WeaponType.firearm or weaponType == WeaponType.handgun then
            itemVisual = BanditUtils.Choice(Bandit.VisualDamage.Gun)
        else
            itemVisual = BanditUtils.Choice(Bandit.VisualDamage.Melee)
        end

        bandit:addVisualDamage(itemVisual)
    end
end

	--	#	#	#	#	#	#	WEAPON UNDUPLICATOR	/ WEAPON CONDITIONER
local function OnZombieDead(zombie)

    if zombie:isReanimatedPlayer() or not zombie:getVariableBoolean("Bandit") then return end
	
	local inv = zombie:getInventory()	
	local invItems = inv:getItems()
	local weaponsList = {}
	local toRemove = {}

	for i = 0, invItems:size() - 1 do
		local item = invItems:get(i)

		if item and item:getCategory() == "Weapon" and (item:getMaxDamage() > 0.15) then
			table.insert(weaponsList, item:getFullType())
--[[			if SandboxVars.Bandits_AddOptions.RandomWeaponCondition == 6 then --perfection
				item:setCondition(100)		
			elseif SandboxVars.Bandits_AddOptions.RandomWeaponCondition ~= 7 then --not vanilla	
				if item:getMagazineType() then	--is firearm
					if 	item:isRequiresEquippedBothHands() then
--						item:setCondition(1+ZombRand(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*5)+(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*10))	--rifle
						item:setCondition(10)		
						print ("rifle conditioner")
					else	
						item:setCondition(1+ZombRand(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*5)+(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*15))	--handgun						
						print ("pistol conditioner")
					end	
				else
					item:setCondition(1+ZombRand(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*5)+(SandboxVars.Bandits_AddOptions.RandomWeaponCondition*10))	--melee								
					print ("melee conditioner")		
				end
			end	--]]
		end
	end
	
	local hash = {}

	for k, v in ipairs(weaponsList) do
		print ("weaponslist " ..v)
		if hash[v] then
			toRemove[#toRemove+1] = v
			print ("add removetable " .. v)
		else
			hash[v] = true
		end
	end
		
    for k, v in pairs(toRemove) do
        for i=0, invItems:size()-1 do
			local item = invItems:get(i)
			if item then
				local name = item:getFullType() 
				if v == name then
					inv:Remove(item)
					inv:removeItemOnServer(item)
					print ("removeitem " .. v)
					break
				end
            end
        end
    end
end

Events.OnZombieDead.Add(OnZombieDead)