ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/map_switching.lua")
ScriptHost:LoadScript("scripts/autotracking/entrance_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
HOSTED = {captain=1,gknight=2,engine=3,librarian=4,scavboss=5,gauntlet=6,heir=7,ding=8,dong=9,dynamite=10,firebomb=11,icebomb=12}
er_table = {}

hexprayer = 0
hexcross = 0
hexice = 0

data_storage_table = {
    ["Defeated Guard Captain"] = "captain",
    ["Defeated Garden Knight"] = "gknight",
    ["Defeated Siege Engine"] = "engine",
    ["Defeated Librarian"] = "librarian",
    ["Defeated Boss Scavenger"] = "scavboss",
    ["Cleared Cathedral Gauntlet"] = "gauntlet",
    ["Reached an Ending"] = "heir",
    ["Rang East Bell"] = "ding",
    ["Rang West Bell"] = "dong",
    ["Granted Firecracker"] = "dynamite",
    ["Granted Firebomb"] = "firebomb",
    ["Granted Icebomb"] = "icebomb",
}

function onSetReply(key, value, _)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onSetReply: %s, %s, %s", key, value, _))
    end
    
    local slot_player = "Slot:" .. Archipelago.PlayerNumber
    local key2 = string.sub(key, string.len(slot_player) + 2, -1) --substrings the actual key name from `key`
    
    if key == slot_player .. ":Current Map" then
        if Tracker:FindObjectForCode("auto_tab").CurrentStage == 1 then
            if TABS_MAPPING[value] then
                CURRENT_ROOM = TABS_MAPPING[value]
            else
                CURRENT_ROOM = CURRENT_ROOM_ADDRESS
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
        end
    end
    
    if data_storage_table[key2] then
        Tracker:FindObjectForCode(data_storage_table[key2], ITEMS).Active = value
    end
    
    if value == true then --if entrance is discovered, populate ENTRANCE_MAPPING with it's pairing
        if ENTRANCE_MAPPING[key2] then
            ENTRANCE_MAPPING[key2][2] = er_table[key2]
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("entrance updated: %s = %s", key2, ENTRANCE_MAPPING[key2][2]))
            end
            Tracker:FindObjectForCode(ENTRANCE_MAPPING[key2][1]).Active = value
        end
    end
end

function retrieved(key, value)
    local key2 = string.sub(key, string.len(Archipelago.PlayerNumber) + 7, -1) --substrings the actual key name from `key`
    
    for long_name, short_name in pairs(data_storage_table) do
        if key == "Slot:" .. Archipelago.PlayerNumber .. ":" .. long_name then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
              print(string.format("called retrieved: %s, %s", key, value))
            end
            Tracker:FindObjectForCode(short_name, ITEMS).Active = value
        end
    end
    if ENTRANCE_MAPPING[key2] then 
        Tracker:FindObjectForCode(ENTRANCE_MAPPING[key2][1], ITEMS).Active = value
    end
end

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset hosted items
    for k, _ in pairs(HOSTED) do
        Tracker:FindObjectForCode(k).Active = false
    end

    if SLOT_DATA == nil then
        return
    end

    if slot_data['Hexagon Quest Prayer'] ~= 0 then
        hexprayer = slot_data['Hexagon Quest Prayer']
        --print("hexprayer: " .. hexprayer)
        hexcross = slot_data['Hexagon Quest Holy Cross']
        --print("hexcross: " .. hexcross)
        hexice = slot_data['Hexagon Quest Icebolt']
        --print("hexice: " .. hexice)
    end

    local should_activate = slot_data.ability_shuffling == 0
    Tracker:FindObjectForCode("pray").Active = should_activate
    Tracker:FindObjectForCode("cross").Active = should_activate
    Tracker:FindObjectForCode("icerod").Active = should_activate

    --print("slot_data.sword_progression: " .. slot_data.sword_progression)
    Tracker:FindObjectForCode("progswordSetting").CurrentStage = slot_data.sword_progression
    Tracker:FindObjectForCode("progswordSetting").CurrentStage = slot_data.sword_progression --why is this duplicated?

    if slot_data.start_with_sword ~= 0 then
        --print("slot_data.start_with_sword: " .. slot_data.start_with_sword)
        Tracker:FindObjectForCode("progsword").CurrentStage = 2
        Tracker:FindObjectForCode("sword").CurrentStage = 0
    end

    if slot_data.hexagon_quest ~= 0 then
        --print("slot_data['hexagon_quest']: " .. slot_data['hexagon_quest'])
        Tracker:FindObjectForCode("hexagonquest").CurrentStage = slot_data.hexagon_quest
        for _, color in ipairs({"red", "green", "blue"}) do
            Tracker:FindObjectForCode(color).Active = true
        end
    end

    if slot_data.entrance_rando ~= 0 then
        --print("slot_data['entrance_rando']: " .. slot_data['entrance_rando'])
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("called onClear, randoData:\n%s", dump_table(SLOT_DATA['Entrance Rando'])))
        end
        Tracker:FindObjectForCode("Entrance_visibility").Active = true
        local obj = Tracker:FindObjectForCode("er_off")
        if slot_data.entrance_rando == 0 then
            obj.CurrentStage = 0
        else
            obj.CurrentStage = 1
        end
        
        for k, v in pairs(SLOT_DATA['Entrance Rando']) do
            er_table[k] = v
            er_table[v] = k
        end
    end



    Tracker:FindObjectForCode("ladder_shuffle_off").CurrentStage = slot_data.shuffle_ladders
    -- needs to be called because onClear turns all the ladders off and the above line doesn't reenable them if shuffle_ladders is 0
    updateLayout()

    Tracker:FindObjectForCode("auto_tab").CurrentStage = 1
    local slot_player = "Slot:" .. Archipelago.PlayerNumber
    local data_storage_list = {}
    for _,list in pairs({ENTRANCE_MAPPING, data_storage_table}) do
        for k, _ in pairs(list) do
            table.insert(data_storage_list, slot_player .. ":" .. k)
        end
    end
    Archipelago:SetNotify(data_storage_list)
    Archipelago:Get(data_storage_list)
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if index <= CUR_INDEX then
        return
    end
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
            if v[1] == "pray" or v[1] == "cross" or v[1] == "icerod" then
                local manual = Tracker:FindObjectForCode("manual")
                manual.AcquiredCount = manual.AcquiredCount + 1
            end
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    if v[1] == "hexquest" and SLOT_DATA.ability_shuffling ~= 0 then
        print("hexes acquired: " .. obj.AcquiredCount)
        Tracker:FindObjectForCode("pray").Active = obj.AcquiredCount >= hexprayer
        Tracker:FindObjectForCode("cross").Active = obj.AcquiredCount >= hexcross
        Tracker:FindObjectForCode("icerod").Active = obj.AcquiredCount >= hexice
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

-- called when a location is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
--Archipelago:AddSetReplyHandler("Current Map", onChangedRegion) -- OLD OLD OLD
Archipelago:AddSetReplyHandler("set reply handler", onSetReply)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
Archipelago:AddRetrievedHandler("retrieved", retrieved)
