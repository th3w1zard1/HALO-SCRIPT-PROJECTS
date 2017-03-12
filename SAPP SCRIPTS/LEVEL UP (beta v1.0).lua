--[[
Script Name: LEVEL UP (beta v1.0), for SAPP | (PC\CE)
Implementing API version: 1.11.0.0

    Acknowledgments
    Credits to "Giraffe" for his AutoVehicle-Flip functions.
    Credits to 002 for his get_tag_info function (return metaid)
    Credits to sehe for his death message patch

This script is also available on my github! Check my github for regular updates on my projects, including this script.
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS

* IGN: Chalwk
* This is my extension of a "progression based game" that was for Phasor, by OZ Clan
* Written by Jericho Crosby (Chalwk)
]]

api_version = "1.11.0.0"
Starting_Level = 1 -- Must match beginning of level[#]
ctf_enabled = true -- Spawn the flag?

-- If the player survives "allocated_time" without dying, reward them with random ammo/powerups
survivor_rewards = true

-- If the player survives this amount of time without dying then they're rewarded with ammo and/or powerup
allocated_time = 120 -- (2 minutes) -- Time (in seconds) before player is rewarded ammo/powerup

-- If player has been alive for "progression_timer", then cycle their level (update, advance)
progression_timer = 180 -- (3 minutes)

-- Temporary weapon to assign when they exit their vehicle
out_of_vehicle_weapon = "weapons\\shotgun\\shotgun"

-- 1 random item from this list will be given after surviving "allocated_time"
REWARDS = { }
REWARDS[1] = { "powerups\\active camouflage", "a camouflage!"}
REWARDS[2] = { "powerups\\over shield", "an overshield!"}

-- Time until flag respawns after being dropped (in seconds)
flag_respawn_timer = 30

-- Time until flag respawn warning is announced (in seconds)
flag_warning = 15

Speed_Powerup = 2 -- in seconds
Speed_Powerup_Duration = 20 -- in seconds
Default_Running_Speed = 1 -- in seconds

Flag_Runner_Speed = 2.0 -- Flag-Holder running speed
Flag_Runner_Camo_Duration = 15 -- Flag-Holder invisibility time

Spawn_Where_Killed = false -- Spawn at the same location as player died
Spawn_Invunrable_Time = nil -- Seconds - nil disabled

Check_Time = 0 -- Mili-seconds to check if player in scoring area
Check_Radius = 1 -- Radius determining if player is in scoring area

Melee_Multiplier = 4 -- Multiplier to meele damage. 1 = normal damage
Grenade_Multiplier = 4 -- Multiplier to frag damage. 1 = normal damage
Normal_Damage = 1 -- Normal weapon damage multiplier. 1 = normal damage

ADMIN_LEVEL = 1 -- Default admin level required to use "/level up" command

-- Giraffe's --
PLAYER_VEHICLES_ONLY = true -- true or false, whether or not to only auto flip vehicles that players are in
WAIT_FOR_IMPACT = true -- true or false, whether or not to wait until impact before auto flipping vehicle
-----------------------------------------------------------------------------------------------------------
-- Choose what to drop when someone dies --
PowerUpSettings = {
    ["WeaponsAndEquipment"] = false,
    ["JustEquipment"] = false,
    ["JustWeapons"] = false
}
-- Giraffe's
rider_ejection = nil
object_table_ptr = nil
-----------------------
current_players = 0
FLAG = { }
TIMER = { }
players = { }
FLAG_BOOL = { }
FRAG_CHECK = { }
FLAG_RESPAWN = { }
FLAG_WARN = { }
PLASMA_CHECK = { }
WEAPON_TABLE = { }
PLAYERS_ALIVE = { }
STORED_LEVELS = { }
DAMAGE_APPLIED = { }
EQUIPMENT_TAGS = { }
PLAYER_LOCATION = { }
EQUIPMENT_TABLE = { }
PROGRESSION_TIMER = { }
for i = 1, 16 do PLAYER_LOCATION[i] = { } end
weap_type_id = "weap"
eqip_type_id = "eqip"
vehi_type_id = "vehi"

-- For a Future Update
-- Objects to drop when someone dies | Rewards for surviving "allocated_time" without dying
EQUIPMENT_TABLE[1] = { "powerups\\shotgun ammo\\shotgun ammo", "Shotgun Ammo" }
EQUIPMENT_TABLE[2] = { "powerups\\assault rifle ammo\\assault rifle ammo", "Assault Rifle Ammo" }
EQUIPMENT_TABLE[3] = { "powerups\\pistol ammo\\pistol ammo", "Pistol Ammo" }
EQUIPMENT_TABLE[4] = { "powerups\\sniper rifle ammo\\sniper rifle ammo", "Sniper Rifle Ammo" }
EQUIPMENT_TABLE[5] = { "powerups\\rocket launcher ammo\\rocket launcher ammo", "Rocket Launcher Ammo" }
EQUIPMENT_TABLE[6] = { "powerups\\needler ammo\\needler ammo", "Needler Ammo" }
EQUIPMENT_TABLE[7] = { "powerups\\flamethrower ammo\\flamethrower ammo", "Flamethrower Ammo" }
EQUIPMENT_TABLE[8] = { "powerups\\active camouflage", "Camouflage" }
EQUIPMENT_TABLE[9] = { "powerups\\health pack", "Health Pack" }
EQUIPMENT_TABLE[10] = { "powerups\\over shield", "Overshield" }
-- Objects to drop when someone dies | Rewards for surviving "allocated_time" without dying
WEAPON_TABLE[1] = { "weapons\\shotgun\\shotgun", "Shotgun" }
WEAPON_TABLE[2] = { "weapons\\assault rifle\\assault rifle", "Assault Rifle" }
WEAPON_TABLE[3] = { "weapons\\pistol\\pistol", "Pistol" }
WEAPON_TABLE[4] = { "weapons\\sniper rifle\\sniper rifle", "Sniper Rifle" }
WEAPON_TABLE[5] = { "weapons\\rocket launcher\\rocket launcher", "Rocket Launcher" }
WEAPON_TABLE[6] = { "weapons\\plasma_cannon\\plasma_cannon", "Plasma Cannon" }
WEAPON_TABLE[7] = { "weapons\\flamethrower\\flamethrower", "Flamethrower" }
WEAPON_TABLE[8] = { "weapons\\needler\\mp_needler", "Needler" }
WEAPON_TABLE[9] = { "weapons\\plasma pistol\\plasma pistol", "Plasma Pistol" }
WEAPON_TABLE[10] = { "weapons\\plasma rifle\\plasma rifle", "Plasma Rifle" }

function LoadLarge()
    Level = { }
    Level[1] = { "weapons\\shotgun\\shotgun", "Shotgun", "Melee or Nades!", 1, { 6, 6 }, 0 }
    Level[2] = { "weapons\\assault rifle\\assault rifle", "Assualt Rifle", "Aim and unload!", 2, { 2, 2 }, 240 }
    Level[3] = { "weapons\\pistol\\pistol", "Pistol", "Aim for the head", 3, { 2, 1 }, 36 }
    Level[4] = { "weapons\\sniper rifle\\sniper rifle", "Sniper Rifle", "Aim, Exhale and fire!", 4, { 3, 2 }, 12 }
    Level[5] = { "weapons\\rocket launcher\\rocket launcher", "Rocket Launcher", "Blow people up!", 5, { 1, 1 }, 6 }
    Level[6] = { "weapons\\plasma_cannon\\plasma_cannon", "Fuel Rod", "Bombard anything that moves!", 6, { 3, 1 }, 0 }
    Level[7] = { "vehicles\\ghost\\ghost_mp", "Ghost", "Run people down!", 7, { 0, 0 }, 0 }
    Level[8] = { "vehicles\\rwarthog\\rwarthog", "Rocket Hog", "Blow em' up!", 8, { 0, 0 }, 0 }
    Level[9] = { "vehicles\\scorpion\\scorpion_mp", "Tank", "Wreak havoc!", 9, { 0, 0 }, 0 }
    Level[10] = { "vehicles\\banshee\\banshee_mp", "Banshee", "Hurry up and win!", 10, { 0, 0 }, 0 }
    for k, v in pairs(Level) do
        if string.find(v[1], "vehicles") then
            v[11] = v[1]
            v[12] = 1
        else
            v[11] = v[1]
            v[12] = 0
        end
    end
end

function LoadSmall()
    Level = { }
    Level[1] = { "weapons\\shotgun\\shotgun", "Shotgun", "Melee or Nades!", 1, { 6, 6 }, 0 }
    Level[2] = { "weapons\\assault rifle\\assault rifle", "Assualt Rifle", "Aim and unload!", 2, { 2, 2 }, 240 }
    Level[3] = { "weapons\\pistol\\pistol", "Pistol", "Aim for the head", 3, { 2, 1 }, 36 }
    Level[4] = { "weapons\\sniper rifle\\sniper rifle", "Sniper Rifle", "Aim, Exhale and fire!", 4, { 3, 2 }, 12 }
    Level[5] = { "weapons\\rocket launcher\\rocket launcher", "Rocket Launcher", "Blow people up!", 5, { 1, 1 }, 6 }
    Level[6] = { "weapons\\plasma_cannon\\plasma_cannon", "Fuel Rod", "Bombard anything that moves!", 6, { 3, 1 }, 0 }
    for k, v in pairs(Level) do
        if string.find(v[1], "weapons") then
            v[7] = v[1]
            v[8] = 1
        else
            v[7] = v[1]
            v[8] = 0
        end
    end
end  
     
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")
    register_callback(cb["EVENT_GAME_START"], "OnNewGame")
    register_callback(cb['EVENT_COMMAND'], "OnServerCommand")
    register_callback(cb['EVENT_WEAPON_DROP'], "OnWeaponDrop")
    register_callback(cb['EVENT_PRESPAWN'], "OnPlayerPrespawn")
    register_callback(cb["EVENT_VEHICLE_EXIT"], "OnVehicleExit")
    register_callback(cb['EVENT_WEAPON_PICKUP'], "OnWeaponPickup")
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")
    -- Giraffe's object_table_ptr --
    object_table_ptr = sig_scan("8B0D????????8B513425FFFF00008D")
    -------------------------------------------------------------
    LoadItems()
    MAP_NAME = get_var(1, "$map")
    -- Check if valid GameType
    CheckType()
    gametype = get_var(0, "$gt")
    -- set score limit --
    execute_command("scorelimit 250")
    -- disable vehicle entry --
    execute_command("disable_all_vehicles 0 1")
    -- disable weapon pickups --
    execute_command("disable_object 'weapons\\assault rifle\\assault rifle'")
    execute_command("disable_object 'weapons\\flamethrower\\flamethrower'")
    execute_command("disable_object 'weapons\\needler\\mp_needler'")
    execute_command("disable_object 'weapons\\pistol\\pistol'")
    execute_command("disable_object 'weapons\\plasma pistol\\plasma pistol'")
    execute_command("disable_object 'weapons\\plasma rifle\\plasma rifle'")
    execute_command("disable_object 'weapons\\plasma_cannon\\plasma_cannon'")
    execute_command("disable_object 'weapons\\rocket launcher\\rocket launcher'")
    execute_command("disable_object 'weapons\\shotgun\\shotgun'")
    execute_command("disable_object 'weapons\\sniper rifle\\sniper rifle'")
    -- disable grenade pickups --
    execute_command("disable_object 'weapons\\frag grenade\\frag grenade'")
    execute_command("disable_object 'weapons\\plasma grenade\\plasma grenade'")
    if halo_type == "PC" then ce = 0x0 else ce = 0x40 end
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    -- sehe's death Message Patch --
    disable_killmsg_addr = sig_scan("8B42348A8C28D500000084C9") + 3
    original_code_1 = read_dword(disable_killmsg_addr)
    safe_write(true)
    write_dword(disable_killmsg_addr, 0x03EB01B1)
    safe_write(false)
    current_players = 0
    -------------------------------------------------------------------
    for i = 1, 16 do
        if player_present(i) then
            DAMAGE_APPLIED[i] = 0
            local PLAYER_ID = get_var(i, "$n")
            PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].VEHICLE = nil
            PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
            PLAYERS_ALIVE[PLAYER_ID].FLAG = 0
        end
    end
    -- Giraffe's --
    if (halo_type == "CE") then
        rider_ejection = read_byte(0x59A34C)
        write_byte(0x59A34C, 0)
    else
        rider_ejection = read_byte(0x6163EC)
        write_byte(0x6163EC, 0)
    end
    -- ======================================== --
