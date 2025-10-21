script.on_configuration_changed(function (event)
  if not event.mod_changes["what-items-do-i-have"] then return end
  -- when the mod version changes, delete the UI so it's recreated from the ground up (in case anything changes)
  for _, player in pairs(game.players) do
    if player.gui.screen["widih-window"] then player.gui.screen["widih-window"].destroy() end
  end
end)

local function get_location(surface)
  return surface.localised_name or (surface.platform or {}).name or script.active_mods["space-exploration"] and surface.name or {"space-location-name." .. surface.name}
end

local function update_gui(player_index, tabledata, network, label)
  if not player_index then return end

  local player = game.get_player(player_index)

  local window = player.gui.screen["widih-window"]

  -- if window content does not exist (mod version change or fresh install)
  if not window then
    -- create new window
    window = player.gui.screen.add{
      type = "frame",
      name = "widih-window",
      direction = "horizontal",
      style = "invisible_frame"
    }

    window.add{
      type = "frame",
      name = "main",
      direction = "vertical"
    }.drag_target = window

    window.add{
      type = "frame",
      name = "settings",
      direction = "vertical"
    }.drag_target = window
    window.settings.visible = false

    window.settings.add{
      type = "flow",
      name = "titlebar",
      direction = "horizontal"
    }.drag_target = window

    window.settings.titlebar.add{
      type = "label",
      style = "frame_title",
      caption = {"widih-window.settings"}
    }.drag_target = window

    -- drag space thingy
    local header = window.settings.titlebar.add{
      type = "empty-widget",
      style = "draggable_space_header"
    }

    header.style.horizontally_stretchable = true
    header.style.natural_height = 24
    header.style.height = 24
    header.style.right_margin = 4
    header.drag_target = window

    window.settings.titlebar.add{
      type = "sprite-button",
      name = "settings-close",
      style = "close_button",
      sprite = "utility/close",
      tooltip = { "widih-window.close-tooltip" }
    }

    -- main content
    window.settings.add{
      type = "frame",
      name = "sub",
      direction = "vertical",
      style = "inside_shallow_frame_with_padding_and_vertical_spacing"
    }.style.horizontal_align = "right"

    window.settings.sub.add{
      type = "label",
      caption = {"mod-setting-name.widih-search-location"}
    }

    window.settings.sub.add{
      type = "drop-down",
      name = "search-location",
      items = {
        {"string-mod-setting-name.local-search"},
        {"string-mod-setting-name.remote-search"}
      },
      selected_index = player.mod_settings["widih-search-location"].value == "local-search" and 1 or 2
    }

    window.settings.sub.add{
      type = "checkbox",
      name = "show-surface",
      state = player.mod_settings["widih-show-surface"].value,
      caption = {"mod-setting-name.widih-show-surface"}
    }

    window.settings.sub.add{
      type = "checkbox",
      name = "auto-hide",
      state = player.mod_settings["widih-auto-hide"].value,
      caption = {"mod-setting-name.widih-auto-hide"}
    }

    window.main.add{
      type = "flow",
      name = "titlebar",
      direction = "horizontal"
    }.style.natural_width = 180
    window.main.titlebar.drag_target = window
    window.main.titlebar.add{
      type = "label",
      name = "label",
      style = "frame_title",
      caption = label or {"widih-network.nil"}
    }.drag_target = window

    -- drag space thingy
    header = window.main.titlebar.add{
      type = "empty-widget",
      style = "draggable_space_header"
    }

    header.style.horizontally_stretchable = true
    header.style.natural_height = 24
    header.style.height = 24
    header.style.right_margin = 4
    header.drag_target = window

    window.main.titlebar.add{
      type = "sprite-button",
      name = "settings",
      style = "frame_action_button",
      sprite = "widih-gear-white",
      hovered_sprite = "widih-gear-black",
      clicked_sprite = "widih-gear-black",
      tooltip = {"widih-window.settings-tooltip"}
    }

    window.main.titlebar.add{
      type = "sprite-button",
      name = "main-close",
      style = "close_button",
      sprite = "utility/close",
      tooltip = { "widih-window.close-tooltip" }
    }

    -- main content
    window.main.add{
      type = "frame",
      name = "sub",
      direction = "vertical",
      style = "inside_shallow_frame_with_padding_and_vertical_spacing"
    }

    -- labels, only show if required and one at a time
    window.main.sub.add{
      type = "label",
      name = "error-no-network",
      caption = {"widih-window.error-no-network"}
    }

    window.main.sub.add{
      type = "label",
      name = "error-bad-entity",
      caption = {"widih-window.error-bad-entity"}
    }

    window.main.sub.add{
      type = "table",
      name = "table",
      column_count = 5
    }.style.horizontal_spacing = 5
  else -- update things, they may have changed
    window.main.titlebar.label.caption = label or window.main.titlebar.caption
    window.settings.sub["search-location"].selected_index = player.mod_settings["widih-search-location"].value == "local-search" and 1 or 2
    window.settings.sub["show-surface"].state = player.mod_settings["widih-show-surface"].value
    window.settings.sub["auto-hide"].state = player.mod_settings["widih-auto-hide"].value
  end

  local content = window.main.sub

  if not network then
    -- no logistic network has been found, or player does not have the right technologies unlocked
    content["error-no-network"].visible = true
    content["error-bad-entity"].visible = false
    content.table.visible = false
  elseif not tabledata then
    -- invalid entity/no item found
    content["error-no-network"].visible = false
    content["error-bad-entity"].visible = true
    content.table.visible = false
  elseif #tabledata ~= 0 then -- sometimes you just want to update the gui
    -- proper logistic network has been found
    content["error-no-network"].visible = false
    content["error-bad-entity"].visible = false
    content.table.visible = true

    -- reset table
    content.table.clear()

    for _, guielement in pairs(tabledata) do
      content.table.add(guielement)
    end
  end

  -- make it visible and focus
  window.visible = true
  window.bring_to_front()
  window.focus()
