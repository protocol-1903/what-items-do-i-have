script.on_configuration_changed(function (event)
  if not event.mod_changes["what-items-do-i-have"] then return end
  -- when the mod version changes, delete the UI so it's recreated from the ground up (in case anything changes)
  for _, player in pairs(game.players) do
    if player.gui.screen["widih-window"] then player.gui.screen["widih-window"].destroy() end
    if player.gui.screen["widih-thin-window"] then player.gui.screen["widih-thin-window"].destroy() end
    player.mod_settings["widih-thin-window"].value = false
  end
end)

defines.content_visibility = {
  valid_data = 0,
  error_no_network = 1,
  error_bad_item = 2,
}

local function get_location(surface)
  return surface.localised_name or (surface.platform or {}).name or {"space-location-name." .. surface.name}
end

local function calculate_location(index)
  local player = game.get_player(index)

  local height = 96 * player.display_scale
  local width = 468 * player.display_scale
  local offset = 24 * player.display_scale
  local frame_width = 188 * player.display_scale
  local frame_height = 80 * player.display_scale
  return {
    player.display_resolution.width / 2 - width / 2 - offset - frame_width,
    player.display_resolution.height - height - frame_height
  }
end

local function show_gui(player_index)
  if not player_index then return end
  if game.get_player(player_index).mod_settings["widih-thin-window"].value then
    local window = game.get_player(player_index).gui.screen["widih-thin-window"]
    if not window then return end
    window.visible = true
  else
    local window = game.get_player(player_index).gui.screen["widih-window"]
    if not window then return end
    window.visible = true
    window.bring_to_front()
    window.focus()
  end
end

local function hide_gui(player_index)
  if not player_index then return end
  if game.get_player(player_index).mod_settings["widih-thin-window"].value then
    local window = game.get_player(player_index).gui.screen["widih-thin-window"]
    if not window then return end
    window.visible = false
  else
    local window = game.get_player(player_index).gui.screen["widih-window"]
    if not window then return end
    window.visible = false
  end
end

local function set_status(content, status)
  content["error-no-network"].visible = status == defines.content_visibility.error_no_network
  content["error-bad-entity"].visible = status == defines.content_visibility.error_bad_item
  content.table.visible = status == defines.content_visibility.valid_data
  if content.item then content.item.visible = status == defines.content_visibility.valid_data end
end

local item_tooltip = "widih-window.button-tooltip" .. (script.feature_flags.quality and "-quality" or "")