end

function OnScriptUnload()
    Level = { }
    FLAG = { }
    players = { }
    FRAG_CHECK = { }
    PLASMA_CHECK = { }
    WEAPON_TABLE = { }
    STORED_LEVELS = { }
    DAMAGE_APPLIED = { }
    PLAYER_LOCATION = { }
    EQUIPMENT_TAGS = { }
    EQUIPMENT_TABLE = { }
    rider_ejection = nil
    object_table_ptr = nil
    -- sehe's death Message Patch --
    safe_write(true)
    write_dword(disable_killmsg_addr, original_code_1)
    write_word(disable_speed_decrease_addr, original_code_2)
    write_word(force_speed_sync_addr, original_code_3)
    safe_write(false)
    ----------------------------------------------------------
    if (halo_type == "CE") then
        -- Giraffe's
        write_byte(0x59A34C, rider_ejection)
    else
        write_byte(0x6163EC, rider_ejection)
    end
    -- ======================================== --
end

function WelcomeHandler(PlayerIndex)
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    ServerName = read_widestring(network_struct + 0x8, 0x42)
    execute_command("msg_prefix \"\"")
    say(PlayerIndex, "Welcome to " .. ServerName)
    say(PlayerIndex, "Type @info if you don't know How to Play")
    say(PlayerIndex, "Type @stats to view your current stats.")
    execute_command("msg_prefix \"** SERVER ** \"")
end

function InfoHandler(PlayerIndex)
    execute_command("msg_prefix \"\"")
    say(PlayerIndex, "This is a progression based game - kill players to gain a Level.")
    say(PlayerIndex, "You will start with a Shotgun (no ammo) and 6 of each grenade.")
    say(PlayerIndex, "Level 1 Objective: Melee or Nades!")
    say(PlayerIndex, "Being meeled or committing suicide will result in moving down a Level.")
    say(PlayerIndex, "There is a flag somewhere on the map - Return it to a base to gain a Level.")
    execute_command("msg_prefix \"** SERVER ** \"")
end

function OnNewGame()
    game_over = false
    CheckType()
    LoadItems()
    MAP_NAME = get_var(1, "$map")
    gametype = get_var(0, "$gt")
    flag_init_respawn = 0
    flag_init_warn = 0
    for i = 1, 16 do
        if player_present(i) then
            DAMAGE_APPLIED[i] = 0
            current_players = current_players + 1
            local PLAYER_ID = get_var(i, "$n")
            PLAYERS_ALIVE[PLAYER_ID].VEHICLE = nil
            PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
            PLAYERS_ALIVE[PLAYER_ID].FLAG = false
        end
    end
    if ctf_enabled == true then
        SPAWN_FLAG()
    end
    if MAP_NAME == "bloodgulch" or MAP_NAME == "timberland" or MAP_NAME == "sidewinder"
        or MAP_NAME == "dangercanyon" or MAP_NAME == "deathisland" or MAP_NAME == "icefields" or MAP_NAME == "infinity" then
        LargeMapConfiguration = true
        LoadLarge()
    end
    -- gephyrophobia = WIP --
    if MAP_NAME == "beavercreek" or MAP_NAME == "boardingaction" or MAP_NAME == "carousel"
        or MAP_NAME == "chillout" or MAP_NAME == "damnation" or MAP_NAME == "gephyrophobia"
        or MAP_NAME == "hangemhigh" or MAP_NAME == "longest" or MAP_NAME == "prisoner"
        or MAP_NAME == "putput" or MAP_NAME == "ratrace" or MAP_NAME == "wizard" then
        LargeMapConfiguration = false
        LoadSmall()
    end
    for k, v in pairs(EQUIPMENT_TABLE) do
        if string.find(v[1], "powerups") then
            v[11] = v[1]
            v[12] = 1
        else
            v[11] = v[1]
            v[12] = 0
        end
    end
    for k, v in pairs(WEAPON_TABLE) do
        if string.find(v[1], "weapons") then
            v[11] = v[1]
            v[12] = 1
        else
            v[11] = v[1]
            v[12] = 0
        end
    end
end

function OnGameEnd()
    Level = { }
    current_players = 0
    rider_ejection = nil
    object_table_ptr = nil
    for i = 1, 16 do
        if player_present(i) then
            TIMER[i] = false
            PROGRESSION_TIMER[i] = false
            DAMAGE_APPLIED[i] = 0
            local PLAYER_ID = get_var(i, "$n")
            FLAG_BOOL[i] = nil
            PLAYERS_ALIVE[PLAYER_ID].VEHICLE = nil
            PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
            PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
            PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
        end
    end
end

function SPAWN_FLAG()
    MAP_NAME = get_var(1, "$map")
    flag_table = FLAG[MAP_NAME][3]
    -- Spawn flag at x,y,z
    flag_objId = spawn_object("weap", "weapons\\flag\\flag", flag_table[1], flag_table[2], flag_table[3])
end

function FragCheck(PlayerIndex)
    local plasma_bool = false
    local player_object = get_dynamic_player(PlayerIndex)
    safe_read(true)
    local frags = read_byte(player_object + 0x31E)
    safe_read(false)
    if tonumber(frags) <= 0 then
        return true
    end
    return false
end

function PlasmaCheck(PlayerIndex)
    local plasma_bool = false
    local player_object = get_dynamic_player(PlayerIndex)
    safe_read(true)
    local plasmas = read_byte(player_object + 0x31F)
    safe_read(false)
    if tonumber(plasmas) <= 0 then
        return true
    end
    return false
end

function PlayerAlive(PlayerIndex)
    if player_present(PlayerIndex) then
        if (player_alive(PlayerIndex)) then
            return true
        else
            return false
        end
    end
end

