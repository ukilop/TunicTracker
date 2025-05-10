ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/map_switching.lua")

CUR_INDEX = -1
SLOT_DATA = nil
HOSTED = {captain=1,gknight=2,engine=3,librarian=4,scavboss=5,gauntlet=6,heir=7,ding=8,dong=9,dynamite=10,firebomb=11,icebomb=12}

hexprayer = 0
hexcross = 0
hexice = 0
progsword_count = 0
start_with_sword_on = false

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

-- the object's code (that you'd use in FindObjectForCode), the slot data value, and if it's a multi-stage option
local function set_option(code, slot_data_value, is_multi_stage)
    local obj = Tracker:FindObjectForCode(code)
    if not obj or not slot_data_value then return end

    if is_multi_stage then
        --print(code)
        --print(slot_data_value)
        obj.CurrentStage = slot_data_value
    else
        obj.Active = slot_data_value == 1
    end
end

function onSetReply(key, value, _)
    local slot_player = "Slot:" .. Archipelago.PlayerNumber
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
    for long_name, short_name in pairs(data_storage_table) do
        if key == slot_player .. ":" .. long_name then
            Tracker:FindObjectForCode(short_name, ITEMS).Active = value
        end
    end
end

function retrieved(key, value)
    for long_name, short_name in pairs(data_storage_table) do
        if key == "Slot:" .. Archipelago.PlayerNumber .. ":" .. long_name then
            Tracker:FindObjectForCode(short_name, ITEMS).Active = value
        end
    end
