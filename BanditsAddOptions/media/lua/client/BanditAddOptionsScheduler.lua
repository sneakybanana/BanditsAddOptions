require "BanditScheduler"

local function getGroundType(square)
    local groundType = "generic"
    local objects = square:getObjects()
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        if object then
            local sprite = object:getSprite()
            if sprite then
                local spriteName = sprite:getName()
                if spriteName then
                    if spriteName:embodies("street") then
                        groundType = "street"
                    end
                end
            end
        end
    end
    return groundType
end

function BanditScheduler.GetWaveDataAll()
    local waveCnt = 16
    local waveData = {}
    for i=1, waveCnt do
        local wave = {}

        wave.enabled = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_WaveEnabled"]
        wave.friendlyChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_FriendlyChance"]
        wave.enemyBehaviour = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_EnemyBehaviour"]
        wave.firstDay = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_FirstDay"]
        wave.lastDay = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_LastDay"]
        wave.spawnDistance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_SpawnDistance"]
        wave.spawnHourlyChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_SpawnHourlyChance"]
        wave.groupSize = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupSize"]
        wave.clanId = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupName"]
        wave.hasPistolChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_HasPistolChance"]
        wave.pistolMagCount = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_PistolMagCount"]
        wave.hasRifleChance = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_HasRifleChance"]
        wave.rifleMagCount = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RifleMagCount"]
		-- #	#	#	#	#	#	#	OPTIONS NEW WAVE SETTINGS insert
        wave.randomAmmo = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RandomAmmo"]
        wave.randomLootPc = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RandomLootPc"]
        wave.randomHealthMin = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RandomHealthMin"]
        wave.randomHealthMax = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_RandomHealthMax"]
        wave.groupSizeMin = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupSizeMin"]
        wave.groupSizeMax = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_GroupSizeMax"]

        wave.loadout = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_Loadout"]
		if wave.loadout == 2 then 
			wave.loadout = "Civilian"
		elseif wave.loadout == 3 then 
			wave.loadout = "Police"
		elseif wave.loadout == 4 then 
			wave.loadout = "Military"
		elseif wave.loadout == 5 then 
			wave.loadout = "Exotic"
		elseif wave.loadout == 6 then 
			wave.loadout = "Looted"
		else 
			wave.loadout = "" 
		end

        wave.specialWeapons = SandboxVars.Bandits["Clan_" .. tostring(i) .. "_SpecialWeapons"]

        table.insert(waveData, wave)
    end
    return waveData
end