function RewardPlayer(PlayerIndex)
    if GetLevel(PlayerIndex) >= 1 and GetLevel(PlayerIndex) <= 6 then
        local PLAYER_ID = get_var(PlayerIndex, "$n")
        local player_object = get_dynamic_player(PlayerIndex)
        local x, y, z = read_vector3d(player_object + 0x5C)
        local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE, 2)
        spawn_object(tostring(eqip_type_id), EQUIPMENT_TABLE[players[PlayerIndex][1]][11], x, y, z + 0.5)
        -- Pick Camouflage or Overshield (item chosen is random)
        math.randomseed(os.time())
        local num = math.random(1, #REWARDS)
        if (tonumber(num) == 1) then
            spawn_object(tostring(eqip_type_id), REWARDS[1][1], x, y, z + 0.5)
            item = REWARDS[1][2]
        else
            spawn_object(tostring(eqip_type_id), REWARDS[2][1], x, y, z + 0.5)
            item = REWARDS[2][2]
        end
        -- To receiving player
        rprint(PlayerIndex, "You have been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)")
        rprint(PlayerIndex, "You received " .. tostring(EQUIPMENT_TABLE[players[PlayerIndex][1]][2]) .. " and " .. tostring(item))
        -- To all other players
        AnnounceChat(get_var(PlayerIndex, "$name") .. " has been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)", PlayerIndex)
        AnnounceChat("Rewarding him/her with " .. tostring(EQUIPMENT_TABLE[players[PlayerIndex][1]][2]) .. " and " .. tostring(item), PlayerIndex)
    end
end

function secondsToTime(seconds, places)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    if places == 2 then
        return minutes, seconds
    end
end

function OnTick()
    -- Flag Respawn Handler --
    --  If the flag is dropped, it will respawn after 30 seconds but warn players 20 seconds before hand.
    --  This doubles as a safety mechanism should the flag become glitched or stuck in a wall somewhere.
    for p = 1, 16 do
        if player_present(p) then
            -- WARNING --
            if (FLAG_WARN[p] == true) then
                flag_init_warn = flag_init_warn + 0.030
                warning_timer = flag_init_warn
                -- local minutes, seconds = secondsToTime(warning_timer, 2)
                -- cprint("Flag will respawn in: " .. math.floor(seconds) .. " seconds")
                if warning_timer > math.floor(flag_warning) then
                    FLAG_WARN[p] = false
                    local minutes, seconds = secondsToTime(warning_timer, 2)
                    execute_command("msg_prefix \"\"")
                    say_all("The flag will respawn in " .. math.floor(flag_respawn_timer - flag_warning) .. " seconds if it's not picked up!")
                    execute_command("msg_prefix \"** SERVER ** \"")
                end
            end
            -- RESPAWN FLAG --
            if (FLAG_RESPAWN[p] == true) then
                flag_init_respawn = flag_init_respawn + 0.030
                respawn_timer = flag_init_respawn
                -- local minutes, seconds = secondsToTime(respawn_timer, 2)
                -- cprint("Flag will respawn in: " .. math.floor(seconds) .. " seconds")
                if flag_init_respawn >= math.floor(flag_respawn_timer) then
                    FLAG_RESPAWN[p] = false
                    local flag = get_object_memory(flag_objId)
                    -- destroy old flag --
                    destroy_object(flag_objId)
                    -- spawn new flag --
                    SPAWN_FLAG()
                    execute_command("msg_prefix \"\"")
                    say_all("The flag has been re-spawned!")
                    execute_command("msg_prefix \"** SERVER ** \"")
                end
            end
        end
    end
    -- Monitor players in vehicles --
    for m = 1, 16 do
        if (player_alive(m)) then
            if PlayerInVehicle(m) then
                local player = get_dynamic_player(m)
                local vehicle_id = read_dword(player + 0x11C)
                if (vehicle_id ~= 0xFFFFFFFF) then
                    local vehicle = get_object_memory(vehicle_id)
                    local PLAYER_ID = get_var(m, "$n")
                    -- Create table key for unique player in this vehicle.
                    -- Used to destroy their vehicle when they quit.
                    PLAYERS_ALIVE[PLAYER_ID].VEHICLE = vehicle_id
                end
            end
        end
    end
    -- Monitor players who're alive --
    if (survivor_rewards == true) then
        for o = 1, 16 do
            if player_present(o) then
                -- If there two or mores players on the server, run the timers.
                if current_players >= 2 then
                    if (TIMER[o] ~= false and PlayerAlive(o) == true) then
                        local PLAYER_ID = get_var(o, "$n")
                        PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE + 0.030
                        --[[
                        -- debugging --
                        local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE, 2)
                        cprint(get_var(o, "$name") .. " has been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)")
                        ]]
                        if PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE >= math.floor(allocated_time) then
                            -- Reset --
                            TIMER[o] = false
                            survivor = tonumber(o)
                            RewardPlayer(o)
                            -- Not Currently Used --
                            -- SetNav(o)
                        end
                    end
                    -- player has been alive for "progression_timer" (3 minutes by default). Level them up.
                    if (PROGRESSION_TIMER[o] ~= false and PlayerAlive(o) == true) then
                        local PLAYER_ID = get_var(o, "$n")
                        PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE + 0.030
                        --[[
                        -- debugging --
                        local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE, 2)
                        cprint(get_var(o, "$name") .. " has been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)")
                        ]]
                        if PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE >= math.floor(progression_timer) then
                            local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE, 2)
                            if (o == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                                -- Reset --
                                PROGRESSION_TIMER[o] = false
                                -- Force player to drop the flag otherwise it will be deleted. (Blame WeaponHandler)
                                drop_weapon(o)
                                CheckPlayer(o)
                                local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE, 2)
                                -- to player who triggered the timer --
                                execute_command("msg_prefix \"\"")
                                say(o, "You have been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)")
                                say(o, "Leveling up!")
                                execute_command("msg_prefix \"** SERVER ** \"")
                                -- to all other players --
                                AnnounceChat(get_var(o, "$name") .. " has been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s) without dying!", o)
                            else
                                -- Reset --
                                PROGRESSION_TIMER[o] = false
                                CheckPlayer(o)
                                local minutes, seconds = secondsToTime(PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE, 2)
                                -- to player who triggered the timer --
                                execute_command("msg_prefix \"\"")
                                say(o, "You have been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s)")
                                say(o, "Leveling up!")
                                execute_command("msg_prefix \"** SERVER ** \"")
                                -- to all other players --
                                AnnounceChat(get_var(o, "$name") .. " has been alive for " .. math.floor(minutes) .. " minute(s) and " .. math.floor(seconds) .. " second(s) without dying!", o)
                            end
                        end
                    end
                end
            end
        end
    end
    for i = 1, 16 do
        if (player_alive(i)) then
            if FRAG_CHECK[i] and FragCheck(i) == false then
                FRAG_CHECK[i] = nil
            elseif FragCheck(i) and FRAG_CHECK[i] == nil then
                FRAG_CHECK[i] = false
                execute_command("msg_prefix \"\"")
                say(i, "Woah! You're out of frag grenades!")
                execute_command("msg_prefix \"** SERVER ** \"")
            end
            if PLASMA_CHECK[i] and PlasmaCheck(i) == false then
                PLASMA_CHECK[i] = nil
            elseif PlasmaCheck(i) and PLASMA_CHECK[i] == nil then
                PLASMA_CHECK[i] = false
                execute_command("msg_prefix \"\"")
                say(i, "Woah! You're out of plasma grenades!")
                execute_command("msg_prefix \"** SERVER ** \"")
            end
        end
    end
    for j = 1, 16 do
        if (player_alive(j)) then
            -- Monitor players
            if (CheckForFlag(j) == false and FLAG_BOOL[j]) then
                local PLAYER_ID = get_var(j, "$n")
                PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
                FLAG_BOOL[j] = nil
            end
            if (CheckForFlag(j) == true) then
                -- Player is current flag holder, monitor them until they: CAPTURE, DROP, DIE, QUIT, RESPAWN
                local PLAYER_ID = get_var(j, "$n")
                PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER =(j)

                -- Set player speed
                execute_command("s " .. j .. " :" .. tonumber(FLAG[MAP_NAME][4][1]))

                -- Blue Base
                if inSphere(j, FLAG[MAP_NAME][1][1], FLAG[MAP_NAME][1][2], FLAG[MAP_NAME][1][3], Check_Radius) == true
                    -- Red Base
                    or inSphere(j, FLAG[MAP_NAME][2][1], FLAG[MAP_NAME][2][2], FLAG[MAP_NAME][2][3], Check_Radius) == true then
                    if PlayerInVehicle(j) then
                        -- Clear their console
                        cls(j)
                        rprint(j, "|c-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-")
                        rprint(j, "|cYou have to get out of your vehicle to score!")
                        rprint(j, "|c-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-")
                        rprint(j, "|c")
                        rprint(j, "|c")
                        rprint(j, "|c")
                    else
                        -- level up (update, advance)
                        ctf_score(j)
                        AnnounceChat("[CAPTURE] " .. get_var(j, "$name") .. " captured a flag!", j)
                        execute_command("s " .. j .. " :" .. tonumber(Default_Running_Speed))
                    end
                end
            end
            -- player has the flag --
            if (CheckForFlag(j) and FLAG_BOOL[j] == nil) then
                FLAG_BOOL[j] = true
                AnnounceChat(get_var(j, "$name") .. " has the flag!", j)
                -- Clear their console
                if game_over then  
                    -- do nothing
                else
                    cls(j)
                    rprint(j, "|cReturn the flag to a base to gain a level")
                    rprint(j, "|c ")
                    rprint(j, "|c ")
                    rprint(j, "|c ")
                    rprint(j, "|c ")
                end
            end
        end
    end
    -- Giraffe's Fucntion --
    if (PLAYER_VEHICLES_ONLY) then
        for k = 1, 16 do
            if (player_alive(k)) then
                local player = get_dynamic_player(k)
                local player_vehicle_id = read_dword(player + 0x11C)
                if (player_vehicle_id ~= 0xFFFFFFFF) then
                    local vehicle = get_object_memory(player_vehicle_id)
                    flip_vehicle(vehicle)
                end
            end
        end
    else
        local object_table = read_dword(read_dword(object_table_ptr + 2))
        local object_count = read_word(object_table + 0x2E)
        local first_object = read_dword(object_table + 0x34)
        for l = 0, object_count - 1 do
            local object = read_dword(first_object + l * 0xC + 0x8)
            if (object ~= 0 and object ~= 0xFFFFFFFF) then
                if (read_word(object + 0xB4) == 1) then
                    flip_vehicle(object)
                end
            end
        end
    end
end

function OnWeaponPickup(PlayerIndex, WeaponIndex, Type)
    if tonumber(Type) == 1 then
        local PlayerObj = get_dynamic_player(PlayerIndex)
        local WeaponObj = get_object_memory(read_dword(PlayerObj + 0x2F8 +(tonumber(WeaponIndex) -1) * 4))
        local name = read_string(read_dword(read_word(WeaponObj) * 32 + 0x40440038))
        if (name == "weapons\\flag\\flag") then
            -- reset flag respawn timers for all players --
            for i = 1, 16 do
                FLAG_RESPAWN[i] = false
                FLAG_WARN[i] = false
                flag_init_respawn = 0
                flag_init_warn = 0
            end
        end
    end
end

function OnWeaponDrop(PlayerIndex)
    -- initiate flag respawn timers --
    FLAG_RESPAWN[PlayerIndex] = true
    FLAG_WARN[PlayerIndex] = true
    -- Set default running speed for player who just dropped the flag.
    if player_alive(PlayerIndex) then
        local PLAYER_ID = get_var(PlayerIndex, "$n")
        if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
            execute_command("s " .. PlayerIndex .. " :" .. tonumber(Default_Running_Speed))
        end
    end
end

function flip_vehicle(Object)
    -- Giraffe's Fucntion --
    if (read_bit(Object + 0x8B, 7) == 1) then
        if (WAIT_FOR_IMPACT and read_bit(Object + 0x10, 1) == 0) then
            return
        end
        write_vector3d(Object + 0x80, 0, 0, 1)
    end
end

function OnVehicleExit(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if player_object ~= 0 then
        local Vehicle_ID = read_dword(player_object + 0x11C)
        exit_vehicle(PlayerIndex)
        timer(1000 * 2, "DestroyVehicle", Vehicle_ID)
        local PlayerObj = get_dynamic_player(PlayerIndex)
        local VehicleObj = get_object_memory(read_dword(PlayerObj + 0x11c))
        local VehicleName = read_string(read_dword(read_word(VehicleObj) * 32 + 0x40440038))
        if VehicleName == "vehicles\\warthog\\mp_warthog" then
            delay = 1000 * 1.1
        elseif VehicleName == "vehicles\\rwarthog\\rwarthog" then
            delay = 1000 * 1.1
        elseif VehicleName == "vehicles\\scorpion\\scorpion_mp" then
            delay = 1000 * 2
        elseif VehicleName == "vehicles\\ghost\\ghost_mp" then
            delay = 1000 * 1.1
        elseif VehicleName == "vehicles\\banshee\\banshee_mp" then
            delay = 1000 * 1.1
        elseif VehicleName == "vehicles\\c gun turret\\c gun turret_mp" then
            delay = 1000 * 1.1
        end
        -- temporary weapon assignment on vehicle exit --
        timer(delay, "AssignTemp", PlayerIndex)
        execute_command("msg_prefix \"\"")
        say(PlayerIndex, get_var(PlayerIndex, "$name") .. ', type "/enter me" to enter your previous vehicle.')
        execute_command("msg_prefix \"** SERVER ** \"")
    end
end

function AssignTemp(PlayerIndex)
    -- ready to fire
    local loaded = 12
    -- backup
    local unloaded = 24
    -- wait_time = time until ammo is updated for new weapon (in seconds)
    -- Do not go lower than 1 second!
    local wait_time = 1
    local player_object = get_dynamic_player(PlayerIndex)
    local x, y, z = read_vector3d(player_object + 0x5C)
    local weapid = assign_weapon(spawn_object("weap", out_of_vehicle_weapon, x, y, z + 0.5), PlayerIndex)
    if tonumber(ammo_multiplier) then
        execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. loaded)
        execute_command_sequence("w8 " .. wait_time .. "; ammo " .. PlayerIndex .. " " .. unloaded)
    end
