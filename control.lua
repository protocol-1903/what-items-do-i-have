local function search(item, player, settings_changed)
  if not player then return end

  window = player.gui.screen["widih-window"]

  if window and (not window.version or window.version.text ~= script.active_mods["what-items-do-i-have"]) then
    window.destroy()
  end

  window = player.gui.screen["widih-window"]

  -- if window content does not exist
  if not window then

    -- create new window
    window = player.gui.screen.add{
      type = "frame",
      name = "widih-window",
      direction = "horizontal",
      style = "invisible_frame"
    }

    -- version text to check if its up to date
    window.add{
      type = "text-box",
      name = "version",
      text = script.active_mods["what-items-do-i-have"]
    }.visible = false

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
      caption = {"mod-setting-name.search-location"}
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
      caption = {"mod-setting-name.show-surface"}
    }

    window.settings.sub.add{
      type = "checkbox",
      name = "auto-hide",
      state = player.mod_settings["widih-auto-hide"].value,
      caption = {"mod-setting-name.auto-hide"}
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
      caption = {"widih-network.nil"}
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
  elseif settings_changed then -- update settings if required
    window.settings.sub["search-location"].selected_index = player.mod_settings["widih-search-location"].value == "local-search" and 1 or 2
    window.settings.sub["show-surface"].state = player.mod_settings["widih-show-surface"].value
    window.settings.sub["auto-hide"].state = player.mod_settings["widih-auto-hide"].value
  end

  content = window.main.sub

  if not item then
    -- invalid entity/no item found
    content["error-no-network"].visible = false
    content["error-bad-entity"].visible = true
    content.table.visible = false
    return
  end

  -- find network of player (or, the position of the map view)
  local network
  local location = player.mod_settings["widih-show-surface"].value or false

  if not player.character or player.controller_type ~= defines.controllers.remote or player.mod_settings["widih-search-location"].value == "remote-search" then
    if player.surface.platform then
      network = player.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      window.main.titlebar.label.caption = location and {"widih-network.platform-r", player.surface.platform.name} or {"widih-network.platform"}
    elseif player.surface.find_closest_logistic_network_by_position(player.position, player.force) then
      network = player.surface.find_closest_logistic_network_by_position(player.position, player.force)
      window.main.titlebar.label.caption = location and {"widih-network.logistic-r", {"space-location-name." .. player.surface.name}} or {"widih-network.logistic"}
    end
  elseif player.controller_type == defines.controllers.remote and player.mod_settings["widih-search-location"].value == "local-search" and player.character then
    if player.character.surface.platform then
      network = player.character.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      window.main.titlebar.label.caption = location and {"widih-network.platform-r", player.character.surface.platform.name} or {"widih-network.platform"}
    elseif player.character.surface.find_closest_logistic_network_by_position(player.character.position, player.force) then
      network = player.character.surface.find_closest_logistic_network_by_position(player.character.position, player.force)
      window.main.titlebar.label.caption = location and {"widih-network.logistic-r", {"space-location-name." .. player.character.surface.name}} or {"widih-network.logistic"}
    end
  end

  if network then
    -- proper logistic network has been found
    content["error-no-network"].visible = false
    content["error-bad-entity"].visible = false
    content.table.visible = true

    -- reset table
    content.table.clear()

    -- find quality items in network
    local items = {}
    for quality in pairs(prototypes.quality) do
      if quality ~= "quality-unknown" then
        local count = network.get_item_count{
          name = item,
          quality = quality
        }
        content.table.add{
          type = "sprite-button",
          sprite = "item." .. item,
          quality = quality,
          number = count,
          tooltip = {"widih-window.button-tooltip" .. (script.feature_flags.quality and "-quality" or ""), {"?", {"entity-name." .. item}, {"item-name." .. item}}, count, {"quality-name." .. quality}}
        }
      end
    end
  else
    -- no logistic network has been found, or player does not have the right technologies unlocked
    content["error-no-network"].visible = true
    content["error-bad-entity"].visible = false
    content.table.visible = false
  end

  -- make it visible and focus
  window.visible = true
  window.bring_to_front()
  window.focus()
end

-- update gui events to reflect
script.on_event(defines.events.on_gui_click, function (event)

  if event.element.get_mod() ~= "what-items-do-i-have" then return end
  
  local player = game.players[event.player_index]

  window = player.gui.screen["widih-window"]

  if not window.version or window.version.text ~= script.active_mods["what-items-do-i-have"] then
    window.destroy()
    return
  end

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
    local caption = player.gui.screen["widih-window"].main.titlebar.label.caption
    local location = (not player.character or player.controller_type ~= defines.controllers.remote or player.mod_settings["widih-search-location"].value == "remote-search") and player.surface or player.character.surface
    player.gui.screen["widih-window"].main.titlebar.label.caption = {
      "widih-network." .. (caption[1]:sub(15, 15) == "l" and "logistic" or "platform") .. (event.element.state and "-r" or ""),
      event.element.state and (location.platform and location.platform.name or {"space-location-name." .. location.name}) or nil
    }
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
  
  local player = game.players[event.player_index]

  window = player.gui.screen["widih-window"]

  if not window.version or window.version.text ~= script.active_mods["what-items-do-i-have"] then
    window.destroy()
    return
  end

  player.mod_settings["widih-search-location"] = {value = event.element.selected_index == 1 and "local-search" or "remote-search"}

  if window.main.sub.table.visible then
    search(window.main.sub.table.children[1].sprite:sub(6), player)
  end
end)

-- update the GUI when mod settings change
script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
  if event.setting_type == "runtime-per-user" and event.player_index then
    search(nil, game.get_player(event.player_index), true)
  end
end)