end

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data))) --print EVERYTHING
        --[[
            example slot_data

            {
                ["sword_progression"] = 0,
                ["Sword Upgrade"] = {
                    [1] = Coins in the Well - 10 Coins,
                    [2] = 2,
                    [3] = Coins in the Well - 15 Coins,
                    [4] = 2,
                    [5] = Coins in the Well - 3 Coins,
                    [6] = 2,
                    [7] = Coins in the Well - 6 Coins,
                    [8] = 2,
                },
                ["Old House Key"] = {
                    [1] = Monastery - Crate 5,
                    [2] = 2,
                },
                ["keys_behind_bosses"] = 0,
                ["ice_grappling"] = 0,
                ["combat_logic"] = 2,
                ["fool_traps"] = 1,
                ["Entrance Rando"] = {
                    ["Furnace, Overworld Redux_gyro_west"] = RelicVoid, Monastery_teleporter_relic plinth,
                    ["Crypt Redux, Sewer_Boss_"] = East Forest Redux, East Forest Redux Laddercave_lower,
                    ["Quarry Redux, Shop_"] = Sword Access, East Forest Redux_lower,
                    ["Overworld Redux, PatrolCave_"] = Transit, Quarry Redux_teleporter_quarry teleporter,
                    ["Atoll Redux, Transit_teleporter_atoll"] = Archipelagos Redux, RelicVoid_teleporter_relic plinth,
                    ["Fortress Courtyard, Fortress Basement_"] = Swamp Redux 2, Cathedral Redux_main,
                    ["Overworld Redux, Swamp Redux 2_conduit"] = Atoll Redux, Library Exterior_,
                    ["Fortress Main, Shop_"] = Cathedral Redux, Cathedral Arena_,
                    ["Atoll Redux, Overworld Redux_lower"] = ziggurat2020_2, ziggurat2020_3_,
                    ["Overworld Redux, Overworld Cave_"] = Forest Boss Room, East Forest Redux Laddercave_,
                    ["Fortress Courtyard, Fortress Main_Big Door"] = Fortress Courtyard, Fortress Reliquary_Upper,
                    ["Crypt Redux, Furnace_"] = Fortress East, Fortress Main_lower,
                    ["Overworld Redux, Darkwoods Tunnel_"] = Fortress Reliquary, Fortress Courtyard_Upper,
                    ["East Forest Redux Laddercave, East Forest Redux_upper"] = Library Rotunda, Library Lab_,
                    ["Overworld Redux, Swamp Redux 2_wall"] = ziggurat2020_3, ziggurat2020_1_zig2_skip,
                    ["Transit, Overworld Redux_teleporter_town"] = Sewer_Boss, Crypt Redux_,
                    ["Fortress Main, Fortress East_upper"] = Sword Cave, Overworld Redux_,
                    ["Archipelagos Redux, Overworld Redux_lower"] = Library Arena, Library Lab_,
                    ["Fortress Courtyard, Fortress East_"] = ShopSpecial, Overworld Redux_,
                    ["ziggurat2020_3, ziggurat2020_FTRoom_"] = Archipelagos Redux, Overworld Redux_lowest,
                    ["Fortress Courtyard, Forest Belltower_"] = RelicVoid, Archipelagos Redux_teleporter_relic plinth,
                    ["ziggurat2020_1, ziggurat2020_2_"] = Overworld Redux, Waterfall_,
                    ["ziggurat2020_0, ziggurat2020_1_"] = frog cave main, Frog Stairs_Exit,
                    ["Cathedral Arena, Shop_"] = Changing Room, Overworld Redux_,
                    ["Atoll Redux, Frog Stairs_eye"] = Waterfall, Overworld Redux_,
                    ["Fortress East, Fortress Main_upper"] = Quarry Redux, Monastery_back,
                    ["Cathedral Redux, Swamp Redux 2_main"] = Purgatory, Purgatory_top,
                    ["Windmill, Overworld Redux_"] = Transit, Atoll Redux_teleporter_atoll,
                    ["Overworld Redux, Transit_teleporter_town"] = ziggurat2020_2, ziggurat2020_1_,
                    ["Overworld Redux, Fortress Courtyard_"] = CubeRoom, Overworld Redux_,
                    ["Fortress Reliquary, Dusty_"] = Forest Belltower, Forest Boss Room_,
                    ["Swamp Redux 2, Overworld Redux_conduit"] = Library Exterior, Library Hall_,
                    ["Transit, Library Lab_teleporter_library teleporter"] = RelicVoid, Sword Access_teleporter_relic plinth,
                    ["East Forest Redux, Sword Access_upper"] = Transit, East Forest Redux_teleporter_forest teleporter,
                    ["Overworld Redux, Town_FiligreeRoom_"] = Mountain, Overworld Redux_,
                    ["Forest Belltower, East Forest Redux_"] = Transit, Archipelagos Redux_teleporter_archipelagos_teleporter,
                    ["Sword Access, East Forest Redux_upper"] = Frog Stairs, Atoll Redux_mouth,
                    ["East Forest Redux, Transit_teleporter_forest teleporter"] = Crypt Redux, Overworld Redux_,
                    ["East Forest Redux Interior, East Forest Redux_lower"] = Archipelagos Redux, Transit_teleporter_archipelagos_teleporter,
                    ["Fortress Courtyard, Fortress Reliquary_Lower"] = East Forest Redux, East Forest Redux Interior_upper,
                    ["Swamp Redux 2, Shop_"] = Overworld Redux, Archipelagos Redux_lower,
                    ["Overworld Redux, EastFiligreeCache_"] = Fortress Courtyard, Shop_,
                    ["Swamp Redux 2, RelicVoid_teleporter_relic plinth"] = Overworld Redux, Temple_main,
                    ["Overworld Redux, Ruins Passage_east"] = Swamp Redux 2, Cathedral Redux_secret,
                    ["Overworld Redux, CubeRoom_"] = Darkwoods Tunnel, Overworld Redux_,
                    ["Sewer, Overworld Redux_entrance"] = RelicVoid, Library Hall_teleporter_relic plinth,
                    ["Overworld Redux, Windmill_"] = Shop, Previous Region_,
                    ["East Forest Redux Laddercave, East Forest Redux_lower"] = Fortress Reliquary, RelicVoid_teleporter_relic plinth,
                    ["Transit, ziggurat2020_FTRoom_teleporter_ziggurat teleporter"] = Town Basement, Overworld Redux_beach,
                    ["Atoll Redux, Frog Stairs_mouth"] = Transit, Fortress Arena_teleporter_spidertank,
                    ["Sewer, Overworld Redux_west_aqueduct"] = Forest Boss Room, Forest Belltower_,
                    ["Overworld Redux, Ruined Shop_"] = East Forest Redux Interior, East Forest Redux_upper,
                    ["Quarry Redux, ziggurat2020_0_"] = Fortress Main, Fortress Courtyard_Big Door,
                    ["Fortress Courtyard, Overworld Redux_"] = ziggurat2020_3, ziggurat2020_2_,
                    ["Quarry Redux, Transit_teleporter_quarry teleporter"] = Maze Room, Overworld Redux_,
                    ["Overworld Redux, Overworld Interiors_house"] = Overworld Interiors, Overworld Redux_under_checkpoint,
                    ["Monastery, Quarry Redux_back"] = Swamp Redux 2, Cathedral Arena_,
                    ["Forest Belltower, Fortress Courtyard_"] = Fortress East, Fortress Courtyard_,
                    ["Quarry Redux, Mountain_"] = Temple, Overworld Redux_main,
                    ["Atoll Redux, Overworld Redux_upper"] = Quarry Redux, Darkwoods Tunnel_,
                    ["Library Lab, Library Rotunda_"] = archipelagos_house, Archipelagos Redux_,
                    ["Archipelagos Redux, Shop_"] = frog cave main, Frog Stairs_Entrance,
                    ["Transit, Spirit Arena_teleporter_spirit arena"] = Darkwoods Tunnel, Quarry Redux_,
                    ["Swamp Redux 2, Overworld Redux_wall"] = Sewer_Boss, Sewer_,
                    ["Overworld Redux, Atoll Redux_lower"] = Fortress Reliquary, Fortress Courtyard_Lower,
                    ["East Forest Redux, East Forest Redux Laddercave_upper"] = g_elements, Overworld Interiors_,
                    ["Overworld Redux, Ruins Passage_west"] = East Forest Redux, East Forest Redux Interior_lower,
                    ["Overworld Redux, Overworld Interiors_under_checkpoint"] = RelicVoid, Fortress Reliquary_teleporter_relic plinth,
                    ["Frog Stairs, frog cave main_Exit"] = Purgatory, Purgatory_bottom,
                    ["Library Hall, Library Rotunda_"] = Furnace, Overworld Redux_gyro_upper_north,
                    ["Overworld Redux, Temple_rafters"] = Overworld Interiors, g_elements_,
                    ["Overworld Redux, Sword Cave_"] = Monastery, RelicVoid_teleporter_relic plinth,
                    ["Overworld Redux, Sewer_entrance"] = Spirit Arena, Transit_teleporter_spirit arena,
                    ["Overworld Redux, Archipelagos Redux_lowest"] = Ruins Passage, Overworld Redux_west,
                    ["Overworld Redux, ShopSpecial_"] = Overworld Redux, Furnace_gyro_upper_north,
                    ["Furnace, Overworld Redux_gyro_lower"] = Library Lab, Library Arena_,
                    ["Overworld Redux, Transit_teleporter_starting island"] = ziggurat2020_FTRoom, ziggurat2020_3_,
                    ["Mountain, Mountaintop_"] = Overworld Cave, Overworld Redux_,
                    ["East Forest Redux, East Forest Redux Laddercave_gate"] = ziggurat2020_FTRoom, Transit_teleporter_ziggurat teleporter,
                    ["Overworld Redux, Crypt Redux_"] = Library Hall, RelicVoid_teleporter_relic plinth,
                    ["Overworld Interiors, Overworld Redux_house"] = Archipelagos Redux, Overworld Redux_upper,
                    ["Library Exterior, Atoll Redux_"] = ziggurat2020_1, ziggurat2020_0_,
                    ["Overworld Redux, Town Basement_beach"] = Ruins Passage, Overworld Redux_east,
                    ["Furnace, Crypt Redux_"] = Cathedral Arena, Cathedral Redux_,
                    ["Overworld Redux, Furnace_gyro_upper_east"] = Ruined Shop, Overworld Redux_,
                    ["Overworld Redux, Maze Room_"] = Windmill, Shop_,
                    ["Archipelagos Redux, archipelagos_house_"] = EastFiligreeCache, Overworld Redux_,
                    ["Mountain, Quarry Redux_"] = Dusty, Fortress Reliquary_,
                    ["Overworld Redux, Atoll Redux_upper"] = Transit, Overworld Redux_teleporter_starting island,
                    ["Library Hall, Library Exterior_"] = Sewer, Sewer_Boss_,
                    ["Overworld Redux, Mountain_"] = Forest Belltower, Overworld Redux_,
                    ["Fortress Basement, Fortress Main_"] = East Forest Redux Laddercave, Forest Boss Room_,
                    ["Overworld Redux, Furnace_gyro_lower"] = ziggurat2020_0, Quarry Redux_,
                    ["Furnace, Overworld Redux_gyro_upper_east"] = Fortress Basement, Fortress Courtyard_,
                    ["Fortress Arena, Fortress Main_"] = Library Lab, Transit_teleporter_library teleporter,
                    ["Frog Stairs, Atoll Redux_eye"] = Mountaintop, Mountain_,
                    ["East Forest Redux, Sword Access_lower"] = Town_FiligreeRoom, Overworld Redux_,
                    ["Overworld Redux, Furnace_gyro_west"] = Fortress Arena, Transit_teleporter_spidertank,
                    ["Cathedral Arena, Swamp Redux 2_"] = PatrolCave, Overworld Redux_,
                    ["Overworld Redux, Forest Belltower_"] = RelicVoid, Swamp Redux 2_teleporter_relic plinth,
                    ["Frog Stairs, frog cave main_Entrance"] = East Forest Redux Laddercave, East Forest Redux_gate,
                    ["Fortress Main, Fortress Basement_"] = Cathedral Redux, Swamp Redux 2_secret,
                    ["Atoll Redux, Shop_"] = Sword Access, RelicVoid_teleporter_relic plinth,
                    ["Fortress Main, Fortress East_lower"] = Monastery, Quarry Redux_front,
                    ["East Forest Redux, Forest Belltower_"] = Temple, Overworld Redux_rafters,
                    ["Quarry Redux, Monastery_front"] = Library Rotunda, Library Hall_,
                    ["Overworld Redux, Sewer_west_aqueduct"] = Fortress Main, Fortress Arena_,
                    ["Overworld Redux, Changing Room_"] = Overworld Redux, Archipelagos Redux_upper,
                },
                ["Hexagon Quest Goal"] = 10,
                ["Hexagon Quest Prayer"] = 2,
                ["Hourglass"] = {
                    [1] = Overworld - [East] Pot near Slimes 3,
                    [2] = 1,
                },
                ["entrance_rando"] = 1,
                ["laurels_zips"] = 1,
                ["disable_local_spoiler"] = 0,
                ["Hero Relic - POTION"] = {
                    [1] = Beneath the Well - [Second Room] Underwater Chest,
                    [2] = 2,
                },
                ["Hero Relic - ATT"] = {
                    [1] = Overworld - [Southwest] West Beach Guarded By Turret,
                    [2] = 2,
                },
                ["Gold Questagon"] = {
                    [1] = Forest Belltower - Pot after Guard Captain 2,
                    [2] = 2,
                    [3] = Maze Cave - Maze Room Holy Cross,
                    [4] = 1,
                    [5] = Purgatory - Pot 25,
                    [6] = 2,
                },
                ["Magic Dagger"] = {
                    [1] = Beneath the Well - [Back Corridor] Left Secret,
                    [2] = 1,
                },
                ["Hero Relic - MP"] = {
                    [1] = Dark Tomb - Spike Maze Upper Walkway,
                    [2] = 2,
                },
                ["hexagon_quest_ability_type"] = 0,
                ["grass_randomizer"] = 0,
                ["start_with_sword"] = 0,
                ["Hexagon Quest Icebolt"] = 5,
                ["Hexagon Quest Holy Cross"] = 7,
                ["Magic Wand"] = {
                    [1] = Swamp - [South Graveyard] 4 Orange Skulls,
                    [2] = 1,
                },
                ["Hero Relic - SP"] = {
                    [1] = Eastern Vault Fortress - [West Wing] Pot by Checkpoint 2,
                    [2] = 1,
                },
                ["seed"] = 1083613470,
                ["Sword"] = {
                    [1] = Purgatory - Pot 9,
                    [2] = 1,
                    [3] = Quarry - [Lowlands] Upper Walkway,
                    [4] = 1,
                    [5] = Beneath the Well - [Third Room] Barrel by West Turret 1,
                    [6] = 2,
                },
                ["Magic Orb"] = {
                    [1] = Overworld - [Northwest] Page By Well,
                    [2] = 1,
                },
                ["maskless"] = 0,
                ["lanternless"] = 0,
                ["Gun"] = {
                    [1] = Fortress Courtyard - Upper Fire Pot,
                    [2] = 2,
                },
                ["ladder_storage_without_items"] = 0,
                ["Stick"] = {
                    [1] = Monastery - Monastery Chest,
                    [2] = 1,
                },
                ["ladder_storage"] = 0,
                ["Hero's Laurels"] = {
                    [1] = Secret Gathering Place - 20 Fairy Reward,
                    [2] = 2,
                },
                ["Lantern"] = {
                    [1] = Ruined Shop - Chest 3,
                    [2] = 1,
                },
                ["Hero Relic - DEF"] = {
                    [1] = Frog's Domain - Escape Chest,
                    [2] = 2,
                },
                ["breakable_shuffle"] = 1,
                ["ability_shuffling"] = 1,
                ["shuffle_ladders"] = 1,
                ["Dath Stone"] = {
                    [1] = Quarry - [West] Lower Area Isolated Chest,
                    [2] = 2,
                },
                ["hexagon_quest"] = 1,
                ["Fortress Vault Key"] = {
                    [1] = Quarry - [West] Crate by Shooting Range 1,
                    [2] = 2,
                },
                ["Scavenger Mask"] = {
                    [1] = Beneath the Well - [Third Room] Barrel after Back Corridor 5,
                    [2] = 1,
                },
                ["Shield"] = {
                    [1] = Beneath the Well - [Entryway] Chest,
                    [2] = 2,
                },
                ["Hero Relic - HP"] = {
                    [1] = Quarry - [West] Explosive Pot above Shooting Range,
                    [2] = 1,
                },
            }

        ]]
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

    if slot_data['Hexagon Quest Prayer'] ~= 0 and slot_data.hexagon_quest_ability_type ~= 1 then
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
    Tracker:FindObjectForCode("progswordSetting").CurrentStage = slot_data.sword_progression

    if slot_data.start_with_sword ~= 0 then
        --print("slot_data.start_with_sword: " .. slot_data.start_with_sword)
        start_with_sword_on = true
        Tracker:FindObjectForCode("progsword").CurrentStage = 2
        Tracker:FindObjectForCode("sword").CurrentStage = 0
    end

    Tracker:FindObjectForCode("hexagonquest").CurrentStage = slot_data.hexagon_quest
    if slot_data.hexagon_quest ~= 0 then
        HEXGOAL = slot_data["Hexagon Quest Goal"]
    end

    set_option("er_off", slot_data.entrance_rando, false)

    set_option("maskless", slot_data.maskless, false)
    set_option("lanternless", slot_data.lanternless, false)

    set_option("laurels_zips", slot_data.laurels_zips, false)
    set_option("ice_grapple_off", slot_data.ice_grappling, true)
    set_option("ladder_storage_off", slot_data.ladder_storage, true)
    set_option("storage_no_items", slot_data.ladder_storage_without_items, false)

    set_option("fuse_shuffle", slot_data.shuffle_fuses, false)
    --set_option("bell_shuffle", slot_data.shuffle_bells, false)

    set_option("vis_ice_grapple_off", math.max(slot_data.ice_grappling, Tracker:FindObjectForCode("vis_ice_grapple_off").CurrentStage), true)
    set_option("vis_ladder_storage_off", math.max(slot_data.ladder_storage, Tracker:FindObjectForCode("vis_ladder_storage_off").CurrentStage), true)

    Tracker:FindObjectForCode("ladder_shuffle_off").CurrentStage = slot_data.shuffle_ladders

    Tracker:FindObjectForCode("auto_tab").CurrentStage = 1
    local slot_player = "Slot:" .. Archipelago.PlayerNumber
    local data_storage_list = ({slot_player .. ":Current Map",
                           slot_player .. ":Defeated Guard Captain",
                           slot_player .. ":Defeated Garden Knight",
                           slot_player .. ":Defeated Siege Engine",
                           slot_player .. ":Defeated Librarian",
                           slot_player .. ":Defeated Boss Scavenger",
                           slot_player .. ":Cleared Cathedral Gauntlet",
                           slot_player .. ":Reached an Ending",
                           slot_player .. ":Rang East Bell",
                           slot_player .. ":Rang West Bell",
                           slot_player .. ":Granted Firecracker",
                           slot_player .. ":Granted Firebomb",
                           slot_player .. ":Granted Icebomb"})

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
        -- if progsword and start with sword is on, we need to avoid weird behavior
        -- so, we're counting up how many progswords you have separately
        if v[1] == "progsword" then
            progsword_count = progsword_count + 1
        end
        -- start with sword sets it to 2, so we want either 2 or your progsword count, whichever is higher
        if v[1] == "progsword" and start_with_sword_on then
            obj.CurrentStage = math.max(2, progsword_count)
        elseif v[2] == "toggle" then
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
    if v[1] == "hexquest" and SLOT_DATA.ability_shuffling ~= 0 and SLOT_DATA.hexagon_quest_ability_type ~= 1 then
        --print("hexes acquired: " .. obj.AcquiredCount)
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
    if not v then
        return
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

-- called when a locations is scouted
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
Archipelago:AddSetReplyHandler("set reply handler", onSetReply)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
Archipelago:AddRetrievedHandler("retrieved", retrieved)