function BanditScheduler.GenerateSpawnPoint(player, d)
    local spawnPoints = {}
    local validSpawnPoints = {}
    local px = player:getX()
    local py = player:getY()
    
     -- Function to check if a point is within a basement region
    local function isInBasement(x, y, basement)
        return x >= basement.x and x < basement.x + basement.width and
               y >= basement.y and y < basement.y + basement.height
    end

    local function isTooCloseToPlayer(x, y)
        -- Check if the player is in debug mode or admin mode
        if isDebugEnabled() or isAdmin() then
            return false
        end

        local playerList = BanditPlayer.GetPlayers()
        for i=0, playerList:size()-1 do
            local player = playerList:get(i)
            if player and not BanditPlayer.IsGhost(player) then
                local dist = BanditUtils.DistTo(x, y, player:getX(), player:getY())
                if dist < 30 then
                    return true
                end
            end
        end
        return false
    end
	
		--	#	#	#	#	#	#	OPTION BASE SPAWN RESTRICTION
    local function isTooCloseToBase(x, y)
		for baseId, base in pairs(BanditPlayerBase.data) do
			local dist = BanditUtils.DistTo(base.x, base.y, x, y)
			--print ("baseID " .. baseId .. " dist " .. dist)
			if dist > 150 then 
			--	print ("baseID " .. baseId .. " too far " .. dist)
			else
				local dist2 = BanditUtils.DistTo(base.x2, base.y2, x, y)
				local dist3 = BanditUtils.DistTo(base.x, base.y2, x, y)
				local dist4 = BanditUtils.DistTo(base.x2, base.y, x, y)
			--	print ("baseID " .. baseId .. " dist2 " .. dist2)
			--	print ("baseID " .. baseId .. " dist3 " .. dist3)
			--	print ("baseID " .. baseId .. " dist4 " .. dist4)
				if dist < SandboxVars.Bandits_AddOptions.BaseSpawnRadius or dist2 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius 
					or dist3 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius or dist4 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius then
					return true
				end
			end
		end	
        return false
	end

    -- Check if BasementAPI exists before using it
    if BasementAPI then
        -- Get the list of basements
        local basements = BasementAPI.GetBasements()

        -- Check if the player is inside any basement region
        for _, basement in ipairs(basements) do
            if isInBasement(px, py, basement) then
                print("[INFO] Player is inside a basement region. Wave will not be spawned.")
                return
            end
        end
    end

    -- Check if RVInterior exists before using it
    if RVInterior then
        if RVInterior.playerInsideInterior(player) then
            print("[INFO] Player is inside an RV interior. Wave will not be spawned.")
            return
        end
    end

    table.insert(spawnPoints, {x=px+d, y=py+d})
    table.insert(spawnPoints, {x=px+d, y=py-d})
    table.insert(spawnPoints, {x=px-d, y=py+d})
    table.insert(spawnPoints, {x=px-d, y=py-d})
    table.insert(spawnPoints, {x=px+d, y=py})
    table.insert(spawnPoints, {x=px-d, y=py})
    table.insert(spawnPoints, {x=px, y=py+d})
    table.insert(spawnPoints, {x=px, y=py-d})

    local cell = player:getCell()
    for i, sp in pairs(spawnPoints) do
        local square = cell:getGridSquare(sp.x, sp.y, 0)
        if square then
            if SafeHouse.isSafeHouse(square, nil, true) then
                print("[INFO] Spawn point is inside a safehouse, skipping.")
            elseif not square:isFree(false) then
                print("[INFO] Square is occupied, skipping.")
            elseif isTooCloseToPlayer(sp.x, sp.y) then
                print("[INFO] Spawn is too close to one of the players, skipping.")
		--	#	#	#	#	#	#	OPTION BASE SPAWN RESTRICTION
            elseif SandboxVars.Bandits_AddOptions.BaseSpawnRadius > 0 then
				if isTooCloseToBase(sp.x, sp.y) then
					print("[INFO] Spawn is too close to player base, skipping.")
				else
					sp.groundType = getGroundType(square)
					table.insert(validSpawnPoints, sp)
				end
            else
                sp.groundType = getGroundType(square)
                table.insert(validSpawnPoints, sp)
            end
        end
    end

    if #validSpawnPoints >= 1 then
        local p = 1 + ZombRand(#validSpawnPoints)
        return validSpawnPoints[p]
    else
        print ("[ERR] No valid spawn points available. Wave will not be spawned.")
    end

    return false
end

function BanditScheduler.SpawnWave(player, wave)
    local event = {}
    event.occured = false
    event.program = {}

    event.hostile = true
	
		-- #	#	#	#	#	#	#	OPTION DISABLE RAIDERS insert
    if wave.enemyBehaviour == 1 and SandboxVars.Bandits_AddOptions.AllowRaiders then
        event.program.name = BanditUtils.Choice({"Bandit", "Looter", "BaseGuard", "Thief"})
    elseif wave.enemyBehaviour == 1 then
        event.program.name = BanditUtils.Choice({"Looter", "BaseGuard", "Thief"})
		print ("Raiders not allowed 1")
	elseif wave.enemyBehaviour == 2 and SandboxVars.Bandits_AddOptions.AllowRaiders then
		event.program.name = "Bandit"        
	elseif wave.enemyBehaviour == 2 then
		print ("Raiders not allowed 2")
		event.program.name = "Looter"
    elseif wave.enemyBehaviour == 3 then
        event.program.name = "Looter"
    elseif wave.enemyBehaviour == 4 then
        event.program.name = "BaseGuard"
    elseif wave.enemyBehaviour == 5 then
        event.program.name = "Thief"
    elseif wave.enemyBehaviour == 6 then
        event.program.name = BanditUtils.Choice({"Looter", "BaseGuard", "Thief"})        
    elseif wave.enemyBehaviour == 7 then
        event.program.name = "Looter"
        event.hostile = false
    elseif wave.enemyBehaviour == 8 then
        event.program.name = "Companion"
        event.hostile = false
    elseif wave.enemyBehaviour == 9 then
        event.program.name = BanditUtils.Choice({"Looter", "Companion"})
        event.hostile = false
    elseif wave.enemyBehaviour == 10 and SandboxVars.Bandits_AddOptions.AllowRaiders then
        if ZombRand(2) == 0 then
            event.program.name = BanditUtils.Choice({"Bandit", "Looter", "BaseGuard", "Thief"})
        else
            event.program.name = BanditUtils.Choice({"Looter", "Companion"})
            event.hostile = false
        end    
	elseif wave.enemyBehaviour == 10 then
        if ZombRand(2) == 0 then
            event.program.name = BanditUtils.Choice({"Looter", "BaseGuard", "Thief"})
			print ("Raiders not allowed 2")
        else
            event.program.name = BanditUtils.Choice({"Looter", "Companion"})
            event.hostile = false
        end
    end

    if event.program.name == "Thief" then
        event.hostile = false -- pseudo-friendly
    end

    event.program.stage = "Prepare"
    event.bandits = {}
    
    local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, wave.spawnDistance)
    if spawnPoint then

		-- #	#	#	#	#	#	#	OPTION RANDOM GROUP SIZE insert
		local groupSizeActual = 1
		if SandboxVars.Bandits_AddOptions.RandomGroupSize then
			if wave.groupSizeMax and wave.groupSizeMin then
				if wave.groupSizeMax <= wave.groupSizeMin then
					groupSizeActual = wave.groupSizeMax
				else	
					groupSizeActual = ZombRand(wave.groupSizeMax - wave.groupSizeMin + 1) + wave.groupSizeMin
				end
			else
				groupSizeActual = ZombRand(wave.groupSize / 2) + (wave.groupSize / 2)
			end
		else
			groupSizeActual = wave.groupSize
		end

        for i=1, groupSizeActual do
            local bandit = BanditCreator.MakeFromWave(wave)
            table.insert(event.bandits, bandit)
        end
    
        if #event.bandits > 0 then
            print ("[INFO] Spawning a bandit group against player id: " .. BanditUtils.GetCharacterID(player))
            event.x = spawnPoint.x
            event.y = spawnPoint.y

            local arrivalSoundVolume = SandboxVars.Bandits.General_ArrivalSoundLevel or 0.4
            if arrivalSoundVolume > 0 then

                local arrivalSound
                local arrivalSoundX
                local arrivalSoundY

				-- #	#	#	#	#	#	#	OPTION DISABLE VEHICLE INSERTION SOUNDS insert
                if wave.groupSize >= 10 and SandboxVars.Bandits_AddOptions.VehicleInsertionFX then
                    arrivalSound = "ZSAttack_Chopper_1"
                elseif wave.groupSize >= 6 and SandboxVars.Bandits_AddOptions.VehicleInsertionFX then
                    arrivalSound = "ZSAttack_Big_" .. tostring(1 + ZombRand(2))
                elseif wave.groupSize >= 4 then
                    arrivalSound = "ZSAttack_Medium_" .. tostring(1 + ZombRand(5))
                else
                    arrivalSound = "ZSAttack_Small_" .. tostring(1 + ZombRand(21))
                end
                
                if event.x < getPlayer():getX() then 
                    arrivalSoundX = getPlayer():getX() - 30
                else
                    arrivalSoundX = getPlayer():getX() + 30
                end
            
                if event.y < getPlayer():getY() then 
                    arrivalSoundY = getPlayer():getY() - 30
                else
                    arrivalSoundY = getPlayer():getY() + 30
                end

                local emitter = getWorld():getFreeEmitter(arrivalSoundX, arrivalSoundY, 0)
                
                emitter:setVolumeAll(arrivalSoundVolume)
                emitter:playSound(arrivalSound)
            end

            if SandboxVars.Bandits.General_ArrivalWakeUp and event.hostile and event.program.name == "Bandit" then
                BanditPlayer.WakeEveryone()
            end
            -- player:Say("Bandits are coming!")

            if SandboxVars.Bandits.General_ArrivaPanic and event.hostile and event.program.name == "Bandit" then
                local stats = player:getStats()
                stats:setPanic(80)
            end

            -- road block spawn
			--	#	#	#	#	#	#	#	OPTION SANDBAG ROADBLOCK insert
			if SandboxVars.Bandits_AddOptions.AllowRoadblockSandbags then
				if event.hostile and spawnPoint.groundType == "street" and ZombRand(5) < 1 then
					-- check space
					local allfree = true
					for x=spawnPoint.x-4, spawnPoint.x+4 do
						for y=spawnPoint.y-4, spawnPoint.y+4 do
							local testSquare = getCell():getGridSquare(x, y, 0)
							if testSquare then
								if not testSquare:isFree(false) then allfree = false end
								
								local testVeh = testSquare:getVehicleContainer()
								if testVeh then allfree = false end
							else
								allfree = false
							end
						end
					end
					
					if allfree then
						event.program.name = "BaseGuard"

						local xcnt = 0
						for x=spawnPoint.x-20, spawnPoint.x+20 do
							local square = getCell():getGridSquare(x, spawnPoint.y, 0)
							if square then
								local gt = getGroundType(square)
								if gt == "street" then xcnt = xcnt + 1 end
							end
						end

						local ycnt = 0
						for y=spawnPoint.y-20, spawnPoint.y+20 do
							local square = getCell():getGridSquare(spawnPoint.x, y, 0)
							if square then
								local gt = getGroundType(square)
								if gt == "street" then ycnt = ycnt + 1 end
							end
						end

						local xm = 0
						local ym = 0
						local sprite
						if xcnt > ycnt then 
							-- ywide
							ym = 1
							sprite = "carpentry_02_12"
						else
							-- xwide
							xm = 1
							sprite = "carpentry_02_13"
						end

						for b=-2, 3, 1 do
							BanditBasePlacements.IsoObject(sprite, spawnPoint.x + xm * b, spawnPoint.y + ym * b , 0)
						end
					end	
                end
            elseif SandboxVars.Bandits.General_BuildRoadblock then
                local vehicleCount = player:getCell():getVehicles():size()
                if event.hostile and spawnPoint.groundType == "street" and vehicleCount < 7 then

                    -- check space
                    local allfree = true
                    for x=spawnPoint.x-4, spawnPoint.x+4 do
                        for y=spawnPoint.y-4, spawnPoint.y+4 do
                            local testSquare = getCell():getGridSquare(x, y, 0)
                            if testSquare then
                                if not testSquare:isFree(false) then allfree = false end
                                
                                local testVeh = testSquare:getVehicleContainer()
                                if testVeh then allfree = false end
                            else
                                allfree = false
                            end
                        end
                    end
                    
                    if allfree then
                        event.program.name = "BaseGuard"

                        local xcnt = 0
                        for x=spawnPoint.x-20, spawnPoint.x+20 do
                            local square = getCell():getGridSquare(x, spawnPoint.y, 0)
                            if square then
                                local gt = getGroundType(square)
                                if gt == "street" then xcnt = xcnt + 1 end
                            end
                        end

                        local ycnt = 0
                        for y=spawnPoint.y-20, spawnPoint.y+20 do
                            local square = getCell():getGridSquare(spawnPoint.x, y, 0)
                            if square then
                                local gt = getGroundType(square)
                                if gt == "street" then ycnt = ycnt + 1 end
                            end
                        end

                        local xm = 0
                        local ym = 0
                        local sprite
                        if xcnt > ycnt then 
                            -- ywide
                            ym = 1
                            sprite = "construction_01_9"
                        else
                            -- xwide
                            xm = 1
                            sprite = "construction_01_8"
                        end

                        local carOpts = {"Base.PickUpTruck", "Base.PickUpVan", "Base.VanSeats"}
                        local args = {type=BanditUtils.Choice(carOpts), x=spawnPoint.x-ym*3, y=spawnPoint.y-xm*3, engine=true, lights=true, lightbar=true}
                        sendClientCommand(player, 'Commands', 'VehicleSpawn', args)
                        
                        for b=-4, 4, 2 do
                            BanditBasePlacements.IsoObject(sprite, spawnPoint.x + xm * b, spawnPoint.y + ym * b, 0)
                        end
                    end
                end
            end


            -- spawn now
            sendClientCommand(player, 'Commands', 'SpawnGroup', event)
            if SandboxVars.Bandits.General_ArrivalIcon then
                local color
                local icon
				local desc
                if event.program.name == "Bandit" then 
                    icon = "media/ui/raid.png"
                    color = {r=1, g=0.5, b=0.5} -- red
                    desc = "Hostile Raiders"
                elseif event.program.name == "BaseGuard" then
                    icon = "media/ui/raid.png"
                    color = {r=1, g=0.5, b=0.5} -- red
                    desc = "Hostile Guards"
                elseif event.program.name == "Thief" then
                    icon = "media/ui/thief.png"
                    color = {r=1, g=1, b=0.5} -- yellow
                    desc = "Hostile Thiefs"
                elseif event.program.name == "Companion" then
                    icon = "media/ui/friend.png"
                    color = {r=0.5, g=1, b=0.5} -- green
                    desc = "Friendly Companions"
                elseif event.program.name == "Looter" then
                    icon = "media/ui/loot.png"
                    if event.hostile then
                        color = {r=1, g=0, b=0} -- red
                        desc = "Hostile Wanderers"
                    else
                        color = {r=0.5, g=1, b=0.5} -- green
                        desc = "Friendly Wanderers"
                    end
                end

                BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), icon, 10, event.x, event.y, color, desc)
            end
        end
    end  