end

-- Only works when "Kill In Order" is ON and Objectives Indicator is set to Nav Markers
function SetNav(survivor)
    if survivor ~= 0 then
        local player = to_real_index(survivor)
        write_word(get_player(survivor) + 0x88, player)
    end
end

function OnPlayerDeath(PlayerIndex, KillerIndex)
    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)
    VictimName = get_var(PlayerIndex, "$name")
    KillerName = get_var(KillerIndex, "$name")
    execute_command("msg_prefix \"\"")
    -- Instant respawn time (for debugging) --
    -- local player = get_player(PlayerIndex)
    -- write_dword(player + 0x2C, 1 * 33)
    ------------------------------------------
    -- If victim was in a vehicle, destroy it...
    local player_object = get_dynamic_player(victim)
    if PlayerInVehicle(victim) then
        if player_object ~= 0 then
            local Vehicle_ID = read_dword(player_object + 0x11C)
            timer(0, "DestroyVehicle", Vehicle_ID)
        end
    end
    -- PvP --
    if (killer > 0) and(victim ~= killer)--[[ and get_var(victim, "$team") ~= get_var(killer, "$team") ]] then
        say_all(VictimName .. " was killed by " .. KillerName)
        local PLAYER_ID = get_var(victim, "$n")
        if (victim == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
            -- initiate flag respawn timers --
            FLAG_RESPAWN[PlayerIndex] = true
            FLAG_WARN[PlayerIndex] = true
        end
        if DAMAGE_APPLIED[PlayerIndex] == MELEE_ASSAULT_RIFLE or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_FLAME_THROWER or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_NEEDLER or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_PISTOL or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_PLASMA_PISTOL or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_PLASMA_RIFLE or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_PLASMA_CANNON or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_ROCKET_LAUNCHER or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_SHOTGUN or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_SNIPER_RIFLE or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_ODDBALL or
            DAMAGE_APPLIED[PlayerIndex] == MELEE_FLAG then
            local PLAYER_ID = get_var(victim, "$n")
            -- Assign table key to Victim --
            PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = victim
            if (victim == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) and(victim == PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM) then
                -- Drop the flag, otherwise it will be deleted - Blame the WeaponHandler.
                drop_weapon(victim)
                
                -- Alternatively, respawn it. (currently disabled out of preference)
                -- SPAWN_FLAG()
                
                -- Reset Melee Victim
                PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
            end
            -- Player was melee'd, move them down a level (update, level down)
            cycle_level(victim, true)
            AnnounceChat(VictimName .. " was meleed and is now Level " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level), PlayerIndex)
        end
        -- Add kill to Killer
        add_kill(killer, victim)
        if Spawn_Where_Killed == true then
            local player_object = get_dynamic_player(victim)
            local xAxis, yAxis, zAxis = read_vector3d(player_object + 0x5C)
            PLAYER_LOCATION[victim][1] = xAxis
            PLAYER_LOCATION[victim][2] = yAxis
            PLAYER_LOCATION[victim][3] = zAxis
            if (PowerUpSettings["WeaponsAndEquipment"] == true) then
                WeaponsAndEquipment(xAxis, yAxis, zAxis)
            elseif (PowerUpSettings["JustEquipment"] == true) then
                JustEquipment(xAxis, yAxis, zAxis)
            elseif (PowerUpSettings["JustWeapons"] == true) then
                JustWeapons(xAxis, yAxis, zAxis)
            end
        end
        -- SUICIDE --
    elseif tonumber(PlayerIndex) == tonumber(KillerIndex) then
        say(PlayerIndex, VictimName .. " committed suicide")
        AnnounceChat(VictimName .. " committed suicide and is now Level " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level), PlayerIndex)
        local PLAYER_ID = get_var(victim, "$n")
        PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = victim
        if (victim == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
            -- Drop the flag, otherwise it will be deleted - Blame the WeaponHandler.
            drop_weapon(victim)
            -- Alternatively, respawn it. (currently disabled out of preference)
            -- SPAWN_FLAG()
        end
        -- Player Committed Suicide, move them down a level
        -- update, level down
        cycle_level(victim, true)
        if Spawn_Where_Killed == true then
            local player_object = get_dynamic_player(victim)
            local xAxis, yAxis, zAxis = read_vector3d(player_object + 0x5C)
            PLAYER_LOCATION[victim][1] = xAxis
            PLAYER_LOCATION[victim][2] = yAxis
            PLAYER_LOCATION[victim][3] = zAxis
            if (PowerUpSettings["WeaponsAndEquipment"] == true) then
                WeaponsAndEquipment(xAxis, yAxis, zAxis)
            elseif (PowerUpSettings["JustEquipment"] == true) then
                JustEquipment(xAxis, yAxis, zAxis)
            elseif (PowerUpSettings["JustWeapons"] == true) then
                JustWeapons(xAxis, yAxis, zAxis)
            end
        end
        timer(500, "delay_score", PlayerIndex)
        timer(500, "delay_score", KillerIndex)
    end
    -- KILLED BY SERVER --
    if (killer == -1) then
        say_all(VictimName .. " died")
        return false
    end
    -- UNKNOWN/GLITCHED --
    if (killer == nil) then
        say_all(VictimName .. " died")
        return false
    end
    -- KILLED BY VEHICLE --
    if (killer == 0) then
        say_all(VictimName .. " died")
        return false
    end
    DAMAGE_APPLIED[PlayerIndex] = 0
    execute_command("msg_prefix \"** SERVER ** \"")
end

function add_kill(killer, victim)
    -- add on a kill
    local kills = players[killer][2]
    players[killer][2] = kills + 1
    -- check to see if player advances
    if players[killer][2] == Level[players[killer][1]][4] then
        local PLAYER_ID = get_var(killer, "$n")
        if (killer == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
            drop_weapon(killer)
            -- Killer Melee'd someone while holding the flag - delay scoring to avoid deleting their flag on cycle_level.
            timer(1, "delay_cycle", killer)
        else
            -- PvP, update, advance (level up)
            cycle_level(killer, true, true)
        end
    end
end

function DropPowerup(x, y, z)
    local num = rand(1, #EQUIPMENT_TAGS)
    spawn_object(EQUIPMENT_TAGS[num], x, y, z + 0.5)
end

function OnPlayerJoin(PlayerIndex)
    current_players = current_players + 1
    -- set level
    players[PlayerIndex] = { Starting_Level, 0 }

    if PlayerIndex ~= 0 then
        local saved_data = get_var(PlayerIndex, "$hash") .. ":" .. get_var(PlayerIndex, "$name")
        -- Check for Previous Statistics --
        for k, v in pairs(STORED_LEVELS) do
            if tostring(k) == tostring(saved_data) then
                say(PlayerIndex, "Your previous level has been saved and restored!")
                players[PlayerIndex][1] = STORED_LEVELS[saved_data][1]
                players[PlayerIndex][2] = STORED_LEVELS[saved_data][2]
                break
            end
        end
    end
    
    timer(1000 * 6, "WelcomeHandler", PlayerIndex)
    -- Update score to reflect changes.
    -- First initial score is equal to Level 1 (score point 1)
    setscore(PlayerIndex, players[PlayerIndex][1])
    local PLAYER_ID = get_var(PlayerIndex, "$n")
    PLAYERS_ALIVE[PLAYER_ID] = { }
    PLAYERS_ALIVE[PLAYER_ID].VEHICLE = nil
    PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
    PLAYERS_ALIVE[PLAYER_ID].CAPTURES = 0
    PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
    PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
    PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
    PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
    PLAYERS_ALIVE[PLAYER_ID].FLAG = 0
end

function OnPlayerLeave(PlayerIndex)
    current_players = current_players - 1
    local PLAYER_ID = get_var(PlayerIndex, "$n")
    PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
    PLAYERS_ALIVE[PLAYER_ID].CAPTURES = 0
    PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
    PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
    PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
    PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
    DAMAGE_APPLIED[PlayerIndex] = nil
    if game_over then
        -- do nothing
    else
        if PlayerIndex ~= 0 then
            local saved_data = get_var(PlayerIndex, "$hash") .. ":" .. get_var(PlayerIndex, "$name")
            -- Create Table Key for Player --
            STORED_LEVELS[saved_data] = { players[PlayerIndex][1], players[PlayerIndex][2] }
        end
    end
    -- Wipe Saved Spawn Locations
    for i = 1, 3 do
        -- reset death location --
        PLAYER_LOCATION[PlayerIndex][i] = nil
    end
    -- destroy vehicle --
    local PLAYER_ID = get_var(PlayerIndex, "$n")
    if PLAYERS_ALIVE[PLAYER_ID].VEHICLE ~= nil then
        destroy_object(PLAYERS_ALIVE[PLAYER_ID].VEHICLE)
    end
end

function OnPlayerPrespawn(PlayerIndex)
    
    -- temporarily disabled --
    --[[
    -- reset last damage --
    DAMAGE_APPLIED[PlayerIndex] = 0
    ]]
    
    if spawn_where_killed == true then
        local victim = tonumber(PlayerIndex)
        if PlayerIndex then
            if PLAYER_LOCATION[victim][1] ~= nil then
                -- spawn at death location --
                write_vector3d(get_dynamic_player(victim) + 0x5C, PLAYER_LOCATION[victim][1], PLAYER_LOCATION[victim][2], PLAYER_LOCATION[victim][3])
                for i = 1, 3 do
                    -- reset death location --
                    PLAYER_LOCATION[victim][i] = nil
                end
            end
        end
    end
end

function OnPlayerSpawn(PlayerIndex)
    if getplayer(PlayerIndex) then
        -- Clear their console
        cls(PlayerIndex)
        --  assign weapons or vehicle according to level --
        if (LargeMapConfiguration == true) then
            WeaponHandler(PlayerIndex)
        elseif (LargeMapConfiguration == false) then
            WeaponHandlerAlternate(PlayerIndex)
        end
        --  Setup Invulnerable Timer --
        if Spawn_Invunrable_Time ~= nil and Spawn_Invunrable_Time > 0 then
            -- Health. (0 to 1) (Normal = 1)
            write_float(PlayerIndex + 0xE0, 99999999)
            -- Overshield. (0 to 3) (Normal = 1) (Full overshield = 3)
            write_float(PlayerIndex + 0xE4, 3)
            timer(Spawn_Invunrable_Time * 1000, "RemoveSpawnProtection", PlayerIndex)
        end
        rprint(PlayerIndex, "Level: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level))
        rprint(PlayerIndex, "Kills Needed to Advance: " .. tostring(Level[players[PlayerIndex][1]][4]))
        rprint(PlayerIndex, "Your Weapon: " .. tostring(Level[players[PlayerIndex][1]][2]))
        rprint(PlayerIndex, "Your Instructions: " .. tostring(Level[players[PlayerIndex][1]][3]))
        rprint(PlayerIndex, " ")
        ammo_multiplier = tonumber(Level[players[PlayerIndex][1]][6])
        -- Reset --
        TIMER[PlayerIndex] = true
        PROGRESSION_TIMER[PlayerIndex] = true
        local PLAYER_ID = get_var(PlayerIndex, "$n")
        PLAYERS_ALIVE[PLAYER_ID].TIME_ALIVE = 0
        PLAYERS_ALIVE[PLAYER_ID].PROGRESSION_TIME_ALIVE = 0
        PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM = nil
        PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM = nil
        PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
        PLAYERS_ALIVE[PLAYER_ID].FLAG = 0
        execute_command("s " .. PlayerIndex .. " :" .. tonumber(Default_Running_Speed))
    end
end

function CheckForFlag(PlayerIndex)
    local bool = false
    local player_object = get_dynamic_player(PlayerIndex)
    for i = 0, 3 do
        local weapon_id = read_dword(player_object + 0x2F8 + 0x4 * i)
        if (weapon_id ~= 0xFFFFFFFF) then
            local weap_object = get_object_memory(weapon_id)
            if (weap_object ~= 0) then
                local obj_type = read_byte(weap_object + 0xB4)
                local tag_address = read_word(weap_object)
                local tagdata = read_dword(read_dword(0x40440000) + tag_address * 0x20 + 0x14)
                if (read_bit(tagdata + 0x308, 3) == 1) then
                    bool = true
                end
            end
        end
    end
    return bool
end

function OnWin(Message, PlayerIndex)
    for i = 1, 16 do
        if player_present(i) then
            if i ~= PlayerIndex then
                rprint(i, "|c" .. Message)
            end
        end
    end
end

function AnnounceChat(Message, PlayerIndex)
    for i = 1, 16 do
        if player_present(i) then
            if i ~= PlayerIndex then
                -- Clear their console
                cls(i)
                execute_command("msg_prefix \"\"")
                say(i, " " .. Message)
                execute_command("msg_prefix \"** SERVER ** \"")
            end
        end
    end
end

-- Check if player is in Sphere (X, Y, Z, Radius)
function inSphere(PlayerIndex, x, y, z, radius)
    if PlayerIndex then
        local player_static = get_player(PlayerIndex)
        local obj_x = read_float(player_static + 0xF8)
        local obj_y = read_float(player_static + 0xFC)
        local obj_z = read_float(player_static + 0x100)
        local x_diff = x - obj_x
        local y_diff = y - obj_y
        local z_diff = z - obj_z
        local dist_from_center = math.sqrt(x_diff ^ 2 + y_diff ^ 2 + z_diff ^ 2)
        if dist_from_center <= radius then
            return true
        end
    end
    return false
end

-- Move ObjectID to X,Y,Z
function moveobject(ObjectID, x, y, z)
    local object = get_object_memory(ObjectID)
    if get_object_memory(ObjectID) ~= 0 then
        local veh_obj = get_object_memory(read_dword(object + 0x11C))
        write_vector3d((veh_obj ~= 0 and veh_obj or object) + 0x5C, x, y, z)
    end
end

-- When a player is in the scoring area (sphere) of a base while holding the flag, update their score accordingly.
function ctf_score(PlayerIndex)
    -- Update, advance (level up)
    cycle_level(PlayerIndex, true, true)
    
    -- reset flag respawn timers --
    FLAG_RESPAWN[PlayerIndex] = false
    FLAG_WARN[PlayerIndex] = false
    flag_init_respawn = 0
    flag_init_warn = 0
    timer(300, "delay_move", PlayerIndex)
    local PLAYER_ID = get_var(PlayerIndex, "$n")
    PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER = nil
    PLAYERS_ALIVE[PLAYER_ID].CAPTURES = PLAYERS_ALIVE[PLAYER_ID].CAPTURES + 1
    if game_over then  
        -- reset flag respawn timers --
        FLAG_RESPAWN[PlayerIndex] = false
        FLAG_WARN[PlayerIndex] = false
        flag_init_respawn = 0
        flag_init_warn = 0
    else
        SPAWN_FLAG()
        execute_command("msg_prefix \"\"")
        say(PlayerIndex, "[CAPTURE] You have " .. tonumber(math.floor(PLAYERS_ALIVE[PLAYER_ID].CAPTURES)) .. " flag captures!")
        execute_command("msg_prefix \"** SERVER ** \"")
    end
end

-- Check if player is in Scoring area. If they are, call "delay_move".
function CheckPlayer(PlayerIndex)
    -- Update, advance (level up)
    cycle_level(PlayerIndex, true, true)
    radius = 3
    if inSphere(PlayerIndex, FLAG[MAP_NAME][1][1], FLAG[MAP_NAME][1][2], FLAG[MAP_NAME][1][3], radius) == true
        or inSphere(PlayerIndex, FLAG[MAP_NAME][2][1], FLAG[MAP_NAME][2][2], FLAG[MAP_NAME][2][3], radius) == true then
        timer(300, "delay_move", PlayerIndex)
    end
end

-- Note to self: Re-calculate coordinates for all maps except bloodgulch.

-- Player is ranking up to a Vehicle Level. If they score on a map where the flag is located 'inside' a building,
-- move them outside the building upon leveling up. Otherwise they might get stuck inside the walls of the building.
function delay_move(PlayerIndex)
    if PlayerInVehicle(PlayerIndex) then
        local player_object = get_dynamic_player(PlayerIndex)
        local VehicleObj = get_object_memory(read_dword(player_object + 0x11c))
        local seat = read_word(player_object + 0x2F0)
        if (VehicleObj ~= 0) and(seat == 0) or(seat == 1) or(seat == 2) or(seat == 3) or(seat == 4) or(seat == 5) then
            local vehicleId = read_dword(player_object + 0x11C)
            player_obj_id = read_dword(get_player(PlayerIndex) + 0x34)
            player_obj_id = vehicleId
            local added_height = 0.3
            -- [!] -- Red Base, Blue Base
            -- inSphere Red, else inSphere Blue base
            if (MAP_NAME == "bloodgulch") then
                if inSphere(PlayerIndex, 95.687797546387, -159.44900512695, -0.10000000149012, 3) == true then
                    moveobject(vehicleId, 95.01, -150.62, 0.07 + added_height)
                else
                    moveobject(vehicleId, 35.87, -70.73, 0.02 + added_height)
                end
            elseif (MAP_NAME == "deathisland") then
                if inSphere(PlayerIndex, -26.576030731201, -6.9761986732483, 9.6631727218628, 3) == true then
                    moveobject(vehicleId, -30.59, -1.81, 9.43 + added_height)
                else
                    moveobject(vehicleId, 33.06, 11.04, 8.05 + added_height)
                end
            elseif (MAP_NAME == "icefields") then
                if inSphere(PlayerIndex, 24.85000038147, -22.110000610352, 2.1110000610352, 3) == true then
                    moveobject(vehicleId, 33.98, -25.61, 0.84 + added_height)
                else
                    moveobject(vehicleId, -86.37, 83.64, 0.87 + added_height)
                end
            elseif (MAP_NAME == "infinity") then
                if inSphere(PlayerIndex, 0.67973816394806, -164.56719970703, 15.039022445679, 3) == true then
                    moveobject(vehicleId, 6.54, -160, 13.76 + added_height)
                else
                    moveobject(vehicleId, -6.23, 41.98, 10.48 + added_height)
                end
            elseif (MAP_NAME == "sidewinder") then
                if inSphere(PlayerIndex, -32.038, -42.067, -3.831, 3) == true then
                    moveobject(vehicleId, -32.73, -25.67, -3.81 + added_height)
                elseif inSphere(PlayerIndex, 30.351, -46.108, -3.831, 3) == true then
                    moveobject(vehicleId, 30.37, -29.36, -3.59 + added_height)
                end
            elseif (MAP_NAME == "timberland") then
                if inSphere(PlayerIndex, 17.322099685669, -52.365001678467, -17.751399993896, 3) == true then
                    moveobject(vehicleId, 16.93, -43.98, -18.16 + added_height)
                else
                    moveobject(vehicleId, 3 - 15.02, 45.36, -18 + added_height)
                end
            end
        end
    end
end

function delay_score(id, count, PlayerIndex)
    if PlayerIndex then
        setscore(PlayerIndex, players[PlayerIndex][1])
    end
    return 0
end

function delay_cycle(killer)
    local Player = tonumber(killer)
    -- Update, advance (level up)
    cycle_level(Player, true, true)
end

function delay_cycle_command(PlayerIndex)
    local Player = tonumber(PlayerIndex)
    if level_up then
        -- Update, advance (level up)
        cycle_level(Player, true, true)
    end
    if level_down then
        -- Update, (level down)
        cycle_level(Player, true)
    end
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    DAMAGE_APPLIED[PlayerIndex] = MetaID
    -- Ghost Bolt Damage - (double damage)
    if MetaID == VEHICLE_GHOST_BOLT then
        -- Double Damage
        return true, Damage * 2
    end
    -- Assault Rifle Bullets (double damage)
    if MetaID == ASSAULT_RIFLE_BULLET then
        -- Double Damage
        return true, Damage * 2
    end
    -- Multiply grenade damage by the value of "Grenade_Multiplier" - Equal to 4 by design default. 1 = normal game value
    if MetaID == GRENADE_FRAG_EXPLOSION or MetaID == GRENADE_PLASMA_ATTACHED or MetaID == GRENADE_PLASMA_EXPLOSION then
        if GetLevel(PlayerIndex) == 1 then
            return true, Damage * Grenade_Multiplier
        else
            -- Double Damage
            return true, Damage * 2
        end
    end
    if MetaID == MELEE_ASSAULT_RIFLE or
        MetaID == MELEE_ODDBALL or
        MetaID == MELEE_FLAG or
        MetaID == MELEE_FLAME_THROWER or
        MetaID == MELEE_NEEDLER or
        MetaID == MELEE_PISTOL or
        MetaID == MELEE_PLASMA_PISTOL or
        MetaID == MELEE_PLASMA_RIFLE or
        MetaID == MELEE_PLASMA_CANNON or
        MetaID == MELEE_ROCKET_LAUNCHER or
        MetaID == MELEE_SHOTGUN or
        MetaID == MELEE_SNIPER_RIFLE then
        -- 4 times normal damage
        return true, Damage * Melee_Multiplier
    end
end

-- Return player's current Level --
function GetLevel(PlayerIndex)
    if tonumber(players[PlayerIndex][1]) == 1 then
        return 1
    elseif tonumber(players[PlayerIndex][1]) == 2 then
        return 2
    elseif tonumber(players[PlayerIndex][1]) == 3 then
        return 3
    elseif tonumber(players[PlayerIndex][1]) == 4 then
        return 4
    elseif tonumber(players[PlayerIndex][1]) == 5 then
        return 5
    elseif tonumber(players[PlayerIndex][1]) == 6 then
        return 6
    elseif tonumber(players[PlayerIndex][1]) == 7 then
        return 7
    elseif tonumber(players[PlayerIndex][1]) == 8 then
        return 8
    elseif tonumber(players[PlayerIndex][1]) == 9 then
        return 9
    elseif tonumber(players[PlayerIndex][1]) == 10 then
        return 10
    else
        return false
    end
end

function RemoveSpawnProtection(PlayerIndex)
    if (player_alive(PlayerIndex)) then
        -- Health. (0 to 1) (Normal = 1)
        write_float(PlayerIndex + 0xE0, 1)
        -- Overshield. (0 to 3) (Normal = 1) (Full overshield = 3)
        write_float(PlayerIndex + 0xE4, 1)
    end
end

function OnPlayerChat(PlayerIndex, Message, type)
    local response = nil
    local Message = string.lower(Message)
    if (Message == "@info") then
        timer(0, "InfoHandler", PlayerIndex)
        response = false
        return false
    end
    if (Message == "@stats") then
        if (GetLevel(PlayerIndex) >= 7) then
            rprint(PlayerIndex, "Level: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level) .. "  |  Kills Needed to Advance: " .. tostring(Level[players[PlayerIndex][1]][4]))
            rprint(PlayerIndex, "Vehicle: " .. tostring(Level[players[PlayerIndex][1]][2]))
            rprint(PlayerIndex, "Your Instructions: " .. tostring(Level[players[PlayerIndex][1]][3]))
        else
            local nades_tbl = Level[players[PlayerIndex][1]][5]
            rprint(PlayerIndex, "Level: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level) .. "  |  Kills Needed to Advance: " .. tostring(Level[players[PlayerIndex][1]][4]))
            rprint(PlayerIndex, "Weapon: " .. tostring(Level[players[PlayerIndex][1]][2]))
            rprint(PlayerIndex, "Ammo Multiplier: " .. tostring(Level[players[PlayerIndex][1]][6]))
            rprint(PlayerIndex, "Frags: " .. tostring(nades_tbl[1]))
            rprint(PlayerIndex, "Plasmas: " .. tostring(nades_tbl[2]))
            rprint(PlayerIndex, "Your Instructions: " .. tostring(Level[players[PlayerIndex][1]][3]))
        end
        response = false
    end
    return response
end

function OnServerCommand(PlayerIndex, Command, Environment)
    local response = nil
    local t = tokenizestring(Command)
    Command = string.lower(Command)
    -- RCON
    if (Environment == 1) then
        if (Command == "level_up") then
            response = false
            local PLAYER_ID = get_var(PlayerIndex, "$n")
            if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                if PlayerInVehicle(PlayerIndex) then
                    rprint(PlayerIndex, "You cannot level up while holding the flag!")
                else
                    drop_weapon(PlayerIndex)
                    timer(1, "delay_cycle_command", PlayerIndex)
                    level_up = true
                end
            else
                -- Update, advance (level up)
                cycle_level(PlayerIndex, true, true)
            end
        elseif (Command == "level_down") then
            response = false
            local PLAYER_ID = get_var(PlayerIndex, "$n")
            if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                if PlayerInVehicle(PlayerIndex) then
                    rprint(PlayerIndex, "You cannot level up while holding the flag!")
                else
                    drop_weapon(PlayerIndex)
                    timer(1, "delay_cycle_command", PlayerIndex)
                    level_up = true
                end
            else
                -- Update (level down)
                cycle_level(PlayerIndex, true)
            end
        end
    end
    -- CHAT
    if (Environment == 2) then
        if t[1] ~= nil then
            if tonumber(get_var(PlayerIndex, "$lvl")) >= ADMIN_LEVEL and(t[1] == string.lower("level")) then
                response = false
                if t[2] ~= nil then
                    if t[2] == "up" then
                        -- update, advance
                        local PLAYER_ID = get_var(PlayerIndex, "$n")
                        if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                            if PlayerInVehicle(PlayerIndex) then
                                rprint(PlayerIndex, "You cannot level up while holding the flag!")
                            else
                                drop_weapon(PlayerIndex)
                                timer(1, "delay_cycle_command", PlayerIndex)
                                level_up = true
                            end
                        else
                            -- Update, advance (level up)
                            cycle_level(PlayerIndex, true, true)
                        end
                    elseif t[2] == "down" then
                        -- update
                        local PLAYER_ID = get_var(PlayerIndex, "$n")
                        if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                            if PlayerInVehicle(PlayerIndex) then
                                rprint(PlayerIndex, "You cannot level up while holding the flag!")
                            else
                                drop_weapon(PlayerIndex)
                                timer(1, "delay_cycle_command", PlayerIndex)
                                level_up = true
                            end
                        else
                            -- Update (level down)
                            cycle_level(PlayerIndex, true)
                        end
                    else
                        rprint(PlayerIndex, "Action not defined - up or down")
                    end
                end
            end
        end
    end
    if tonumber(get_var(PlayerIndex, "$lvl")) >= -1 and(t[1] == string.lower("enter")) then
        response = false
        if (LargeMapConfiguration == true) then
            if PlayerInVehicle(PlayerIndex) then
                rprint(PlayerIndex, "You're already in a vehicle!")
            else
                if t[2] ~= nil then
                    if t[2] == "me" or(Command == "enter me") then
                        if (GetLevel(PlayerIndex) <= 6) then
                            rprint(PlayerIndex, "You're only Level: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level))
                            rprint(PlayerIndex, "You must be Level 7 or higher.")
                        elseif (GetLevel(PlayerIndex) <= 8) then
                            -- rocket hog (gunner & drivers seat)
                            local player_object = get_dynamic_player(PlayerIndex)
                            local x, y, z = read_vector3d(player_object + 0x5c)
                            vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + 0.5)
                            enter_vehicle(vehicleId, PlayerIndex, 0)
                            timer(0, "delay_gunners_seat", PlayerIndex)
                        else
                            -- all other vehicles --
                            local player_object = get_dynamic_player(PlayerIndex)
                            local x, y, z = read_vector3d(player_object + 0x5c)
                            vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + 0.5)
                            enter_vehicle(vehicleId, PlayerIndex, 0)
                        end
                    else
                        rprint(PlayerIndex, "Invalid Command. Usage: /enter me")
                    end
                else
                    rprint(PlayerIndex, "Invalid Command. Usage: /enter me")
                end
            end
        else
            rprint(PlayerIndex, "This map is not set up for vehicles!")
        end
    end
    return response
end

  -- [[ PROGRESSION HANDLER ]] --    
function cycle_level(PlayerIndex, update, advance)
    -- clear player console --
    cls(PlayerIndex)
    local current_Level = players[PlayerIndex][1]
    if advance == true then
        local cur = current_Level + 1
        -- Player has completed level 10, end game.
        if cur == (#Level + 1) then
            game_over = true
            local PLAYER_ID = get_var(PlayerIndex, "$n")
            if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                -- Delete the winner's weapons and assign them plasma pistol (for fun, because why not)
                local player_object = get_dynamic_player(PlayerIndex)
                local weaponId = read_dword(player_object + 0x118)
                if weaponId ~= 0 then
                    for j = 0, 3 do
                        local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                        destroy_object(m_weapon)
                    end
                end
                local x, y, z = read_vector3d(player_object + 0x5C)
                local weapid = assign_weapon(spawn_object("weap", "weapons\\plasma pistol\\plasma pistol", x, y, z + 0.5), PlayerIndex)
            end
            -- ON WIN --
            OnWin("--<->--<->--<->--<->--<->--<->--<->--", PlayerIndex)
            OnWin(get_var(PlayerIndex, "$name") .. " WON THE GAME!", PlayerIndex)
            OnWin("--<->--<->--<->--<->--<->--<->--<->--", PlayerIndex)
            OnWin(" ", PlayerIndex)
            OnWin(" ", PlayerIndex)
            OnWin(" ", PlayerIndex)
            -------------------------------------------------------------------------
            rprint(PlayerIndex, "|c-<->-<->-<->-<->-<->-<->-<->")
            rprint(PlayerIndex, "|cYOU WIN!")
            rprint(PlayerIndex, "|c-<->-<->-<->-<->-<->-<->-<->")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            execute_command("sv_map_next")
        end
        -- LEVEL UP
        if current_Level < #Level then
            players[PlayerIndex][1] = current_Level + 1
            local name = get_var(PlayerIndex, "$name")
            AnnounceChat(name .. " is now Level " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level) .. " and has the " .. tostring(Level[players[PlayerIndex][1]][2]), PlayerIndex)
            rprint(PlayerIndex, "|c****** LEVEL UP ******")
            rprint(PlayerIndex, "|cLevel: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level))
            rprint(PlayerIndex, "|cKills Needed to Advance: " .. tostring(Level[players[PlayerIndex][1]][4]))
            rprint(PlayerIndex, "|cYour Weapon: " .. tostring(Level[players[PlayerIndex][1]][2]))
            rprint(PlayerIndex, "|cYour Instructions: " .. tostring(Level[players[PlayerIndex][1]][3]))
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
        end
        -- Player has completed level 10, end game.
        if current_Level == (#Level + 1) then
            game_over = true
            local PLAYER_ID = get_var(PlayerIndex, "$n")
            if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].CURRENT_FLAGHOLDER) then
                -- Delete the winner's weapons and assign them plasma pistol (for fun, because why not)
                local player_object = get_dynamic_player(PlayerIndex)
                local weaponId = read_dword(player_object + 0x118)
                if weaponId ~= 0 then
                    for j = 0, 3 do
                        local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                        destroy_object(m_weapon)
                    end
                end
                local x, y, z = read_vector3d(player_object + 0x5C)
                local weapid = assign_weapon(spawn_object("weap", "weapons\\plasma pistol\\plasma pistol", x, y, z + 0.5), PlayerIndex)
            end
            -- ON WIN --
            OnWin("--<->--<->--<->--<->--<->--<->--<->--", PlayerIndex)
            OnWin(get_var(PlayerIndex, "$name") .. " WON THE GAME!", PlayerIndex)
            OnWin("--<->--<->--<->--<->--<->--<->--<->--", PlayerIndex)
            OnWin(" ", PlayerIndex)
            OnWin(" ", PlayerIndex)
            OnWin(" ", PlayerIndex)
            OnWin(" ", PlayerIndex)
            -------------------------------------------------------------------------
            rprint(PlayerIndex, "|c-<->-<->-<->-<->-<->-<->-<->")
            rprint(PlayerIndex, "|cYOU WIN!")
            rprint(PlayerIndex, "|c-<->-<->-<->-<->-<->-<->-<->")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            execute_command("sv_map_next")
        end
    else
        -- LEVEL DOWN
        if current_Level > Starting_Level then
            local name = get_var(PlayerIndex, "$name")
            local PLAYER_ID = get_var(PlayerIndex, "$n")
            players[PlayerIndex][1] = current_Level - 1
            if (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].SUICIDE_VICTIM) then
                rprint(PlayerIndex, "|c****** SUICIDE - LEVEL DOWN ******")
            elseif (PlayerIndex == PLAYERS_ALIVE[PLAYER_ID].MELEE_VICTIM) then
                rprint(PlayerIndex, "|c****** MELEED - LEVEL DOWN ******")
            else
                rprint(PlayerIndex, "|c****** LEVEL DOWN ******")
                AnnounceChat(name .. " leveled down and is now Level " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level), PlayerIndex)
            end
            rprint(PlayerIndex, "|cLevel: " .. tostring(players[PlayerIndex][1]) .. "/" .. tostring(#Level))
            rprint(PlayerIndex, "|cKills Needed to Advance: " .. tostring(Level[players[PlayerIndex][1]][4]))
            rprint(PlayerIndex, "|cYour Weapon: " .. tostring(Level[players[PlayerIndex][1]][2]))
            rprint(PlayerIndex, "|cYour Instructions: " .. tostring(Level[players[PlayerIndex][1]][3]))
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
            rprint(PlayerIndex, "|c ")
        end
    end
    if (update == true) and not game_over then
        setscore(PlayerIndex, players[PlayerIndex][1])
    end
    --  assign weapons or vehicle according to level --
    if not game_over then
        if (LargeMapConfiguration == true) then
            WeaponHandler(PlayerIndex)
        elseif (LargeMapConfiguration == false) then
            WeaponHandlerAlternate(PlayerIndex)
        end
        -- Reset Kills --
        players[PlayerIndex][2] = 0
    end
end

-- Check if player is in a Vehicle. Returns boolean --
function PlayerInVehicle(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        local VehicleID = read_dword(player_object + 0x11C)
        if VehicleID == 0xFFFFFFFF then
            return false
        else
            return true
        end
    else
        return false
    end
end

-- destroy old vehicle --
function DestroyVehicle(Vehicle_ID)
    if Vehicle_ID then
        destroy_object(Vehicle_ID)
    end
end

-- Delay entery to Gunner Seat (Rocket Hog) --
-- Important to delay this otherwise player's will spawn in the drivers seat 70% of the time.
function delay_gunners_seat(PlayerIndex)
    -- Gunners Seat --
    enter_vehicle(vehicleId, PlayerIndex, 2)
end

-- WEAPON / VEHICLE ASSIGNMENT HANDLERS
-----------------------------------------
function WeaponHandler(PlayerIndex)
    if (player_alive(PlayerIndex)) then
        local player_object = get_dynamic_player(PlayerIndex)
        -- If already in vehicle when they level up, destroy the old one
        vbool = false
        if PlayerInVehicle(PlayerIndex) then
            vbool = true
            if player_object ~= 0 then
                -- destroy old vehicle --
                Vehicle_ID = read_dword(player_object + 0x11C)
                obj_id = get_object_memory(Vehicle_ID)
                exit_vehicle(PlayerIndex)
                timer(0, "DestroyVehicle", Vehicle_ID)
            end
        end
        if (Level[players[PlayerIndex][1]][12]) == 1 then
            -- remove weapon --
            local weaponId = read_dword(player_object + 0x118)
            if weaponId ~= 0 then
                for j = 0, 3 do
                    local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                    destroy_object(m_weapon)
                end
            end
            -- Core handler --
            if (vbool == true) then
                if (GetLevel(PlayerIndex) == 8) then
                    -- Spawn in Rocket Hog as Gunner/Driver --
                    local x, y, z = read_vector3d(obj_id + 0x5c)
                    -- added_height (important for moving vehicle objects on scoring)
                    -- Can't be higher than 0.3 otherwise players get stuck in walls on large maps when flag capturing and leveling up to a Vehicle Level.
                    added_height = 0.3
                    vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + added_height)
                    enter_vehicle(vehicleId, PlayerIndex, 0)
                    timer(0, "delay_gunners_seat", PlayerIndex)
                else
                    -- handle other vehicle spawns --
                    local x, y, z = read_vector3d(obj_id + 0x5c)
                    -- added_height (important for moving vehicle objects on scoring)
                    -- Can't be higher than 0.3 otherwise players get stuck in walls.
                    added_height = 0.3
                    vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + added_height)
                    enter_vehicle(vehicleId, PlayerIndex, 0)
                end
            else
                -- If scoring with the flag, make sure Level 8 recipients spawn in the gunner/drivers seat of the rocket hog.
                if (GetLevel(PlayerIndex) == 8) then
                    local x, y, z = read_vector3d(player_object + 0x5c)
                    added_height = 0.3
                    vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + added_height)
                    enter_vehicle(vehicleId, PlayerIndex, 0)
                    timer(0, "delay_gunners_seat", PlayerIndex)
                    -- All other vehicles
                else
                    local x, y, z = read_vector3d(player_object + 0x5c)
                    -- added_height (important for moving vehicle objects on scoring)
                    -- Can't be higher than 0.3 otherwise players get stuck in walls.
                    added_height = 0.3
                    vehicleId = spawn_object(vehi_type_id, Level[players[PlayerIndex][1]][11], x, y, z + added_height)
                    enter_vehicle(vehicleId, PlayerIndex, 0)
                end
            end
        else
            -- remove weapon --
            local weaponId = read_dword(player_object + 0x118)
            if weaponId ~= 0 then
                for j = 0, 3 do
                    local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                    destroy_object(m_weapon)
                end
            end
            -- assign weapon --
            local x, y, z = read_vector3d(player_object + 0x5C)
            local weapid = assign_weapon(spawn_object(weap_type_id, Level[players[PlayerIndex][1]][11], x, y, z + 0.5), PlayerIndex)
            local wait_time = 1
            -- Sync Ammo --
            if tonumber(Level[players[PlayerIndex][1]][6]) then
                execute_command_sequence("w8 " .. wait_time .. "; ammo " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6])
                if (GetLevel(PlayerIndex) == 2) then
                    -- Assault Rifle
                    execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] -180)
                elseif (GetLevel(PlayerIndex) == 3) then
                    -- Pistol
                    execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] -24)
                elseif (GetLevel(PlayerIndex) == 4) then
                    -- Sniper Rifle
                    execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] / 3)
                elseif (GetLevel(PlayerIndex) == 5) then
                    -- Rocket Launcher
                    execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] / 3)
                else
                    execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6])
                end
            end
            -- write nades --
            local nades_tbl = Level[players[PlayerIndex][1]][5]
            if nades_tbl then
                FRAG_CHECK[PlayerIndex] = true
                PLASMA_CHECK[PlayerIndex] = true
                safe_write(true)
                local PLAYER = get_dynamic_player(PlayerIndex)
                -- Frags
                write_word(PLAYER + 0x31E, tonumber(nades_tbl[1]))
                -- Plasmas
                write_word(PLAYER + 0x31F, tonumber(nades_tbl[2]))
                safe_write(false)
            end
        end
    end
