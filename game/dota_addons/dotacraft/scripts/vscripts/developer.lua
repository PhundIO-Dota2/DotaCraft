CHEAT_CODES = {
    ["warpten"] = function(...) dotacraft:WarpTen(...) end,                  -- "Speeds construction of buildings and units"
    ["greedisgood"] = function(...) dotacraft:GreedIsGood(...) end,          -- "Gives you X gold and lumber" 
    ["whosyourdaddy"] = function(...) dotacraft:WhosYourDaddy(...) end,      -- "God Mode"    
    ["thereisnospoon"] = function(...) dotacraft:ThereIsNoSpoon(...) end,    -- "Unlimited Mana"      
    ["iseedeadpeople"] = function(...) dotacraft:ISeeDeadPeople(...) end,    -- "Remove fog of war"       
    ["pointbreak"] = function(...) dotacraft:PointBreak(...) end,            -- "Sets food limit to 1000" 
    ["synergy"] = function(...) dotacraft:Synergy(...) end,                  -- "Disable tech tree requirements"
    ["riseandshine"] = function(...) dotacraft:RiseAndShine(...) end,        -- "Set time of day to dawn" 
    ["lightsout"] = function(...) dotacraft:LightsOut(...) end,              -- "Set time of day to dusk"
    ["322"] = function(...) dotacraft:MakePlayerLose(...) end,               -- Lose the game         
    ["lvlup"] = function(...) dotacraft:LevelUp(...) end,                    -- Level all heroes    
    ["map_view"] = function(...) dotacraft:MapOverview(...) end,             -- Hides UI elements and sets flying camera distance
}

DEBUG_CODES = {
    ["debug_trees"] = function(...) Gatherer:DebugTrees() end,               -- Prints the trees marked as pathable
    ["debug_forests"] = function(...) Gatherer:DebugForests() end,           -- Prints the forest of each tree
    ["debug_blight"] = function(...) dotacraft:DebugBlight(...) end,         -- Prints the positions marked for undead buildings
    ["debug_food"] = function(...) dotacraft:DebugFood(...) end,             -- Prints the food count for all players, checking for inconsistencies
    ["debug_clear"] = function(...) DebugDrawClear() end,                    -- Clears all debug world elements
    ["debug_c"] = function(...) dotacraft:DebugCalls(...) end,               -- Spams the console with every lua call
    ["debug_l"] = function(...) dotacraft:DebugLines(...) end,               -- Spams the console with every lua line
}

TEST_CODES = {
    ["giveitem"] = function(...) dotacraft:GiveItem(...) end,          -- Gives an item by name to the currently selected unit
    ["createunits"] = function(...) dotacraft:CreateUnits(...) end,    -- Creates 'name' units around the currently selected unit, with optional num and neutral team
    ["testhero"] = function(...) dotacraft:TestHero(...) end,          -- Creates 'name' max level hero at the currently selected unit, optional team num
    ["testunit"] = function(...) dotacraft:TestUnit(...) end,          -- Creates 'name' unit
    ["testbuilding"] = function(...) dotacraft:TestBuilding(...) end,          -- Creates 'name' building unit
}

function dotacraft:DeveloperMode(player)
	local pID = player:GetPlayerID()
	local hero = player:GetAssignedHero()

    Players:ModifyGold(pID, 50000)
	Players:ModifyLumber(pID, 50000)
	Players:ModifyFoodLimit(pID, 100)
	--[[local position = GameRules.StartingPositions[pID].position
	dotacraft:SpawnTestUnits("orc_spirit_walker", 8, player, position + Vector(0,-600,0), false)
	dotacraft:SpawnTestUnits("nightelf_mountain_giant", 10, player, position + Vector(0,-1000,0), true)]]
end

