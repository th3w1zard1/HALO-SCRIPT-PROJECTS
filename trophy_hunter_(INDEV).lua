--[[
Script Name: Trophy Hunter (slayer), for SAPP | (PC|CE)

Description:    When you kill someone, a skull-trophy will fall at your victims death location.
                To claim your kill and score, you have to retrieve the skull.
                To deny a kill, pick up someone else's skull-trophy.

                To Do: [1] CTF Compatibility
                       [2] Full-Spectrum-Vision cubes instead of oddballs
               
This script is also available on my github! Check my github for regular updates on my projects, including this script.
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS

* IGN: Chalwk
* This is my extension of Kill Confirmed ~ re-written and converted for SAPP (PC|CE)
* Credits to Kennan for the original Kill Confirmed add-on for Phasor.
* Written by Jericho Crosby (Chalwk)
------------------------------------
]]--

api_version = "1.11.0.0"

--================================= CONFIGURATION STARTS =================================-- 
-- Full-Spectrum-Vision Cubes will take place of oddballs in a future update.
-- Item to drop on death
tag_item = "weapons\\ball\\ball"

-- SCORING -- 
confirm_self = 2        -- Confirm your own kill:
confirm_kill_other = 1  -- Claim someone else's kill:
deny_kill_self = 3      -- Deny someone's kill on yourself:
death_penalty = 1       -- Death Penalty (This many points taken away on death) - PvP only

-- MISCELLANEOUS --
-- If you have issues with weapons being removed when you pick up a trophy, increase this number to between 200-300
drop_delay = 150

-- MESSAGE BOARD --
-- Messages are sent to the Console environment
message_board = {
    "Welcome to Trophy Hunter",
    "A skull-trophy will fall at your victims death location.",
    "To confirm your kill and score, you have to retrieve the skull-trophy.",
    "To deny a kill, pick up someone else's trophy.",
    }
    
-- How long should the message be displayed on screen for? (in seconds) --
Welcome_Msg_Duration = 15
-- Message Alignment:
-- Left = l,    Right = r,    Center = c,    Tab: t
Alignment = "l"
--================================= CONFIGURATION ENDS =================================-- 
tags = { }
players = { }
new_timer = { }
stored_data = { }
welcome_timer = { }
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_WEAPON_PICKUP'], "OnWeaponPickup")
    -- Check if valid gametype.
    if (CheckType == true) then
        for i = 1, 16 do
            if player_present(i) then
                stored_data[i] = { }
                -- reset table elements --
                local player_id = get_var(i, "$n")
                players[player_id].new_timer = 0
                players[player_id].trophies = 0
                players[player_id].kills = 0
            end
        end
    end
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) then
            if (welcome_timer[i] == true) then
                -- init new timer --
                local player_id = get_var(i, "$n")
                players[player_id].new_timer = players[player_id].new_timer + 0.030
                -- clear the player's console --
                ConsoleClear(i)
                -- print the contents of "message_board" to the player's console
                for k, v in pairs(message_board) do rprint(i, "|" .. Alignment .. " " .. v) end
                if players[player_id].new_timer >= math.floor(Welcome_Msg_Duration) then
                    -- reset welcome timer --
                    welcome_timer[i] = false
                    players[player_id].new_timer = 0
                end
            end
        end
    end
end

function OnNewGame()
    if (CheckType == true) then
        for i = 1, 16 do
            if player_present(i) then
                stored_data[i] = { }
                -- reset table elements --
                local player_id = get_var(i, "$n")
                players[player_id].new_timer = 0
                players[player_id].trophies = 0
                players[player_id].kills = 0
            end
        end
    end
end

function OnGameEnd()
    for i = 1, 16 do
        if player_present(i) then
            if player_present(i) then
                -- reset welcome timer --
                welcome_timer[i] = false
                -- reset table elements --
                local player_id = get_var(i, "$n")
                players[player_id].new_timer = 0
                players[player_id].trophies = 0
                players[player_id].kills = 0
            end
        end
    end
end

function OnPlayerJoin(PlayerIndex)
    -- initialize welcome timer --
    welcome_timer[PlayerIndex] = true
    -- assign elements to new player and set init to zero --
    local player_id = get_var(PlayerIndex, "$n")
    players[player_id] = { }
    players[player_id].trophies = 0
    players[player_id].kills = 0
    players[player_id].new_timer = 0