script.on_event("widih-update-hand", function (event)
  game.players[event.player_index].set_shortcut_toggled(
    "widih-update-hand",
    not game.players[event.player_index].is_shortcut_toggled("widih-update-hand")
  )
end)

script.on_event("widih-update-hover", function (event)
  game.players[event.player_index].set_shortcut_toggled(
    "widih-update-hover",
    not game.players[event.player_index].is_shortcut_toggled("widih-update-hover")
  )
end)

script.on_event(defines.events.on_lua_shortcut, function (event)
  if event.prototype_name == "widih-update-hand" then
    game.players[event.player_index].set_shortcut_toggled(
      "widih-update-hand",
      not game.players[event.player_index].is_shortcut_toggled("widih-update-hand")
    )
  elseif event.prototype_name == "widih-update-hover" then
    game.players[event.player_index].set_shortcut_toggled(
      "widih-update-hover",
      not game.players[event.player_index].is_shortcut_toggled("widih-update-hover")
    )
  end
end)

script.on_event("widih-search-network", function(event)
  player = game.players[event.player_index]
  prototype = event.selected_prototype

  if not prototype then return end

  -- get item
  item = prototype.base_type == "item" and not prototypes.item[prototype.name].has_flag("spawnable") and prototype.name or
  prototype.base_type == "recipe" and prototypes.recipe[prototype.name].main_product and prototypes.recipe[prototype.name].main_product.type == "item" and prototypes.recipe[prototype.name].main_product.name or
  prototype.base_type == "entity" and prototypes.entity[prototype.name].items_to_place_this and #prototypes.entity[prototype.name].items_to_place_this == 1 and prototypes.entity[prototype.name].items_to_place_this[1].name

  search(item, player)
end)

-- update on hand stack change
script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
  local player = game.players[event.player_index]
  -- only run if cursor is not empty and the shortcut is on
  if not player.is_cursor_empty() and player.is_shortcut_toggled("widih-update-hand") then
  
    -- get item
    item = player.cursor_ghost and player.cursor_ghost.name.name or player.cursor_stack.valid_for_read and player.cursor_stack.name
  
    if player.is_cursor_blueprint() or not item or prototypes.item[item].has_flag("spawnable") then return end

    search(item, player)
  elseif player.is_cursor_empty() and player.mod_settings["widih-auto-hide"].value and player.gui.screen["widih-window"] then
    player.gui.screen["widih-window"].visible = false -- auto hide if the setting is enabled
  end
end)

-- update on hover
script.on_event(defines.events.on_selected_entity_changed, function(event)
  -- only run if shortcut is enabled
  if game.players[event.player_index].is_shortcut_toggled("widih-update-hover") and game.players[event.player_index].selected then
    player = game.players[event.player_index]
    prototype = prototypes.entity[player.selected.type == "entity-ghost" and player.selected.ghost_name or player.selected.name]

    if not prototype.mineable_properties.products or not prototype.has_flag("player-creation") then return end

    -- get item
    item = prototype.mineable_properties.products[1].name

    search(item, player)
  end
end)