end

local function search(item, player_index)
  if not player_index then return end

  local player = game.get_player(player_index)

  -- find network of player (or, the position of the map view)
  local network, label
  local location = player.mod_settings["widih-show-surface"].value or false

  if not player.character or player.controller_type ~= defines.controllers.remote or player.mod_settings["widih-search-location"].value == "remote-search" then
    if player.surface.platform then
      network = player.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      label = location and {"widih-network.platform-r", get_location(player.surface)} or {"widih-network.platform"}
    else
      network = player.surface.find_closest_logistic_network_by_position(player.position, player.force)
      label = location and {"widih-network.logistic-r", get_location(player.surface)} or {"widih-network.logistic"}
    end
  elseif player.controller_type == defines.controllers.remote and player.mod_settings["widih-search-location"].value == "local-search" and player.character then
    if player.character.surface.platform then
      network = player.character.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      label = location and {"widih-network.platform-r", get_location(player.character.surface)} or {"widih-network.platform"}
    else
      network = player.character.surface.find_closest_logistic_network_by_position(player.character.position, player.force)
      label = location and {"widih-network.logistic-r", get_location(player.character.surface)} or {"widih-network.logistic"}
    end
  end

  local tabledata = {}
  if type(item) == "table" and player.gui.screen["widih-window"] and player.gui.screen["widih-window"].main.sub.table.children[1] then
    -- research (lol)
    item = player.gui.screen["widih-window"].main.sub.table.children[1].sprite:sub(6) or nil
  end

  if network and item then
    -- find quality items in network
    for quality in pairs(prototypes.quality) do
      if quality ~= "quality-unknown" then
        local count = network.get_item_count{
          name = item,
          quality = quality
        }
        -- just shove the following into the table when required
        tabledata[#tabledata+1] = {
          type = "sprite-button",
          sprite = "item." .. item,
          quality = quality,
          number = count,
          tooltip = {"widih-window.button-tooltip" .. (script.feature_flags.quality and "-quality" or ""), {"?", {"entity-name." .. item}, {"item-name." .. item}}, count, {"quality-name." .. quality}}
        }
      end
    end
  end

  update_gui(player.index, tabledata, network, label)
end