end

function BanditScheduler.RaiseDefences(x, y)
    local cell = getCell()
    local square = cell:getGridSquare(x, y, 0)
    if not square then return end

    local building = square:getBuilding()
    
    if building then
        local buildingDef = building:getDef()
        if buildingDef then
            local x = buildingDef:getX()
            local y = buildingDef:getY()
            local w = buildingDef:getX2() - buildingDef:getX()
            local h = buildingDef:getY2() - buildingDef:getY()

            BanditBaseGroupPlacements.Junk(x, y, 0, w, h, 3)
            if ZombRand(5) == 0 then    
                BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.WineOpen"), x, y, 0, w, h, 2)
                BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.BeerCanEmpty"), x, y, 0, w, h, 2)
                BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.ToiletPaper"), x, y, 0, w, h, 1)
                BanditBaseGroupPlacements.Item(BanditCompatibility.GetLegacyItem("Base.TinCanEmpty"), x, y, 0, w, h, 2)
            end

			-- #	#	#	#	#	#	#	OPTION GENERATOR SETTINGS insert
			local buildingPowered = nil
			if SandboxVars.Bandits_AddOptions.GeneratorSettings ~= 5 then
				local genSquare = cell:getGridSquare(buildingDef:getX()-1, buildingDef:getY()-1, 0)
				if genSquare then
					if genSquare:haveElectricity() or getWorld():isHydroPowerOn() then
						buildingPowered = true
					end
					local generator = genSquare:getGenerator()
					if generator then
						print ("already generator")
						if not generator:isActivated() then
							generator:setCondition(99)
							generator:setFuel(80 + ZombRand(20))
							generator:setActivated(true)
						end
					elseif SandboxVars.Bandits_AddOptions.GeneratorSettings ~= 1 and buildingPowered then
						print ("already powered, do nothing")
					elseif SandboxVars.Bandits_AddOptions.GeneratorSettings == 3 and ZombRand(100) < 60	then --sometimes (40%)
						print ("fail random chance")
					elseif SandboxVars.Bandits_AddOptions.GeneratorSettings == 4 and ZombRand(100) < 80	then --rarely (20%)
						print ("fail random chance")
					else	-- success condition
						print ("new generator")
						-- local genItem = InventoryItemFactory.CreateItem("Base.Generator")
						local genRand = ZombRand(100)
						local genItem = nil
						if genRand > 90 then
							genItem = instanceItem("Base.Generator_Yellow")
						elseif genRand > 60 then
							genItem = instanceItem("Base.Generator_Blue")
						elseif genRand > 30 then
							genItem = instanceItem("Base.Generator_Old")
						else
							genItem = instanceItem("Base.Generator")
						end
						local obj = IsoGenerator.new(genItem, cell, genSquare)
						obj:setConnected(true)
						obj:setFuel(30 + ZombRand(60))
						obj:setCondition(99)
						obj:setActivated(true)
						buildingPowered = true
					end
                end
            end

            local maxc = 5
            local c = 0
            for z = 0, 7 do
                for y = buildingDef:getY()-1, buildingDef:getY2()+1 do
                    for x = buildingDef:getX()-1, buildingDef:getX2()+1 do
                        local square = cell:getGridSquare(x, y, z)
                        if square then
                            local objects = square:getObjects()
                            for i=0, objects:size()-1 do
                                local object = objects:get(i)
                                if object then
									-- #	#	#	#	#	GENERATOR SETTINGS	don't mess with lights and curtains if no power
                                    if instanceof(object, "IsoLightSwitch") and buildingPowered then
                                        local lightList = object:getLights()
                                        if lightList:size() == 0 then
                                            object:setActive(false)
                                        elseif buildingPowered then
                                            object:setBulbItemRaw("Base.LightBulbRed")
                                            object:setPrimaryR(1)
                                            object:setPrimaryG(0)
                                            object:setPrimaryB(0)
                                            object:setActive(true)
                                        end
                                    end
                                    if instanceof(object, "IsoCurtain") and buildingPowered then
                                        if object:IsOpen() then
                                            object:ToggleDoorSilent()
                                        end
                                    end
						
									-- #	#	#	#	#	BARRICADE RANDOMISER	less barricade if no power
                                    if z == 0 and SandboxVars.Bandits_AddOptions.RandomBarricades then			
                                        if instanceof(object, "IsoWindow") then
											local barricadeRand = ZombRand(100)
											print ("try to barricade " ..barricadeRand)
											if barricadeRand > 95 then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), isMetalBars=true, condition=5000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											elseif barricadeRand > 75 then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), isMetal=true, condition=5000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											elseif barricadeRand > 60 and buildingPowered then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), condition=1000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											elseif barricadeRand > 50 and buildingPowered then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), condition=1000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											elseif barricadeRand > 20 then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), condition=1000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											elseif barricadeRand > 10 then
												local args = {x=x, y=y, z=z, index=object:getObjectIndex(), condition=1000}
												sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
											end
                                        end
									elseif z == 0 then
										if instanceof(object, "IsoWindow") then
                                            local args = {x=x, y=y, z=z, index=object:getObjectIndex(), isMetal=true, condition=5000}
                                            -- tempPlayer:setPerkLevelDebug(Perks.Woodwork, 10)
                                            sendClientCommand(getPlayer(), 'Commands', 'Barricade', args)
                                        end
                                    end

                                    local lootAmount = SandboxVars.Bandits.General_DefenderLootAmount - 1
                                    local roomCnt = building:getRoomsNumber()
                                    if lootAmount > 0 and roomCnt > 2 and c < maxc then
                                        local fridge = object:getContainerByType("fridge")
                                        if fridge then
                                            BanditLoot.FillContainer(fridge, BanditLoot.FreshFoodItems, lootAmount)
                                            c = c + 1
                                        end

                                        local freezer = object:getContainerByType("freezer")
                                        if freezer then
                                            BanditLoot.FillContainer(freezer, BanditLoot.FreshFoodItems, lootAmount)
                                            c = c + 1
                                        end

                                        if ZombRand(10) == 1 then
                                            local counter = object:getContainerByType("counter")
                                            if counter then
                                                BanditLoot.FillContainer(counter, BanditLoot.CannedFoodItems, lootAmount)
                                                c = c + 1
                                            end

                                            local crate = object:getContainerByType("crate")
                                            if crate then
                                                BanditLoot.FillContainer(crate, BanditLoot.CannedFoodItems, lootAmount)
                                                c = c + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function BanditScheduler.GenerateSpawnPointsInRandomBuilding(character, min, max)
    local cell = character:getCell()
    local px = character:getX()
    local py = character:getY()
    local ret = {}

    -- checks if there building is valid for a the spawn
    local function checkBuilding(building)

        -- avoid safehouses
        local buildingDef = building:getDef()
        for x=buildingDef:getX(), buildingDef:getX2() do
            for y=buildingDef:getY(), buildingDef:getY2() do
                local square = cell:getGridSquare(x, y, 0)
                if square and SafeHouse.isSafeHouse(square, nil, true) then
                    print ("[INFO] Defenders are not allowed to spawn in a safehouse.")
                    return false
                end
            end
        end
		
    		--	#	#	#	#	#	#	OPTION BASE SPAWN RESTRICTION		
		if SandboxVars.Bandits_AddOptions.BaseSpawnRadius then
			local baseId, base = BanditPlayerBase.GetBaseClosest(buildingDef)
			if not base or not baseId then return true end
			local x=buildingDef:getX()
			local y=buildingDef:getY()
			local dist = BanditUtils.DistTo(base.x, base.y, x, y)
			print (" dist " .. dist)
			if dist > 150 then 
				print (" too far " .. dist)
			else
				local x2=buildingDef:getX2()
				local y2=buildingDef:getY2()
				local dist2 = BanditUtils.DistTo(base.x2, base.y2, x2, y2)
				local dist3 = BanditUtils.DistTo(base.x, base.y2, x, y2)
				local dist4 = BanditUtils.DistTo(base.x2, base.y, x2, y)
				print (" dist2 " .. dist2)
				print (" dist3 " .. dist3)
				print (" dist4 " .. dist4)
				if dist < SandboxVars.Bandits_AddOptions.BaseSpawnRadius or dist2 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius 
					or dist3 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius or dist4 < SandboxVars.Bandits_AddOptions.BaseSpawnRadius then
					print ("[INFO] Defenders are not allowed to spawn near a player base.")
					return false
				end
			end
		end  	
		
        -- avoid recently visited buildings
        local bid = BanditUtils.GetBuildingID(buildingDef)
        local gmd = GetBanditModData()
        if gmd.VisitedBuildings and gmd.VisitedBuildings[bid] then
            local now = getGameTime():getWorldAgeHours() --  8
            local lastVisit = gmd.VisitedBuildings[bid] -- 1			
			-- #	#	#	#	#	#	#	OPTION DEFENDER COOLDOWN insert	
            local coolDown = SandboxVars.Bandits_AddOptions.DefenderCooldown * 24
            if now - coolDown < lastVisit then
                print ("[INFO] Defenders are not allowed to spawn " ..now - coolDown.. " < " ..lastVisit.. " hours.")
                return false
            end
        end

        return true
    end

    -- based on the room types establish general type of the building
    local function getBuildingType(building)
        local btype
        if building:containsRoom("medclinic") or building:containsRoom("medicalstorage") then
            btype = "medical"
        elseif building:containsRoom("policestore") or building:containsRoom("policestorage") or building:containsRoom("cell") then
            btype = "police"
        elseif building:containsRoom("gunstore") then
            btype = "gunstore"
        elseif building:containsRoom("bank") then
            btype = "bank"
        elseif building:containsRoom("warehouse") then
            btype = "warehouse"
        elseif building:containsRoom("grocery") or building:containsRoom("grocerystore") or building:containsRoom("clothingstore") or building:containsRoom("conveniencestore") or building:containsRoom("liquorstore") then
            btype = "store"
        elseif building:containsRoom("motelroom") then
            btype = "motel"
        elseif building:containsRoom("gasstore") then
            btype = "gasstore"
        elseif building:containsRoom("spiffo_dining") then
            btype = "spiffo"
        elseif building:containsRoom("church") then
            btype = "church"
        else
            btype = "unknown"
        end
        return btype
    end

    local function getRoomSize(roomDef)
        local roomSize = (roomDef:getX2() - roomDef:getX()) * (roomDef:getY2() - roomDef:getY())
        return roomSize
    end

    -- iterates over rooms in a building and finds free squares
    -- that will be available for the spawn
    local function getSpawnPoints(buildingDef)
        local spawnPoints = {}

        -- getRooms actually returns roomDefs
        local roomDefList = buildingDef:getRooms()
        for i=0, roomDefList:size()-1 do
            local roomDef = roomDefList:get(i)
            local square = roomDef:getFreeSquare()

            -- double-checking, and roomsize must be > 1 otherwise they spawn in columns of the buildings :)
            if square and square:isFree(false) and getRoomSize(roomDef) > 1 then
                table.insert(spawnPoints, {x=square:getX(), y=square:getY(), z=square:getZ()})
            end
        end
        return spawnPoints
    end

    -- get center x, y of a building
    local function getCenterCoords(buildingDef)
        local coords = {}
        local x = math.floor((buildingDef:getX() + buildingDef:getX2()) / 2)
        local y = math.floor((buildingDef:getY() + buildingDef:getY2()) / 2)
        coords = {x=x, y=y}
        return coords
    end

    local function getNearbyBuildings(character, min, max)
        -- Get the character's current cell
        local cell = character:getCell()  

        -- Get the character's current position
        local chrX = character:getX()
        local chrY = character:getY()
        
        -- Get the list of all rooms in the character's current cell
        local rooms = cell:getRoomList()
        local buildings = {}

        -- Iterate through the rooms and construct our own list of buildings
        for i = 0, rooms:size() - 1 do
            local room = rooms:get(i)  -- Get the room at the current index
            local building = room:getBuilding()
            if building then
                local buildingDef = building:getDef()
                local buildingKey = buildingDef:getKeyId()
                
                -- Calculate the distance between the character and the building
                local coords = getCenterCoords(buildingDef)
                local distance = math.sqrt((coords.x - chrX)^2 + (coords.y - chrY)^2)

                -- Buildings stay in memory even after exiting the cell, so we need to check if the building is within a set distance
                if distance >= min and distance <= max then
                    if not buildings[buildingKey] then
                        buildings[buildingKey] = building
                    end
                end
            end
        end

        return buildings
    end

    -- get building candidates for the spawn
    local buildings = getNearbyBuildings(character, min, max)

    -- shuffle (Fisher-Yates)
    for i = #buildings, 2, -1 do
        local j = ZombRand(i) + 1
        buildings[i], buildings[j] = buildings[j], buildings[i]
    end

    -- choose first good building
    for _, building in pairs(buildings) do
        local valid = checkBuilding(building)
        if valid then
            local buildingDef = building:getDef()
            ret.buildingCoords = {x = buildingDef:getX(), y = buildingDef:getY()}
            ret.buildingCenterCoords = getCenterCoords(buildingDef)
            ret.spawnPoints = getSpawnPoints(buildingDef)
            ret.buildingType = getBuildingType(building)
            break
        end
    end

    return ret