end

function WeaponHandlerAlternate(PlayerIndex)
    if (player_alive(PlayerIndex)) then
        local player_object = get_dynamic_player(PlayerIndex)
        -- remove weapon --
        local weaponId = read_dword(player_object + 0x118)
        if weaponId ~= 0 then
            for j = 0, 3 do
                local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                destroy_object(m_weapon)
            end
        end
        -- assign weapon --
        local x, y, z = read_vector3d(player_object + 0x5C)
        local weapid = assign_weapon(spawn_object(weap_type_id, Level[players[PlayerIndex][1]][7], x, y, z + 0.5), PlayerIndex)
        local wait_time = 1
        -- Sync Ammo --
        if tonumber(Level[players[PlayerIndex][1]][6]) then
            execute_command_sequence("w8 " .. wait_time .. "; ammo " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6])
            if (GetLevel(PlayerIndex) == 2) then
                -- Assault Rifle
                execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] -180)
            elseif (GetLevel(PlayerIndex) == 3) then
                -- Pistol
                execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] -24)
            elseif (GetLevel(PlayerIndex) == 4) then
                -- Sniper Rifle
                execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] / 3)
            elseif (GetLevel(PlayerIndex) == 5) then
                -- Rocket Launcher
                execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6] / 3)
            else
                execute_command_sequence("w8 " .. wait_time .. "; mag " .. PlayerIndex .. " " .. Level[players[PlayerIndex][1]][6])
            end
        end
        -- write nades --
        local nades_tbl = Level[players[PlayerIndex][1]][5]
        if nades_tbl then
            FRAG_CHECK[PlayerIndex] = true
            PLASMA_CHECK[PlayerIndex] = true
            safe_write(true)
            local PLAYER = get_dynamic_player(PlayerIndex)
            -- Frags
            write_word(PLAYER + 0x31E, tonumber(nades_tbl[1]))
            -- Plasmas
            write_word(PLAYER + 0x31F, tonumber(nades_tbl[2]))
            safe_write(false)
        end
    end