-- update gui events to reflect
script.on_event(defines.events.on_gui_click, function (event)

  if event.element.get_mod() ~= "what-items-do-i-have" then return end
  
  local player = game.get_player(event.player_index)

  local window = player.gui.screen["widih-window"]

  if event.element.name == "main-close" then
    window.visible = false
  elseif event.element.name == "settings-close" then
    window.settings.visible = false
    window.main.titlebar.settings.toggled = false
  elseif event.element.name == "settings" then
    local open = not window.settings.visible
    window.settings.visible = open
    window.main.titlebar.settings.toggled = open
  elseif event.element.name == "show-surface" then
    player.mod_settings["widih-show-surface"] = {value = event.element.state}
  elseif event.element.name == "auto-hide" then
    player.mod_settings["widih-auto-hide"] = {value = event.element.state}
  elseif event.element.type == "sprite-button" then
    if player.clear_cursor() then
      player.cursor_ghost = {
        name = event.element.sprite:sub(6),
        quality = event.element.quality
      }
    end
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function (event)

  if event.element.get_mod() ~= "what-items-do-i-have" then return end
  
  local player = game.get_player(event.player_index)

  player.mod_settings["widih-search-location"] = {value = event.element.selected_index == 1 and "local-search" or "remote-search"}

  search({}, player.index)
end)

-- update the GUI when mod settings change
script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
  if event.setting_type == "runtime-per-user" and event.player_index then
    search({}, event.player_index)
  end
end)

script.on_event("widih-update-hand", function (event)
  game.get_player(event.player_index).set_shortcut_toggled(
    "widih-update-hand",
    not game.get_player(event.player_index).is_shortcut_toggled("widih-update-hand")
  )
end)

script.on_event("widih-update-hover", function (event)
  game.get_player(event.player_index).set_shortcut_toggled(
    "widih-update-hover",
    not game.get_player(event.player_index).is_shortcut_toggled("widih-update-hover")
  )
end)

script.on_event(defines.events.on_lua_shortcut, function (event)
  if event.prototype_name == "widih-update-hand" then
    game.get_player(event.player_index).set_shortcut_toggled(
      "widih-update-hand",
      not get_player(event.player_index).is_shortcut_toggled("widih-update-hand")
    )
  elseif event.prototype_name == "widih-update-hover" then
    game.get_player(event.player_index).set_shortcut_toggled(
      "widih-update-hover",
      not game.get_player(event.player_index).is_shortcut_toggled("widih-update-hover")
    )
  end
end)

script.on_event("widih-search-network", function(event)
  local prototype = event.selected_prototype

  if not prototype then return end

  -- get item
  local item = prototype.base_type == "item" and not prototypes.item[prototype.name].has_flag("spawnable") and prototype.name or
  prototype.base_type == "recipe" and prototypes.recipe[prototype.name].main_product and prototypes.recipe[prototype.name].main_product.type == "item" and prototypes.recipe[prototype.name].main_product.name or
  prototype.base_type == "entity" and prototypes.entity[prototype.name].items_to_place_this and #prototypes.entity[prototype.name].items_to_place_this == 1 and prototypes.entity[prototype.name].items_to_place_this[1].name

  search(item, event.player_index)
end)

-- update on hand stack change
script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
  local player = game.get_player(event.player_index)
  -- only run if cursor is not empty and the shortcut is on
  if not player.is_cursor_empty() and player.is_shortcut_toggled("widih-update-hand") then
  
    -- get item
    local item = player.cursor_ghost and player.cursor_ghost.name.name or player.cursor_stack.valid_for_read and player.cursor_stack.name
  
    if player.is_cursor_blueprint() or not item or prototypes.item[item].has_flag("spawnable") then return end

    search(item, player.index)
  elseif player.is_cursor_empty() and player.mod_settings["widih-auto-hide"].value and player.gui.screen["widih-window"] then
    player.gui.screen["widih-window"].visible = false -- auto hide if the setting is enabled
  end
end)

-- update on hover
script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  -- only run if shortcut is enabled
  if player.is_shortcut_toggled("widih-update-hover") and player.selected then
    local prototype = prototypes.entity[player.selected.type == "entity-ghost" and player.selected.ghost_name or player.selected.name]

    if not prototype.mineable_properties.products or not prototype.has_flag("player-creation") then return end

    -- get item
    local item = prototype.mineable_properties.products[1].name

    search(item, player.index)
  end
end)