-- A player has typed something into the chat
function dotacraft:OnPlayerChat(keys)
	local text = keys.text
	local userID = keys.userid
    local playerID = self.vUserIds[userID] and self.vUserIds[userID]:GetPlayerID()
    if not playerID then return end

    -- Handle '-command'
    if StringStartsWith(text, "-") then
        text = string.sub(text, 2, string.len(text))
    end

	local input = split(text)
	local command = input[1]
	if CHEAT_CODES[command] then
		CHEAT_CODES[command](playerID, input[2])
	elseif DEBUG_CODES[command] then
        DEBUG_CODES[command](input[2])
    elseif TEST_CODES[command] then
        TEST_CODES[command](playerID, input[2], input[3], input[4])
    end        
end

function dotacraft:WarpTen()
	BuildingHelper:WarpTen()
	local message = GameRules.WarpTen and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:GreedIsGood(playerID, value)
	if not value then value = 500 end
	
	Players:ModifyGold(playerID, tonumber(value))
	Players:ModifyLumber(playerID, tonumber(value))
	
	GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end

function dotacraft:WhosYourDaddy()
	GameRules.WhosYourDaddy = not GameRules.WhosYourDaddy
	
	local message = GameRules.WhosYourDaddy and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:ThereIsNoSpoon()
	GameRules.ThereIsNoSpoon = not GameRules.ThereIsNoSpoon
	
	local message = GameRules.ThereIsNoSpoon and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:ISeeDeadPeople()	
	GameRules.ISeeDeadPeople = not GameRules.ISeeDeadPeople
	GameMode:SetFogOfWarDisabled( GameRules.ISeeDeadPeople )

	local message = GameRules.ISeeDeadPeople and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:PointBreak()
	GameRules.PointBreak = not GameRules.PointBreak
	local foodBonus = GameRules.PointBreak and 1000 or 0

	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			Players:ModifyFoodLimit(playerID, foodBonus-Players:GetFoodLimit(playerID))
		end
	end

	local message = GameRules.PointBreak and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:Synergy()
	GameRules.Synergy = not GameRules.Synergy
	
	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local playerUnits = Players:GetUnits(playerID)
            local playerStructures = Players:GetUnits(playerID)
			for _,v in pairs(playerUnits) do
				CheckAbilityRequirements(v, playerID)
			end
			for _,v in pairs(playerStructures) do
				CheckAbilityRequirements(v, playerID)
			end
		end
	end

	local message = GameRules.Synergy and "Cheat enabled!" or "Cheat disabled!"
	GameRules:SendCustomMessage(message, 0, 0)
end

function dotacraft:RiseAndShine()
	GameRules:SetTimeOfDay( 0.3 )
end

function dotacraft:LightsOut()
	GameRules:SetTimeOfDay( 0.8 )
end

function dotacraft:GiveItem(playerID, item_name)
	local selected = PlayerResource:GetMainSelectedEntity(playerID)
    if selected then
        selected = EntIndexToHScript(selected)

    	local new_item = CreateItem(item_name, nil, nil)
    	if new_item then
            if selected:IsRealHero() then
                selected:AddItem(new_item)
            else
                local pos = selected:GetAbsOrigin()+RandomVector(200)
                CreateItemOnPositionSync(pos,new_item)
                new_item:LaunchLoot(false, 200, 0.75,pos)
            end
    	else
            print("ERROR, can't find "..item_name)
        end
    end
end

function dotacraft:MapOverview(playerID, distance)
    playerID = playerID or 0
    distance = distance or math.max((math.abs(GetWorldMinX())+GetWorldMaxX()), (math.abs(GetWorldMinY())+GetWorldMaxY()))

    GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )
    SendToServerConsole("r_farz 100000")
    SendToServerConsole("fog_enable 0")
    SendToServerConsole("dota_hud_healthbars 0")

    dotacraft.center_unit = dotacraft.center_unit or CreateUnitByName("nightelf_wisp",Vector(0,0,0),true,nil,nil,0)
    dotacraft.center_unit:AddNoDraw()
    Timers:CreateTimer(0.1, function()
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "map_overview", {center = dotacraft.center_unit:GetEntityIndex(), distance = distance})
    end)
end