end

function OnPlayerLeave(PlayerIndex)
    -- reset welcome timer --
    welcome_timer[PlayerIndex] = false
    -- reset table elements --
    local player_id = get_var(PlayerIndex, "$n")
    players[player_id] = { }
    players[player_id].trophies = 0
    players[player_id].kills = 0
    players[player_id].new_timer = 0
end

function OnPlayerDeath(PlayerIndex, KillerIndex)
    
    local Victim_ID = tonumber(PlayerIndex)
    local Killer_ID = tonumber(KillerIndex)
    
    -- Get Killer/Victim's names
    local Victim_Name = get_var(Victim_ID, "$name")
    local Killer_Name = get_var(Killer_ID, "$name")
    
    -- Get Killer/Victim's cd-hash 
    local Victim_Hash = get_var(Victim_ID, "$hash")
    local Killer_Hash = get_var(Killer_ID, "$hash")
    
    if (Killer_ID > 0) and (Victim_ID ~= Killer_ID) then
        -- Deduct 1 point off the killer's score tally. The only way to score is to pickup a trophy.
        execute_command("score " .. Killer_ID .. " -1")
        
        -- Keep track of the killer's kill tally
        local player_id = get_var(KillerIndex, "$n")
        players[player_id].kills = players[player_id].kills + 1
        
        -- Retrieve XYZ coords of victim and spawn a trophy at that location.
        local player_object = get_dynamic_player(Victim_ID)
        local x, y, z = read_vector3d(player_object + 0x5C)
        local trophy = spawn_object("weap", tag_item, x, y, z + 0.3)
        
        -- Get memory address of trophy
        m_object = get_object_memory(trophy)
        trophy_object = trophy
        -- Pin data to trophy that just dropped
        tags[m_object] = Victim_Hash .. ":" .. Killer_Hash .. ":" .. Victim_ID .. ":" .. Killer_ID .. ":" .. Victim_Name .. ":" .. Killer_Name
        
        -- Store tags[m_object] data in a table to prevent undesirable behavior
        stored_data[tags] = stored_data[tags] or { }
        table.insert(stored_data[tags], tostring(tags[m_object]))
        
        -- Deduct the value of "death_penalty" from victim's score
        updatescore(PlayerIndex, tonumber(death_penalty), false)
        rprint(PlayerIndex, "Death Penalty: -" .. tonumber(death_penalty) .. " point(s)")
    end
end

function OnWeaponPickup(PlayerIndex, WeaponIndex, Type)
    local PlayerObj = get_dynamic_player(PlayerIndex)
    local WeaponObject = get_object_memory(read_dword(PlayerObj + 0x2F8 + (tonumber(WeaponIndex) -1) * 4))
    if (ObjectTagID(WeaponObject) == tag_item) then
        if stored_data[tags] ~= nil then
            if (WeaponObject == m_object) then
                local t = tokenizestring(tostring(tags[m_object]), ":")
                OnTagPickup(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6])
                timer(drop_delay, "drop_and_destroy", PlayerIndex)
            end
        end
    end
end

