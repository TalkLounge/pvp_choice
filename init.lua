-- mods/pvp_choice/init.lua
-- =================
-- See README.txt for licensing and other information.

minetest.register_on_joinplayer(function(player)
    minetest.after(1, function()
        if not player then
          return
        end
        local name = player:get_player_name()
        if minetest.get_player_privs(name).interact and not player:get_attribute("pvp_choice_time") or os.time() >= tonumber(player:get_attribute("pvp_choice_time")) then
          minetest.show_formspec(name, "pvp_choice:main",
            "size[6,1.3]" ..
            "label[0,0;Would you like to be vulnerable and attack others this month?*]" ..
            "label[0.7,0.2;*This choice cant be changed afterwards]" ..
            "button_exit[0.7,1;1.2,0.1;pvp_yes;Yes]" ..
            "button_exit[2.5,1;1.2,0.1;pvp_no;No]")
        end
    end)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "pvp_choice:main" then
    return
  end
  local name = player:get_player_name()
  if fields.pvp_yes then
    player:set_attribute("pvp_choice", 1)
    player:set_attribute("pvp_choice_time", os.time() + (60 * 60 * 24 * 31))
    minetest.chat_send_player(name, "[Server]: You are now vulnerable and can attack others for a month")
  elseif fields.pvp_no then
    player:set_attribute("pvp_choice", 0)
    player:set_attribute("pvp_choice_time", os.time() + (60 * 60 * 24 * 31))
    minetest.chat_send_player(name, "[Server]: You cant be attacked and cant attack others this month")
  end
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if not hitter:is_player() then
    return
  end
  local hitter_name = hitter:get_player_name()
  local player_name = player:get_player_name()
  if tonumber(player:get_attribute("pvp_choice")) == 0 or tonumber(hitter:get_attribute("pvp_choice")) == 0 then
    if tonumber(player:get_attribute("pvp_choice")) == 0 then
      minetest.chat_send_player(hitter_name, "[Server]: You cant attack ".. player_name .." because he has decide against PVP this month")
    else
      minetest.chat_send_player(hitter_name, "[Server]: You cant attack ".. player_name .." because you have decide against PVP this month")
    end
    return true
  end
  return
end)