end

function getplayer(PlayerIndex)
    if tonumber(PlayerIndex) then
        if tonumber(PlayerIndex) ~= 0 then
            local m_player = get_player(PlayerIndex)
            if m_player ~= 0 then return m_player end
        end
    end
    return nil
end

function setscore(PlayerIndex, score)
    if tonumber(score) then
        if get_var(0, "$gt") == "ctf" then
            local m_player = getplayer(PlayerIndex)
            if score >= 0x7FFF then
                write_word(m_player + 0xC8, 0x7FFF)
            elseif score <= -0x7FFF then
                write_word(m_player + 0xC8, -0x7FFF)
            else
                write_word(m_player + 0xC8, score)
            end
        elseif get_var(0, "$gt") == "slayer" then
            if score >= 0x7FFF then
                execute_command("score " .. PlayerIndex .. " +1")
            elseif score <= -0x7FFF then
                execute_command("score " .. PlayerIndex .. " -1")
            else
                execute_command("score " .. PlayerIndex .. " " .. score)
            end
        end
    end
end

function CheckType()
    type_is_koth = get_var(1, "$gt") == "koth"
    type_is_oddball = get_var(1, "$gt") == "oddball"
    type_is_race = get_var(1, "$gt") == "race"
    if (type_is_koth) or (type_is_oddball) or (type_is_race) then
        unregister_callback(cb['EVENT_TICK'])
        unregister_callback(cb["EVENT_JOIN"])
        unregister_callback(cb["EVENT_DIE"])
        unregister_callback(cb['EVENT_CHAT'])
        unregister_callback(cb["EVENT_GAME_END"])
        unregister_callback(cb['EVENT_SPAWN'])
        unregister_callback(cb["EVENT_LEAVE"])
        unregister_callback(cb["EVENT_GAME_START"])
        unregister_callback(cb['EVENT_COMMAND'])
        unregister_callback(cb['EVENT_PRESPAWN'])
        unregister_callback(cb["EVENT_DAMAGE_APPLICATION"])
        cprint("Warning: This script doesn't support ODDBALL, KOTH or RACE", 4 + 8)
    end