function dotacraft:DebugBlight()
    for y,v in pairs(BuildingHelper.Grid) do
        for x,_ in pairs(v) do
            if BuildingHelper:CellHasGridType(x,y,'BLIGHT') then
                DrawGridSquare(x,y,Vector(128,0,128))
            end
            local pos = Vector(GridNav:GridPosToWorldCenterX(x), GridNav:GridPosToWorldCenterY(y), 0)
            pos = GetGroundPosition(pos,nil)
            if HasBlightParticle(pos) then
                DebugDrawCircle(pos,Vector(128,0,128),100,32,true,10)
            end
        end
    end
end

function dotacraft:DebugFood()
    for playerID=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local food_limit = Players:GetFoodLimit(playerID)
            local food_used = Players:GetFoodUsed(playerID)
            local food_produced_counter = 0
            local food_used_counter = 0
            print("== PLAYER "..playerID.." ==")
            print("== UNITS ==")

            local units = {}
            local playerUnits = Players:GetUnits(playerID)
            for _,v in pairs(playerUnits) do
                if not IsValidAlive(v) then
                    print(" Invalid Unit!")
                else
                    local food_cost = GetFoodCost(v)
                    food_used_counter = food_used_counter + food_cost
                    local unitName = v:GetUnitName()
                    units[unitName] = units[unitName] and units[unitName]+1 or 1
                end
            end

            print('-> '..food_used_counter.." food used on units: ")
            for k,v in pairs(units) do
                print(k,GameRules.UnitKV[k].FoodCost * v, "("..v..")")
            end

            print("== HEROES ==")
            local playerHeroes = Players:GetHeroes(playerID)
            local hero_food_counter = 0
            for _,v in pairs(playerHeroes) do
                if not IsValidAlive(v) then
                    print(" Invalid Hero!")
                else
                    local food_cost = GetFoodCost(v)
                    food_used_counter = food_used_counter + food_cost
                    hero_food_counter = hero_food_counter + food_cost
                end
            end
            print("-> "..hero_food_counter.." food used on heroes")

            print("== STRUCTURES ==")
            local playerStructures = Players:GetStructures(playerID)
            for _,v in pairs(playerStructures) do
                if not IsValidAlive(v) then
                    print(" Invalid Structure!")
                else
                    local food_produced = GetFoodProduced(v) or 0
                    food_produced_counter = food_produced_counter + food_produced
                    if food_produced_counter > 100 then food_produced_counter = 100 end
                end
            end
            print("-> "..food_produced_counter.." food produced from structures")

            print("================")
            print("Stored:  ",food_used.." / "..food_limit)
            print("Recount: ",food_used_counter.." / "..food_produced_counter)
            if (food_used ~= food_used_counter) then print("ERROR IN FOOD USED!") end
            if (food_limit ~= food_produced_counter) then print("ERROR IN FOOD PRODUCED!") end
            print("================")
        end
    end
end

function dotacraft:CreateUnits(pID, unitName, numUnits, bEnemy)
    local selected = PlayerResource:GetMainSelectedEntity(pID)
    if not selected then return end
    selected = EntIndexToHScript(selected)

    local pos = selected:GetAbsOrigin()
    local player = PlayerResource:GetPlayer(pID)
    local hero = player:GetAssignedHero()

     -- Handle possible unit issues
    numUnits = numUnits or 1
    if not GameRules.UnitKV[unitName] then
        Say(nil,"["..unitName.."] <font color='#ff0000'> is not a valid unit name!</font>", false)
        return
    end

    local gridPoints = GetGridAroundPoint(numUnits, pos)

    PrecacheUnitByNameAsync(unitName, function()
        for i=1,numUnits do
            local unit = CreateUnitByName(unitName, gridPoints[i], true, hero, hero, hero:GetTeamNumber())
            unit:SetOwner(hero)
            unit:SetControllableByPlayer(pID, true)
            unit:SetMana(unit:GetMaxMana())

            if bEnemy then 
                unit:SetTeam(DOTA_TEAM_NEUTRALS)
            else
                Players:AddUnit(pID, unit)
            end

            FindClearSpaceForUnit(unit, gridPoints[i], true)
            unit:Hold()         
        end
    end, pID)
