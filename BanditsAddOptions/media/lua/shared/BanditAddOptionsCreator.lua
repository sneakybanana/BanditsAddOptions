require "BanditCreator"

function BanditCreator.MakeWeapons(wave, clan)
    local weapons = {}
	if not wave.loadout then
		if wave.hasRifleChance == 70 or wave.hasRifleChance == 100 then
			wave.loadout = "Military" -- for week one 
		--	print ("military loadout")
		else
			wave.loadout = ""
		--	print ("new loadout")
		end
	end	
	if not wave.specialWeapons then
	--	print ("new specialweapons")
		wave.specialWeapons = 6
	end

    -- fallback
    weapons.melee = "Base.Axe"

    -- set up primary weapon
    weapons.primary = {}
    weapons.primary.name = false
    weapons.primary.magSize = 0
    weapons.primary.bulletsLeft = 0
    weapons.primary.magCount = 0
    local rifleRandom = ZombRandFloat(0, 101)
    if rifleRandom < wave.hasRifleChance then
        local setAmmo = wave.rifleMagCount
		if BanditWeapons[wave.loadout .. "PrimarySpecial"] and BanditWeapons[wave.loadout .. "PrimarySpecial"][1] and ZombRand(wave.specialWeapons*3) == 1 and wave.specialWeapons ~= 6 then
		--	print (wave.loadout .. "Special")
			weapons.primary = BanditUtils.Choice(BanditWeapons[wave.loadout .. "PrimarySpecial"])
			setAmmo = 1
		elseif BanditWeapons[wave.loadout .. "Primary"] and BanditWeapons[wave.loadout .. "Primary"][1] then
		
		--	print (wave.loadout .. "Primary")
			weapons.primary = BanditUtils.Choice(BanditWeapons[wave.loadout .. "Primary"])
		else
		--	print ("actually Vanilla")
			weapons.primary = BanditUtils.Choice(clan.Primary)	
		end
		--	#	#	#	#	#	#	OPTION RANDOM AMMO insert
		if SandboxVars.Bandits_AddOptions.RandomAmmo then
			if wave.randomAmmo then		--we dont always have a value for this if its not from the table
				weapons.primary.magCount = ZombRand(setAmmo + 1)
				if weapons.primary.magCount < wave.randomAmmo then
					weapons.primary.magCount = wave.randomAmmo
				end
			else		--my source is I MADE IT UP
				weapons.primary.magCount = ZombRand(setAmmo / 2) + (setAmmo / 2)
			end
		--	print ("random ammo: " .. weapons.primary.magCount)
		else
			weapons.primary.magCount = setAmmo
		end
    end

    -- set up secondary weapon
    weapons.secondary = {}
    weapons.secondary.name = false
    weapons.secondary.magSize = 0
    weapons.secondary.bulletsLeft = 0
    weapons.secondary.magCount = 0
    local pistolRandom = ZombRandFloat(0, 101)
    if pistolRandom < wave.hasPistolChance then
		if BanditWeapons[wave.loadout .. "SecondarySpecial"] and BanditWeapons[wave.loadout .. "SecondarySpecial"][1] and ZombRand(wave.specialWeapons*3) == 1 and wave.specialWeapons ~= 6 then
		--	print (wave.loadout .. "SecondarySpecial (remove)")	-- for special secondary weapons, remove the primary - so that we use the correct animation for eg. SMG

			weapons.primary = {}
			weapons.primary.name = false
			weapons.primary.magSize = 0
			weapons.primary.bulletsLeft = 0
			weapons.primary.magCount = 0
			
			weapons.secondary = BanditUtils.Choice(BanditWeapons[wave.loadout .. "SecondarySpecial"])
		elseif BanditWeapons[wave.loadout .. "Secondary"] and BanditWeapons[wave.loadout .. "Secondary"][1] then
		--	print (wave.loadout .. "Secondary")
			weapons.secondary = BanditUtils.Choice(BanditWeapons[wave.loadout .. "Secondary"])
		else			
		--	print ("Vanilla secondary")
			weapons.secondary = BanditUtils.Choice(clan.Secondary)
		end
		--	#	#	#	#	#	#	OPTION RANDOM AMMO insert
		if SandboxVars.Bandits_AddOptions.RandomAmmo then
			if wave.randomAmmo then
				weapons.secondary.magCount = ZombRand(wave.pistolMagCount + 1)
				if weapons.secondary.magCount < wave.randomAmmo then
					weapons.secondary.magCount = wave.randomAmmo
				end
			else
				weapons.secondary.magCount = ZombRand(wave.pistolMagCount / 2) + (wave.pistolMagCount / 2)
			end	
		--print ("random sec ammo: " .. weapons.secondary.magCount)
		else
			weapons.secondary.magCount = wave.pistolMagCount
		end
    end

    return weapons			
end

