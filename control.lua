local function search(item, player)
  if not player then return end

  if not storage[player.index] then storage[player.index] = 1 end

  window = player.gui.screen["widih-window"]

  if window and (not window.version or window.version.text ~= script.active_mods["what-items-do-i-have"]) then window.destroy() end

  window = player.gui.screen["widih-window"]

  -- end if anything is nil
  if not item then return end

  -- if window does not exist (i.e. player is new to game)
  if not window then
    -- create new window
    window = player.gui.screen.add{
      type = "frame",
      name = "widih-window",
      direction = "vertical"
    }
    window.add{
      type = "flow",
      name = "titlebar",
      direction = "horizontal"
    }.style.natural_width = 180
    window.titlebar.drag_target = window
    window.add{ -- way to check if window is up to date with current version of the script code, if not it will be deleted and replaced
      type = "text-box",
      name = "version",
      text = script.active_mods["what-items-do-i-have"]
    }.visible = false
    window.titlebar.add{
      type = "label",
      name = "label",
      style = "frame_title",
      caption = {"widih-network.nil"}
    }.drag_target = window
    window.titlebar.add{
      type = "empty-widget",
      name = "space",
      style = "draggable_space"
    }.style.horizontally_stretchable = true
    window.titlebar.space.drag_target = window
    window.titlebar.add{
      type = "sprite-button",
      name = "pin",
      style = "frame_action_button",
      sprite = "widih-pin-white",
      hovered_sprite = "widih-pin-black",
      clicked_sprite = "widih-pin-black",
    }
    window.titlebar.add{
      type = "sprite-button",
      name = "close-button",
      style = "close_button",
      sprite = "utility/close"
    }
    window.add{
      type = "frame",
      name = "main",
      direction = "vertical",
      style = "inside_shallow_frame_with_padding"
    }.style.horizontal_align = "right"
    window.main.add{
      type = "label",
      name = "label",
      caption = {"widih-window.search-location"}
    }
    window.main.add{
      type = "empty-widget",
      name = "space0"
    }.style.minimal_height = 2
    window.main.add{
      type = "drop-down",
      name = "dropdown",
      items = {
        {"widih-window.local-search"},
        {"widih-window.remote-search"}
      },
      selected_index = storage[player.index]
    }
    window.main.add{
      type = "empty-widget",
      name = "space1"
    }.style.minimal_height = 4
    window.main.add{
      type = "line",
      name = "line"
    }
    window.main.add{
      type = "empty-widget",
      name = "space2"
    }.style.minimal_height = 4
    window.main.add{
      type = "label",
      name = "error-no-network",
      caption = {"widih-window.error-no-network"}
    }
    window.main.add{
      type = "label",
      name = "error-bad-entity",
      caption = {"widih-window.error-bad-entity"}
    }
    window.main.add{
      type = "table",
      name = "table",
      column_count = 2
    }.style.horizontal_spacing = 10
  end

  main = window.main

  if not item then
    -- invalid entity/no item found
    main["error-no-network"].visible = false
    main["error-bad-entity"].visible = true
    main.table.visible = false
    return
  end

  -- find network of player (or, the position of the map view)
  local network

  if not player.character or player.controller_type ~= defines.controllers.remote or storage[player.index] == 2 then
    if player.surface.platform then
      network = player.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      window.titlebar.label.caption = {"widih-network.platform"}
    elseif player.surface.find_closest_logistic_network_by_position(player.position, player.force) then
      network = player.surface.find_closest_logistic_network_by_position(player.position, player.force)
      window.titlebar.label.caption = {"widih-network.logistic"}
    end
  elseif player.controller_type == defines.controllers.remote and storage[player.index] == 1 and player.character then
    if player.character.surface.platform then
      network = player.character.surface.platform.hub.get_inventory(defines.inventory.hub_main)
      window.titlebar.label.caption = {"widih-network.platform"}
    elseif player.character.surface.find_closest_logistic_network_by_position(player.character.position, player.force) then
      network = player.character.surface.find_closest_logistic_network_by_position(player.character.position, player.force)
      window.titlebar.label.caption = {"widih-network.logistic"}
    end
  end

  if network then
    -- proper logistic network has been found
    main["error-no-network"].visible = false
    main["error-bad-entity"].visible = false
    main.table.visible = true

    -- reset table
    main.table.clear()

    -- find quality items in network
    local items = {}
    for q, quality in pairs(prototypes.quality) do
      if q ~= "quality-unknown" then
        main.table.add{
          type = "choose-elem-button",
          elem_type = "item-with-quality",
          ["item-with-quality"] = {
            name = item,
            quality = q
          }
        }.locked = true
        main.table.add{ type = "label", caption =
          network.get_item_count{
            name = item,
            quality = quality.name
          }
        }
      end
    end
  else
    -- no logistic network has been found, or player does not have the right technologies unlocked
    main["error-no-network"].visible = true
    main["error-bad-entity"].visible = false
    main.table.visible = false
  end

  -- make it visible and focus
  window.visible = true

  if not window.titlebar.pin.toggled then
    player.opened = window
    window.bring_to_front()
  end
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

  if event.element.name == "close-button" then
    window.destroy()
  elseif event.element.name == "pin" then
    local pinned = not window.titlebar["pin"].toggled
    window.titlebar["pin"].toggled = pinned
    if pinned and player.opened == window then
      player.opened = nil
    elseif not pinned and not player.opened_self and not player.opened then
      player.opened = window
    end
  elseif event.element.type == "choose-elem-button" then -- must be an icon button, put it in the hand
    if player.clear_cursor() then
      player.cursor_ghost = {
        name = event.element.elem_value.name,
        quality = event.element.elem_value.quality
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

  storage[player.index] = event.element.selected_index

  if window.main.table.visible then
    search(window.main.table.children[1].elem_value.name, player)
  end
end)

script.on_event(defines.events.on_gui_closed, function (event)
  if event.element and event.element.get_mod() == "what-items-do-i-have" and
    not event.element.titlebar.pin.toggled then
    event.element.destroy()
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
  item = prototype.base_type == "item" and prototype.name or
  prototype.base_type == "recipe" and prototypes.recipe[prototype.name].main_product and prototypes.recipe[prototype.name].main_product.type == "item" and prototypes.recipe[prototype.name].main_product.name or
  prototype.base_type == "entity" and prototypes.entity[prototype.name].items_to_place_this and #prototypes.entity[prototype.name].items_to_place_this == 1 and prototypes.entity[prototype.name].items_to_place_this[1].name

  search(item, player)
end)

-- update on hand stack change
script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
  -- only run if cursor is not empty and the shortcut is on
  if not game.players[event.player_index].is_cursor_empty() and game.players[event.player_index].is_shortcut_toggled("widih-update-hand") then
    player = game.players[event.player_index]
  
    -- get item
    item = player.cursor_ghost and player.cursor_ghost.name.name or player.cursor_stack.valid_for_read and player.cursor_stack.name
  
    search(item, player)
  end
end)

-- update on hover
script.on_event(defines.events.on_selected_entity_changed, function(event)
  -- only run if shortcut is enabled
  if game.players[event.player_index].is_shortcut_toggled("widih-update-hover") and game.players[event.player_index].selected then
    player = game.players[event.player_index]
    prototype = player.selected.type == "entity-ghost" and player.selected.ghost_name or player.selected.name

    -- get item
    item = prototypes.entity[prototype].items_to_place_this and #prototypes.entity[prototype].items_to_place_this == 1 and prototypes.entity[prototype].items_to_place_this[1].name

    search(item, player)
  end
end)