local function update_gui(player_index, tabledata, network, label)
  if not player_index then return end

  local player = game.get_player(player_index)
  local window = player.gui.screen["widih-window"]
  local thin_window = player.gui.screen["widih-thin-window"]
  local content -- area for search data to go, table or table + icon for item

  if not window and #tabledata == 0 then return end

  -- if window content does not exist (mod version change or fresh install)
  if not window then
    -- create new window
    window = player.gui.screen.add{
      type = "frame",
      name = "widih-window",
      direction = "horizontal",
      style = "invisible_frame"
    }
    window.visible = false

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
      style = "frame_action_button",
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

    window.settings.sub.add{
      type = "checkbox",
      name = "ignore-zero-count",
      state = player.mod_settings["widih-ignore-zero-count"].value,
      caption = {"mod-setting-name.widih-ignore-zero-count"}
    }

    window.settings.sub.add{
      type = "checkbox",
      name = "invert-sort",
      state = player.mod_settings["widih-invert-sort"].value,
      caption = {"mod-setting-name.widih-invert-sort"}
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
      name = "pin",
      style = "frame_action_button",
      sprite = "widih-pin-white",
      hovered_sprite = "widih-pin-black",
      clicked_sprite = "widih-pin-black",
      tooltip = {"widih-window.pin-tooltip"}
    }

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
      style = "frame_action_button",
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
  end
  -- if window content does not exist (mod version change or fresh install)
  if not thin_window then
    thin_window = player.gui.screen.add {
      type = "frame",
      name = "widih-thin-window",
      direction = "vertical"
    }
    thin_window.style.padding = 4
    thin_window.style.width = 188
    thin_window.style.height = 80
    thin_window.location = calculate_location(player.index)

    -- main content
    thin_window.add{
      type = "flow",
      name = "titlebar",
      direction = "horizontal"
    }
    thin_window.titlebar.drag_target = thin_window
    thin_window.titlebar.style.natural_width = 180
    thin_window.titlebar.add{
      type = "label",
      name = "label",
      style = "caption_label",
      caption = label or {"widih-network.nil"}
    }
    thin_window.titlebar.label.drag_target = thin_window
    thin_window.titlebar.label.style.top_padding = -2

    -- drag space thingy
    thin_window.titlebar.add{
      type = "empty-widget",
      name = "header",
      style = "draggable_space_header"
    }

    thin_window.titlebar.header.drag_target = thin_window
    thin_window.titlebar.header.style.horizontally_stretchable = true
    thin_window.titlebar.header.style.height = 14
    thin_window.titlebar.header.style.right_margin = 4

    thin_window.titlebar.add{
      type = "sprite-button",
      name = "pin",
      style = "frame_action_button",
      sprite = "widih-pin-white",
      hovered_sprite = "widih-pin-black",
      clicked_sprite = "widih-pin-black",
      toggled = true,
      tooltip = {"widih-window.unpin-tooltip"}
    }.style.size = 14

    thin_window.titlebar.add{
      type = "sprite-button",
      name = "main-close",
      style = "frame_action_button",
      sprite = "utility/close",
      tooltip = { "widih-window.close-tooltip" }
    }.style.size = 14

    -- -- main content
    thin_window.add{
      type = "frame",
      name = "sub",
      direction = "horizontal",
      style = "inside_shallow_frame_with_padding_and_vertical_spacing"
    }
    thin_window.sub.style.top_padding = 3
    thin_window.sub.style.bottom_padding = 3
    thin_window.sub.style.left_padding = 3
    thin_window.sub.style.right_padding = 3

    -- labels, only show if required and one at a time
    thin_window.sub.add{
      type = "label",
      name = "error-no-network",
      caption = {"widih-window.error-no-network"}
    }

    thin_window.sub.add{
      type = "label",
      name = "error-bad-entity",
      caption = {"widih-window.error-bad-entity"}
    }

    thin_window.sub.add{
      type = "table",
      name = "table",
      column_count = 5
    }.style.horizontal_spacing = 2
  end

  -- reset location if out of bounds
  if window.location.x >= player.display_resolution.width - 100 or window.location.y >= player.display_resolution.height - 100 then
    window.location = {0, 0}
  end
  if thin_window.location.x >= player.display_resolution.width - 100 or thin_window.location.y >= player.display_resolution.height - 100 then
    thin_window.location = calculate_location(player.index)
  end

  if label then -- new search location
    window.main.titlebar.label.caption = label
    thin_window.titlebar.label.caption = label
  end
  
  -- update settings, might move to the 
  window.settings.sub["search-location"].selected_index = player.mod_settings["widih-search-location"].value == "local-search" and 1 or 2
  window.settings.sub["show-surface"].state = player.mod_settings["widih-show-surface"].value
  window.settings.sub["auto-hide"].state = player.mod_settings["widih-auto-hide"].value

  local thin_mode = player.mod_settings["widih-thin-window"].value

  -- set visibility and find the proper content window
  content = thin_mode and thin_window.sub or window.main.sub
  window.visible = not thin_mode
  thin_window.visible = thin_mode

  if not network then
    -- no logistic network has been found, or player does not have the right technologies unlocked
    set_status(content, defines.content_visibility.error_no_network)
  elseif not tabledata then
    -- invalid entity/no item found
    set_status(content, defines.content_visibility.error_bad_item)
  else
    -- proper logistic network has been found
    set_status(content, defines.content_visibility.valid_data)

    local tags = window.tags or {}
    if #tabledata ~= 0 then
      -- new data, reset table
      tags["widih-search-data"] = tabledata
      window.tags = tags
    else -- pull from storage, sometimes you just wanna update the gui
      tabledata = tags["widih-search-data"]
    end

    if not tabledata or not prototypes.item[tabledata[1].item] then
      -- item does not exist
      set_status(content, defines.content_visibility.error_bad_item)
      return
    end

    content.table.clear()

    local invert = player.mod_settings["widih-invert-sort"].value
    local include_zero = not player.mod_settings["widih-ignore-zero-count"].value

    local max_render_count = thin_mode and 5 or 10
    local counted = 0
    for i = invert and #tabledata or 1, invert and 1 or #tabledata, invert and -1 or 1 do
      local itemdata = tabledata[i]
      if counted == max_render_count then break end
      if prototypes.quality[itemdata.quality] and (include_zero or itemdata.count > 0) then
        content.table.add {
          type = "sprite-button",
          sprite = "item." .. itemdata.item,
          quality = itemdata.quality,
          number = itemdata.count,
          tooltip = {item_tooltip, {"?", {"entity-name." .. itemdata.item}, {"item-name." .. itemdata.item}}, itemdata.count, {"quality-name." .. itemdata.quality}},
          resize_to_sprite = false
        }.style.size = thin_mode and 32 or 40
        counted = counted + 1
      end
    end
  end