function BanditCreator.MakeLoot(clanLoot)
    local loot = {}

    -- add loot from loot table				
	--	#	#	#	#	#	#	OPTION RANDOM LOOT insert
	if SandboxVars.Bandits_AddOptions.RandomLoot ~= 100 then
		for k, v in pairs(clanLoot) do
			local r = ZombRand(101)
			local rl = SandboxVars.Bandits_AddOptions.RandomLoot / 100
			local rv = nil
			rv = v.chance * rl
		--	print ("loot % " .. v.chance .. " rl " .. rl)
			if r <= rv then
				table.insert(loot, v.name)		
			end	
		end	
	else	
		for k, v in pairs(clanLoot) do
			local r = ZombRand(101)
			if r <= v.chance then
		--	print ("loot % " .. v.chance)
				table.insert(loot, v.name)			
			end
        end
    end

    -- add clan-independent, individual random personal character loot below
    
    -- smoker
    if not getActivatedMods():contains("Smoker") then
        if ZombRand(4) == 1 then
            for i=1, ZombRand(19) do
                table.insert(loot, "Base.CigaretteSingle")
            end
            table.insert(loot, "Base.Lighter")
        end
    end

    -- hotties collector
    if ZombRand(100) == 1 then
        for i=1, ZombRand(31) do
            table.insert(loot, "Base.HottieZ")
        end
    end

    -- perv
    if ZombRand(100) == 1 then
        for i=1, ZombRand(44) do
            local i = ZombRand(7)
            if i == 1 then
                table.insert(loot, "Base.Underpants_White")
            elseif i == 2 then
                table.insert(loot, "Base.Underpants_Black")
            elseif i == 3 then
                table.insert(loot, "Base.FrillyUnderpants_Black")
            elseif i == 4 then
                table.insert(loot, "Base.FrillyUnderpants_Pink")
            elseif i == 5 then
                table.insert(loot, "Base.FrillyUnderpants_Red")
            elseif i == 6 then
                table.insert(loot, "Base.Underpants_RedSpots")
            else
                table.insert(loot, "Base.Underpants_AnimalPrint")
            end
        end
    end

    -- ku chwale ojczyzny!
    if ZombRand(100) == 1 then
        for i=1, ZombRand(18) do
            table.insert(loot, "Base.Perogies")
        end
    end
    

    return loot
end

function BanditCreator.MakeFromWave(wave)
    local clan = BanditCreator.GroupMap[wave.clanId]

    local bandit = {}
    
    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
	--	#	#	#	#	#	#	OPTION RANDOM HEALTH insert
	if SandboxVars.Bandits_AddOptions.RandomHealth then
		if wave.randomHealthMax and wave.randomHealthMin then
			if wave.randomHealthMax <= wave.randomHealthMin then
				bandit.health = wave.randomHealthMin
			else
				bandit.health = ZombRand(wave.randomHealthMax - wave.randomHealthMin + 1) + wave.randomHealthMin
			end
		else
			bandit.health = ZombRand(clan.health + 2)
		end
	--	print ("min ".. wave.randomHealthMin.." max ".. wave.randomHealthMax.." random hp: " .. bandit.health)
	else
		bandit.health = clan.health
	end
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(wave, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- hairstyle 
    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end
    
    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    return bandit
end

function BanditCreator.MakeFromSpawnType(spawnData)
    local clan
    local config = {}

    -- clan detection based on building type
    if spawnData.buildingType == "medical" then
        clan = BanditClan.Scientist
        config.hasRifleChance = 0
        config.hasPistolChance = 50
        config.rifleMagCount = 0
        config.pistolMagCount = 3
    elseif spawnData.buildingType == "police" then
        clan = BanditClan.Police
        config.hasRifleChance = 20
        config.hasPistolChance = 50
        config.rifleMagCount = 2
        config.pistolMagCount = 4
    elseif spawnData.buildingType == "gunstore" then
        clan = BanditClan.DoomRider
        config.hasRifleChance = 100
        config.hasPistolChance = 100
        config.rifleMagCount = 6
        config.pistolMagCount = 4
    elseif spawnData.buildingType == "bank" then
        clan = BanditClan.Criminal
        config.hasRifleChance = 10
        config.hasPistolChance = 80
        config.rifleMagCount = 0
        config.pistolMagCount = 3
    elseif spawnData.buildingType == "church" then
        clan = BanditClan.Reclaimer
        config.hasRifleChance = 0
        config.hasPistolChance = 0
        config.rifleMagCount = 0
        config.pistolMagCount = 0
    else
        clan = BanditClan.DoomRider
        config.hasRifleChance = 5
        config.hasPistolChance = 25
        config.rifleMagCount = 0
        config.pistolMagCount = 2
    end

    local bandit = {}

    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
	--	#	#	#	#	#	#	OPTION RANDOM HEALTH insert - kludge to avoid pulling wavedata
	if SandboxVars.Bandits_AddOptions.RandomHealth then
		bandit.health = ZombRand(clan.health + 2)
	else
		bandit.health = clan.health
	end
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost
	
	--	#	#	#	#	#	#	OPTION RANDOM AMMO insert - kludge to avoid pulling wavedata
	config.randomAmmo	= 1

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(config, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- hairstyle 
    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end

    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    return bandit
end