end

function dotacraft:TestHero(playerID, heroName, bEnemy)
    local selected = PlayerResource:GetMainSelectedEntity(playerID)
    if not selected then return end
    selected = EntIndexToHScript(selected)

    local pos = selected:GetAbsOrigin()
    local unitName = GetRealHeroName(heroName)
    local team = bEnemy and DOTA_TEAM_BADGUYS or PlayerResource:GetTeam(playerID)

    PrecacheUnitByNameAsync(unitName, function()
        local hero = CreateUnitByName(unitName, pos, true, nil, nil, team)
        hero:SetControllableByPlayer(playerID, true)
        if not bEnemy then
            hero:SetOwner(PlayerResource:GetPlayer(playerID))
            hero:SetPlayerID(playerID)
        end

        for i=1,9 do
            hero:HeroLevelUp(false)
        end

    end, playerID)
end

function dotacraft:TestUnit(playerID, name, bEnemy)
    local selected = PlayerResource:GetMainSelectedEntity(playerID)
    if not selected then return end
    selected = EntIndexToHScript(selected)

    local pos = selected:GetAbsOrigin()
    local unitName
    for k,_ in pairs(KeyValues.UnitKV) do
        if k:match(name) then
            unitName = k
        end
    end
    local team = PlayerResource:GetTeam(playerID)
    if unitName then
        PrecacheUnitByNameAsync(unitName, function()
            local unit = CreateUnitByName(unitName, pos, true, nil, nil, team)
            unit:SetOwner(selected:GetOwner())
            unit:SetControllableByPlayer(playerID, true)
            unit:SetMana(unit:GetMaxMana())

            if bEnemy then 
                unit:SetTeam(DOTA_TEAM_NEUTRALS)
            else
                Players:AddUnit(playerID, unit)
                CheckAbilityRequirements(unit, playerID)
            end

            FindClearSpaceForUnit(unit, selected:GetAbsOrigin()+RandomVector(100), true)
            unit:Hold()

        end, playerID)
    end
end

function dotacraft:TestBuilding(playerID, name, bEnemy)
    local selected = PlayerResource:GetMainSelectedEntity(playerID)
    if not selected then return end
    selected = EntIndexToHScript(selected)

    local pos = selected:GetAbsOrigin() + RandomVector(300)
    local unitName
    for k,_ in pairs(KeyValues.UnitKV) do
        if k:match(name) then
            unitName = k
        end
    end
    local team = PlayerResource:GetTeam(playerID)
    if unitName then
        PrecacheUnitByNameAsync(unitName, function()
            local unit = BuildingHelper:PlaceBuilding(0, name, pos)

            if bEnemy then 
                unit:SetTeam(DOTA_TEAM_NEUTRALS)
            end

        end, playerID)
    end
end

function dotacraft:LevelUp(playerID, lvl)
    lvl = lvl or 1
    local heroes = Players:GetHeroes(playerID)
    for _,hero in pairs(heroes) do
        for i=1,lvl do
            hero:HeroLevelUp(false)
        end
    end
end

function dotacraft:DebugCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

function dotacraft:DebugLines(funcName)
    if not GameRules.DebugLines then
        print("Starting DebugLines "..funcName)
        GameRules.DebugLines = true

        -- Line Hook
        debug.sethook(function(event, line)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name == funcName then
                print("Line ".. line .. " -- " .. src .. " -- " .. name)
            end
        end, "l")
    else
        print("Stopped DebugLines")
        GameRules.DebugLines = false
        debug.sethook(nil, "l")
    end
end

--[[ 
StrengthAndHonor - No defeat
Motherland [race] [level] - level jump
SomebodySetUpUsTheBomb - Instant defeat
AllYourBaseAreBelongToUs - Instant victory
WhoIsJohnGalt - Enable research
SharpAndShiny - Research upgrades
DayLightSavings [time] - If a time is specified, time of day is set to that, otherwise time of day is alternately halted/resumed
]]