function OnTagPickup(PlayerIndex, victim_hash, killer_hash, victim_id, killer_id, victim_name, killer_name)
    if (victim_hash and killer_hash) and (victim_id and killer_id) and (victim_name and killer_name) then
        if get_var(PlayerIndex, "$hash") == (killer_hash) and get_var(PlayerIndex, "$hash") ~= (victim_hash) then
            local player_id = get_var(killer_id, "$n")
            updatescore(PlayerIndex, tonumber(confirm_self), true)
            players[player_id].trophies = players[player_id].trophies + tonumber(confirm_self)
            respond(get_var(killer_id, "$name") .. " claimed " .. victim_name .. "'s  trophy!", tonumber(killer_id), tonumber(victim_id))
            execute_command("msg_prefix \"\"")
            say(killer_id, "You have claimed "  .. victim_name .. "'s trophy")
            say(victim_id, killer_name .. " claimed your trophy!")
            execute_command("msg_prefix \"** SERVER ** \"")
            rprint(killer_id, "[TROPHIES] You have " .. tonumber(math.floor(players[player_id].trophies)) .. " trophy points and " .. tonumber(math.floor(players[player_id].kills)) .. " kills")
        elseif get_var(PlayerIndex, "$hash") ~= (killer_hash) or get_var(PlayerIndex, "$hash") ~= (victim_hash) then
            if get_var(PlayerIndex, "$name") ~= victim_name and get_var(PlayerIndex, "$name") ~= killer_name then
                local player_id = get_var(killer_id, "$n")
                updatescore(PlayerIndex, tonumber(confirm_kill_other), true)
                players[player_id].trophies = players[player_id].trophies + tonumber(confirm_kill_other)
                respond(get_var(victim_id, "$name") .. " claimed " .. killer_name .. "'s trophy-kill on " .. victim_name .. "!", tonumber(victim_id))
                execute_command("msg_prefix \"\"")
                say(victim_id, "You have claimed " .. killer_name .. "'s trophy-kill on " .. victim_name .. "!")
                execute_command("msg_prefix \"** SERVER ** \"")
                rprint(killer_id, "[TROPHIES] You have " .. tonumber(math.floor(players[player_id].trophies)) .. " trophy points and " .. tonumber(math.floor(players[player_id].kills)) .. " kills")
            end
        end
        if get_var(PlayerIndex, "$hash") == (victim_hash) and get_var(PlayerIndex, "$hash") ~= (killer_hash) then
            local player_id = get_var(killer_id, "$n")
            updatescore(PlayerIndex, tonumber(deny_kill_self), true)
            players[player_id].trophies = players[player_id].trophies + tonumber(deny_kill_self)
            respond(get_var(victim_id, "$name") .. " denied " .. killer_name .. "'s trophy-kill on themselves!", tonumber(killer_id), tonumber(victim_id))
            execute_command("msg_prefix \"\"")
            say(victim_id, "You have Denied " .. killer_name .. "'s trophy-kill on yourself!")
            say(killer_id, victim_name .. " denied your trophy-kill on themselves!")
            execute_command("msg_prefix \"** SERVER ** \"")
            rprint(killer_id, "[TROPHIES] You have " .. tonumber(math.floor(players[player_id].trophies)) .. " trophy points and " .. tonumber(math.floor(players[player_id].kills)) .. " kills")
        end
    end
end

function updatescore(PlayerIndex, number, bool)
    local m_player = get_player(PlayerIndex)
    if m_player then
        if bool ~= nil then
            if (bool == true) then
                execute_command("score " .. PlayerIndex .. " +" .. number)
            elseif (bool == false) then
                execute_command("score " .. PlayerIndex .. " -" .. number)
            end
        end
    end
end

function drop_and_destroy(PlayerIndex)
    -- force player to drop the trophy --
    drop_weapon(PlayerIndex)
    -- destroy trophy --
    destroy_object(trophy_object)
end

-- Check if gametype is valid. 
-- Currently, this add-on only supports slayer gametype
function CheckType()
    if (get_var(1, "$gt") == "ctf") or (get_var(1, "$gt") == "koth") or (get_var(1, "$gt") == "oddball") or (get_var(1, "$gt") == "race") then
        unregister_callback(cb['EVENT_DIE'])
        unregister_callback(cb['EVENT_TICK'])
        unregister_callback(cb['EVENT_JOIN'])
        unregister_callback(cb['EVENT_LEAVE'])
        unregister_callback(cb['EVENT_GAME_END'])
        unregister_callback(cb['EVENT_WEAPON_PICKUP'])
        cprint("Kill-Confirmed Error:", 4 + 8)
        cprint("This script doesn't support " .. get_var(1, "$gt"), 4 + 8)
        return false
    else
        return true
    end
end

function respond(Message, killer_id, victim_id)
    for i = 1, 16 do
        if player_present(i) then
            if (i ~= killer_id and i ~= victim_id) then
                execute_command("msg_prefix \"\"")
                say(i, " " .. Message)
                execute_command("msg_prefix \"** SERVER ** \"")
            end
        end
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

-- clear the player's console --
function ConsoleClear(PlayerIndex)
    for clear_cls = 1, 25 do
        rprint(PlayerIndex, " ")
    end
end

function ObjectTagID(object)--	Gets directory + name of the object
	if(object ~= nil and object ~= 0) then
		return read_string(read_dword(read_word(object) * 32 + 0x40440038))
	else
		return ""
	end
end