end

local function search(player_index, item)
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
  if type(item) == "table" then
    item = (((player.gui.screen["widih-window"] or {}).tags or {})["widih-search-data"] or {})[1].item
  end

  -- item must exist
  if not prototypes.item[item] then item = nil end

  if network and item then
    -- find quality items in network
    for quality in pairs(prototypes.quality) do
      if quality ~= "quality-unknown" then
        -- just shove the following into the table when required
        tabledata[#tabledata+1] = {
          item = item,
          quality = quality,
          count = network.get_item_count{
            name = item,
            quality = quality
          }
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
    hide_gui(player.index)
  elseif event.element.name == "settings-close" then
    window.settings.visible = false
  elseif event.element.name == "settings" then
    local open = not window.settings.visible
    window.settings.visible = open
    window.main.titlebar.settings.toggled = open
  elseif event.element.name == "show-surface" then
    player.mod_settings["widih-show-surface"] = {value = event.element.state}
  elseif event.element.name == "auto-hide" then
    player.mod_settings["widih-auto-hide"] = {value = event.element.state}
  elseif event.element.name == "ignore-zero-count" then
    player.mod_settings["widih-ignore-zero-count"] = {value = event.element.state}
  elseif event.element.name == "invert-sort" then
    player.mod_settings["widih-invert-sort"] = {value = event.element.state}
  elseif event.element.name == "pin" then
    player.mod_settings["widih-thin-window"] = {value = not player.mod_settings["widih-thin-window"].value}
  elseif event.element.type == "sprite-button" then
    if player.clear_cursor() then
      player.cursor_ghost = {
        name = event.element.sprite:sub(6),
        quality = event.element.quality
      }
    end
  end
end)

-- update GUI when search location changes
script.on_event(defines.events.on_gui_selection_state_changed, function (event)
  if event.element.get_mod() ~= "what-items-do-i-have" then return end

  local player = game.get_player(event.player_index)
  player.mod_settings["widih-search-location"] = {value = event.element.selected_index == 1 and "local-search" or "remote-search"}

  search(player.index)
end)

-- update GUI when player changes remote view (not to/from remote view)
---@param event EventData.on_player_changed_surface
script.on_event(defines.events.on_player_changed_surface, function (event)
  search(event.player_index)
end)

-- update the GUI when mod settings change
script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
  if event.setting_type == "runtime-per-user" and event.player_index then
    update_gui(event.player_index, {}, true)
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
      not game.get_player(event.player_index).is_shortcut_toggled("widih-update-hand")
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

  if not prototype then
    hide_gui(event.player_index)
    return
  end

  -- get item
  local item = prototype.base_type == "item" and not prototypes.item[prototype.name].has_flag("spawnable") and prototype.name or
  prototype.base_type == "recipe" and prototypes.recipe[prototype.name].main_product and prototypes.recipe[prototype.name].main_product.type == "item" and prototypes.recipe[prototype.name].main_product.name or
  prototype.base_type == "entity" and prototypes.entity[prototype.name].items_to_place_this and #prototypes.entity[prototype.name].items_to_place_this == 1 and prototypes.entity[prototype.name].items_to_place_this[1].name

  search(event.player_index, item)
  show_gui(event.player_index)
end)

-- update on hand stack change
script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
  local player = game.get_player(event.player_index)
  -- only run if cursor is not empty and the shortcut is on
  if not player.is_cursor_empty() and player.is_shortcut_toggled("widih-update-hand") then

    -- get item
    local item = player.cursor_ghost and player.cursor_ghost.name.name or player.cursor_stack.valid_for_read and player.cursor_stack.name

    if player.is_cursor_blueprint() or not item or prototypes.item[item].has_flag("spawnable") then return end

    search(player.index, item)
    show_gui(player.index)
  elseif player.is_cursor_empty() and player.mod_settings["widih-auto-hide"].value then
    hide_gui(player.index)
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

    search(player.index, item)
    show_gui(player.index)
  end
end)