end

function tokenizestring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = { }; i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- Clear the player's console
function cls(PlayerIndex)
    for clear = 1, 25 do
        rprint(PlayerIndex, " ")
    end
end

function WeaponsAndEquipment(victim, xAxis, yAxis, zAxis)
    math.randomseed(os.time())
    local e = EQUIPMENT_TABLE[math.random(1, #EQUIPMENT_TABLE - 1)]
    local w = WEAPON_TABLE[math.random(1, #WEAPON_TABLE - 1)]
    local player = get_player(victim)
    local rotation = read_float(player + 0x138)
    local GetRandomNumber = math.random(1, 2)
    if (tonumber(GetRandomNumber) == 1) then
        spawn_object(tostring(eqip_type_id), e, xAxis, yAxis, zAxis + 0.5, rotation)
    elseif (tonumber(GetRandomNumber) == 2) then
        spawn_object(tostring(weap_type_id), w, xAxis, yAxis, zAxis + 0.5, rotation)
    end
end

function JustEquipment(victim, xAxis, yAxis, zAxis)
    math.randomseed(os.time())
    local e = EQUIPMENT_TABLE[math.random(0, #EQUIPMENT_TABLE - 1)]
    local player = get_player(victim)
    local rotation = read_float(player + 0x138)
    spawn_object(tostring(eqip_type_id), e, xAxis, yAxis, zAxis + 0.5, rotation)
end

function JustWeapons(victim, xAxis, yAxis, zAxis)
    math.randomseed(os.time())
    local w = WEAPON_TABLE[math.random(0, #WEAPON_TABLE - 1)]
    local player = get_player(victim)
    local rotation = read_float(player + 0x138)
    spawn_object(tostring(weap_type_id), w, xAxis, yAxis, zAxis + 0.5, rotation)
end

function get_tag_info(tagclass, tagname)
    -- Credits to 002 for this function. Return metaid
    local tagarray = read_dword(0x40440000)
    for i = 0, read_word(0x4044000C) -1 do
        local tag = tagarray + i * 0x20
        local class = string.reverse(string.sub(read_string(tag), 1, 4))
        if (class == tagclass) then
            if (read_string(read_dword(tag + 0x10)) == tagname) then
                return read_dword(tag + 0xC)
            end
        end
    end
    return nil
end

function LoadTableLarge()
    if get_var(0, "$gt") ~= "n/a" then

    end
end

function LoadItems()
    if get_var(0, "$gt") ~= "n/a" then
        -- Melee
        MELEE_ASSAULT_RIFLE = get_tag_info("jpt!", "weapons\\assault rifle\\melee")
        MELEE_ODDBALL = get_tag_info("jpt!", "weapons\\ball\\melee")
        MELEE_FLAG = get_tag_info("jpt!", "weapons\\flag\\melee")
        MELEE_FLAME_THROWER = get_tag_info("jpt!", "weapons\\flamethrower\\melee")
        MELEE_NEEDLER = get_tag_info("jpt!", "weapons\\needler\\melee")
        MELEE_PISTOL = get_tag_info("jpt!", "weapons\\pistol\\melee")
        MELEE_PLASMA_PISTOL = get_tag_info("jpt!", "weapons\\plasma pistol\\melee")
        MELEE_PLASMA_RIFLE = get_tag_info("jpt!", "weapons\\plasma rifle\\melee")
        MELEE_ROCKET_LAUNCHER = get_tag_info("jpt!", "weapons\\rocket launcher\\melee")
        MELEE_SHOTGUN = get_tag_info("jpt!", "weapons\\shotgun\\melee")
        MELEE_SNIPER_RIFLE = get_tag_info("jpt!", "weapons\\sniper rifle\\melee")
        MELEE_PLASMA_CANNON = get_tag_info("jpt!", "weapons\\plasma_cannon\\effects\\plasma_cannon_melee")
        -- Grenades Explosion/Attached
        GRENADE_FRAG_EXPLOSION = get_tag_info("jpt!", "weapons\\frag grenade\\explosion")
        GRENADE_PLASMA_EXPLOSION = get_tag_info("jpt!", "weapons\\plasma grenade\\explosion")
        GRENADE_PLASMA_ATTACHED = get_tag_info("jpt!", "weapons\\plasma grenade\\attached")
        -- Vehicles
        VEHICLE_GHOST_BOLT = get_tag_info("jpt!", "vehicles\\ghost\\ghost bolt")
        -- Weapons
        ASSAULT_RIFLE_BULLET = get_tag_info("jpt!", "weapons\\assault rifle\\bullet")

        -- configuration --
        -- Red Base x,y,z
        -- Blue Base x,y,z
        -- Flag x,y,z
        -- Flag Runner Speed
        FLAG["bloodgulch"] = {
            { 95.687797546387, - 159.44900512695, - 0.10000000149012 },
            { 40.240600585938, - 79.123199462891, - 0.10000000149012 },
            { 65.749893188477, - 120.40949249268, 0.11860413849354 },
            { 1.2 }
        }
        FLAG["deathisland"] = {
            { - 26.576030731201, - 6.9761986732483, 9.6631727218628 },
            { 29.843469619751, 15.971487045288, 8.2952880859375 },
            { - 30.282138824463, 31.312761306763, 16.601940155029 },
            { 1.2 }
        }
        FLAG["icefields"] = {
            { 24.85000038147, - 22.110000610352, 2.1110000610352 },
            { - 77.860000610352, 86.550003051758, 2.1110000610352 },
            { - 26.032163619995, 32.365093231201, 9.0070295333862 },
            { 1.2 }
        }
        FLAG["infinity"] = {
            { 0.67973816394806, - 164.56719970703, 15.039022445679 },
            { - 1.8581243753433, 47.779975891113, 11.791272163391 },
            { 9.6316251754761, - 64.030670166016, 7.7762198448181 },
            { 1.2 }
        }
        FLAG["sidewinder"] = {
            { - 32.038200378418, - 42.066699981689, - 3.7000000476837 },
            { 30.351499557495, - 46.108001708984, - 3.7000000476837 },
            { 2.0510597229004, 55.220195770264, - 2.8019363880157 },
            { 1.2 }
        }
        FLAG["timberland"] = {
            { 17.322099685669, - 52.365001678467, - 17.751399993896 },
            { - 16.329900741577, 52.360000610352, - 17.741399765015 },
            { 1.2504668235779, - 1.4873152971268, - 21.264007568359 },
            { 1.2 }
        }
        FLAG["dangercanyon"] = {
            { - 12.104507446289, - 3.4351840019226, - 2.2419033050537 },
            { 12.007399559021, - 3.4513700008392, - 2.2418999671936 },
            { - 0.47723594307899, 55.331966400146, 0.23940123617649 },
            { 1.2 }
        }
        FLAG["beavercreek"] = {
            { 29.055599212646, 13.732000350952, - 0.10000000149012 },
            { - 0.86037802696228, 13.764800071716, - 0.0099999997764826 },
            { 14.01514339447, 14.238339424133, - 0.91193699836731 },
            { 1.2 }
        }
        FLAG["boardingaction"] = {
            { 1.723109960556, 0.4781160056591, 0.60000002384186 },
            { 18.204000473022, - 0.53684097528458, 0.60000002384186 },
            { 4.3749675750732, - 12.832932472229, 7.2201852798462 },
            { 1.5 }
        }
        FLAG["carousel"] = {
            { 5.6063799858093, - 13.548299789429, - 3.2000000476837 },
            { - 5.7499198913574, 13.886699676514, - 3.2000000476837 },
            { 0.033261407166719, 0.0034416019916534, - 0.85620224475861 },
            { 1.2 }
        }
        FLAG["chillout"] = {
            { 7.4876899719238, - 4.49059009552, 2.5 },
            { - 7.5086002349854, 9.750340461731, 0.10000000149012 },
            { 1.392117857933, 4.7001452445984, 3.108856678009 },
            { 1.2 }
        }
        FLAG["damnation"] = {
            { 9.6933002471924, - 13.340399742126, 6.8000001907349 },
            { - 12.17884349823, 14.982703208923, - 0.20000000298023 },
            { - 2.0021493434906, - 4.3015551567078, 3.3999974727631 },
            { 1.2 }
        }
        FLAG["gephyrophobia"] = {
            { 26.884338378906, - 144.71551513672, - 16.049139022827 },
            { 26.727857589722, 0.16621616482735, - 16.048349380493 },
            { 63.513668060303, - 74.088592529297, - 1.0624552965164 },
            { 1.2 }
        }
        FLAG["hangemhigh"] = {
            { 13.047902107239, 9.0331249237061, - 3.3619771003723 },
            { 32.655700683594, - 16.497299194336, - 1.7000000476837 },
            { 21.020147323608, - 4.6323413848877, - 4.2290902137756 },
            { 1.2 }
        }
        FLAG["longest"] = {
            { - 12.791899681091, - 21.6422996521, - 0.40000000596046 },
            { 11.034700393677, - 7.5875601768494, - 0.40000000596046 },
            { - 0.84, - 14.54, 2.41 },
            { 1.2 }
        }
        FLAG["prisoner"] = {
            { - 9.3684597015381, - 4.9481601715088, 5.6999998092651 },
            { 9.3676500320435, 5.1193399429321, 5.6999998092651 },
            { 0.90271377563477, 0.088873945176601, 1.392499089241 },
            { 1.2 }
        }
        FLAG["putput"] = {
            { - 18.89049911499, - 20.186100006104, 1.1000000238419 },
            { 34.865299224854, - 28.194700241089, 0.10000000149012 },
            { - 2.3500289916992, - 21.121452331543, 0.90232092142105 },
            { 1.2 }
        }
        FLAG["ratrace"] = {
            { - 4.2277698516846, - 0.85564690828323, - 0.40000000596046 },
            { 18.613000869751, - 22.652599334717, - 3.4000000953674 },
            { 8.6629104614258, - 11.159770965576, 0.2217468470335 },
            { 1.2 }
        }
        FLAG["wizard"] = {
            { - 9.2459697723389, 9.3335800170898, - 2.5999999046326 },
            { 9.1828498840332, - 9.1805400848389, - 2.5999999046326 },
            { - 5.035900592804, - 5.0643291473389, - 2.7504394054413 },
            { 1.2 }
        }
    end
end
        
function read_widestring(address, length)
    local count = 0
    local byte_table = { }
    for i = 1, length do
        if read_byte(address + count) ~= 0 then
            byte_table[i] = string.char(read_byte(address + count))
        end
        count = count + 2
    end
    return table.concat(byte_table)
end

function math.round(number, place)
    return math.floor(number *(10 ^(place or 0)) + 0.5) /(10 ^(place or 0))
end
        
function OnError(Message)
    print(debug.traceback())
end