-- mods/pvp_choice/init.lua
-- =================
-- See README.txt for licensing and other information.

local start = false
local pvp_tbl = {}
 
local function load_database()
  local file = io.open(minetest.get_worldpath() .."/pvp", "r")
    if not file then
    return {}
  end
  local database = minetest.deserialize(file:read("*a"))
  file:close()
  if not database then
    return {}
  end
  return database
end

local function save_database(database)
  local file = io.open(minetest.get_worldpath() .."/pvp","w")
  file:write(minetest.serialize(database))
  file:close()
end

minetest.register_on_joinplayer(function(player)
  if not start then
    start = true
    pvp_tbl = load_database()
    if not pvp_tbl["."] or ((os.time() - pvp_tbl["."]) / (60 * 60 * 24)) >= 31 then
      pvp_tbl = {}
      pvp_tbl["."] = os.time()
      save_database(pvp_tbl)
    end
  end
  local name = player:get_player_name()
  if minetest.get_player_privs(name).interact and not pvp_tbl[name] then
    minetest.after(0.5, function()
    minetest.show_formspec(name, "pvp_choice:main",
      "size[6,1.3]" ..
      "label[0,0;Would you like to be vulnerable and attack others this month?*]" ..
      "label[0.7,0.2;*This choice cant be changed afterwards]" ..
      "button_exit[0.7,1;1.2,0.1;pvp_yes;Yes]" ..
      "button_exit[2.5,1;1.2,0.1;pvp_no;No]")
    end)
  end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
  local name = player:get_player_name()
  if formname ~= "pvp_choice:main" or pvp_tbl[name] then
    return
  end
  if fields.pvp_yes then
    pvp_tbl[name] = name
    save_database(pvp_tbl)
    minetest.chat_send_player(name, "[Server]: You are now vulnerable and can attack others for a month")
  elseif fields.pvp_no then
    pvp_tbl[name] = "."
    save_database(pvp_tbl)
    minetest.chat_send_player(name, "[Server]: You cant be attacked and cant attack others this month")
  end
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if not hitter:is_player() then
    return
  end
  local player_name = player:get_player_name()
  local hitter_name = hitter:get_player_name()
  if pvp_tbl[player_name] == "." or pvp_tbl[hitter_name] == "." then
    if pvp_tbl[player_name] == "." then
      minetest.chat_send_player(hitter_name, "[Server]: You cant attack ".. player_name .." because he has decide against PVP this month")
    else
      minetest.chat_send_player(hitter_name, "[Server]: You cant attack ".. player_name .." because you have decide against PVP this month")
    end
    return true
  end
  return
end)