end

function BanditScheduler.GetSpawnZoneBoost(player, clanId)
	-- #	#	#	#	#	#	#	OPTION ZONEBOOST insert	
    local zoneBoost = 1
    local clan = BanditCreator.GroupMap[clanId]
    local zone = getWorld():getMetaGrid():getZoneAt(player:getX(), player:getY(), 0)

    if zone and clan then
        local zoneType = zone:getType()
        if clan.favoriteZones then
            for _, zt in pairs(clan.favoriteZones) do
                if zt == zoneType then
                    zoneBoost = 1.4
                    break
                end
            end
        end
        if clan.avoidZones then
            for _, zt in pairs(clan.avoidZones) do
                if zt == zoneType then
                    zoneBoost = SandboxVars.Bandits_AddOptions.ZoneBoost / 100
                    break
                end
            end
        end
    end
    return zoneBoost
end

function BanditScheduler.CheckEvent()
    if isServer() then return end

    local world = getWorld()
    local gamemode = world:getGameMode()
    local currentPlayer = getPlayer()
    local onlinePlayer 

    if gamemode == "Multiplayer" then
        local playerList = getOnlinePlayers()
        local pid = ZombRand(playerList:size())
        onlinePlayer = playerList:get(pid)
    else
        onlinePlayer = getPlayer()
    end

    if BanditUtils.GetCharacterID(currentPlayer) == BanditUtils.GetCharacterID(onlinePlayer) then

        -- SPAWN ATTACKING FORCE
		-- #	#	#	#	#	#	#	OPTION PERSISTENT TIME insert		
		if SandboxVars.Bandits_AddOptions.TimePersists then
			local daysPassed = BanditScheduler.DaysSinceApo()
			print ("Persistent time")
		else
			local daysPassed = currentPlayer:getHoursSurvived() / 24
		end
        local waveData = BanditScheduler.GetWaveDataForDay(daysPassed)

        local densityScore = 1
        if SandboxVars.Bandits.General_DensityScore then
           densityScore = BanditScheduler.GetDensityScore(currentPlayer, 120)
        end

        for _, wave in pairs(waveData) do
            local spawnZoneBoost = BanditScheduler.GetSpawnZoneBoost(currentPlayer, wave.clanId)		
			-- #	#	#	#	#	#	#	OPTION SPAWN MULTIPLIER insert		
            local spawnChance = wave.spawnHourlyChance * spawnZoneBoost * densityScore / 6 * (SandboxVars.Bandits_AddOptions.SpawnMultiplier / 100)
            local spawnRandom = ZombRandFloat(0, 101)
            if spawnRandom < spawnChance then
                BanditScheduler.SpawnWave(currentPlayer, wave)
            end
        end

        -- SPAWN DEFENDERS
        local spawnRandom = ZombRandFloat(0, 101)
        local spawnChance = SandboxVars.Bandits.General_DefenderSpawnHourlyChanced or 8	
			-- #	#	#	#	#	#	#	OPTION SPAWN MULTIPLIER insert		
        if spawnRandom < spawnChance / 6 * (SandboxVars.Bandits_AddOptions.SpawnMultiplier / 100) then
            BanditScheduler.SpawnDefenders(currentPlayer, 55, 100)
        end

        -- SPAWN BASES
        local spawnRandom = ZombRandFloat(0, 101)
        local spawnChance = SandboxVars.Bandits.General_BaseSpawnHourlyChance or 0.3	
			-- #	#	#	#	#	#	#	OPTION SPAWN MULTIPLIER insert		
        if spawnRandom < spawnChance / 6 * (SandboxVars.Bandits_AddOptions.SpawnMultiplier / 100) then
            local sceneNo = 1 + ZombRand(#BanditBaseScenes)
            BanditScheduler.SpawnBase(currentPlayer, sceneNo)
        end
    end
end