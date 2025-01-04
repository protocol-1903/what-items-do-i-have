script.on_event("widih-search-network", function(event)
  player = game.get_player(event.player_index)
  window = player.gui.screen["widih-window"]
  prototype = event.selected_prototype

  if not prototype then return end

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
      name = "widih-titlebar",
      direction = "horizontal"
    }
    window["widih-titlebar"].add{
      type = "label",
      name = "widih-titlebar-label",
      style = "frame_title",
      caption = {"gui.widih-window-title"}
    }
    window["widih-titlebar"].add{
      type = "empty-widget",
      name = "widih-titlebar-break",
      style = "draggable_space"
    }
    window["widih-titlebar"].add{
      type = "sprite-button",
      name = "widih-close-button",
      style = "close_button",
      sprite = "utility/close"
    }
    window.add{
      type = "label",
      name = "widih-error-no-network",
      caption = {"gui.widih-error-no-network"}
    }
    window.add{
      type = "label",
      name = "widih-error-bad-entity",
      caption = {"gui.widih-error-bad-entity"}
    }
    window.add{
      type = "table",
      name = "widih-content-table",
      column_count = 3
    }
    window["widih-titlebar"]["widih-titlebar-break"].style.minimal_width = 20
    window["widih-titlebar"]["widih-titlebar-label"].drag_target = window
    window["widih-titlebar"].drag_target = window
  end

  -- make it visible and focus
  window.visible = true
  window.bring_to_front()

  item = prototype.base_type == "item" and prototype.name or
  prototype.base_type == "entity" and prototypes.entity[prototype.name].items_to_place_this and #prototypes.entity[prototype.name].items_to_place_this == 1 and prototypes.entity[prototype.name].items_to_place_this[1].name

  -- find network of player (or, the position of the map view)
  local network = player.force.find_logistic_network_by_position(player.position, player.surface)

  if not item then
    -- invalid entity/no item found
    window["widih-error-no-network"].visible = false
    window["widih-error-bad-entity"].visible = true
    window["widih-content-table"].visible = false
  elseif network then
    -- proper logistic network has been found
    window["widih-error-no-network"].visible = false
    window["widih-error-bad-entity"].visible = false
    window["widih-content-table"].visible = true

    -- reset table
    window["widih-content-table"].clear()

    -- find quality items in network
    local items = {}
    for q, quality in pairs(prototypes.quality) do
      if q ~= "quality-unknown" then
        window["widih-content-table"].add{ type = "sprite", sprite = "item." .. item }
        window["widih-content-table"].add{ type = "sprite", sprite = "quality." .. q }
        window["widih-content-table"].add{ type = "label", caption =
        network.get_item_count{
          name = item,
          quality = quality.name
        }}
      end
    end
  else
    -- no logistic network has been found, or player does not have the right technologies unlocked
    window["widih-error-no-network"].visible = true
    window["widih-error-bad-entity"].visible = false
    window["widih-content-table"].visible = false
  end
end)

-- close window when button clicked
script.on_event(defines.events.on_gui_click, function (event)
  if event.element.name == "widih-close-button" then
    game.get_player(event.player_index).gui.screen["widih-window"].destroy()
  end
end)

script.on_event("widih-update-hand", function (event)
  game.get_player(event.player_index).set_shortcut_toggled(
    "widih-update-hand",
    not game.get_player(event.player_index).is_shortcut_toggled("widih-update-hand")
  )
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
  -- only run if cursor is not empty and the shortcut is on
  if not game.get_player(event.player_index).is_cursor_empty() and game.get_player(event.player_index).is_shortcut_toggled("widih-update-hand") then
    player = game.get_player(event.player_index)
    window = player.gui.screen["widih-window"]
    item = player.cursor_ghost and player.cursor_ghost.name.name or player.cursor_stack.valid_for_read and player.cursor_stack.name
  
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
        name = "widih-titlebar",
        direction = "horizontal"
      }
      window["widih-titlebar"].add{
        type = "label",
        name = "widih-titlebar-label",
        style = "frame_title",
        caption = {"gui.widih-window-title"}
      }
      window["widih-titlebar"].add{
        type = "empty-widget",
        name = "widih-titlebar-break",
        style = "draggable_space"
      }
      window["widih-titlebar"].add{
        type = "sprite-button",
        name = "widih-close-button",
        style = "close_button",
        sprite = "utility/close"
      }
      window.add{
        type = "label",
        name = "widih-error-no-network",
        caption = {"gui.widih-error-no-network"}
      }
      window.add{
        type = "label",
        name = "widih-error-bad-entity",
        caption = {"gui.widih-error-bad-entity"}
      }
      window.add{
        type = "table",
        name = "widih-content-table",
        column_count = 3
      }
      window["widih-titlebar"]["widih-titlebar-break"].style.minimal_width = 20
      window["widih-titlebar"]["widih-titlebar-label"].drag_target = window
      window["widih-titlebar"].drag_target = window
    end
  
    -- make it visible and focus
    window.visible = true
    window.bring_to_front()
  
    -- find network of player (or, the position of the map view)
    local network = player.force.find_logistic_network_by_position(player.position, player.surface)
  
    if not item then
      -- invalid entity/no item found
      window["widih-error-no-network"].visible = false
      window["widih-error-bad-entity"].visible = true
      window["widih-content-table"].visible = false
    elseif network then
      -- proper logistic network has been found
      window["widih-error-no-network"].visible = false
      window["widih-error-bad-entity"].visible = false
      window["widih-content-table"].visible = true
  
      -- reset table
      window["widih-content-table"].clear()
  
      -- find quality items in network
      local items = {}
      for q, quality in pairs(prototypes.quality) do
        if q ~= "quality-unknown" then
          window["widih-content-table"].add{ type = "sprite", sprite = "item." .. item }
          window["widih-content-table"].add{ type = "sprite", sprite = "quality." .. q }
          window["widih-content-table"].add{ type = "label", caption =
          network.get_item_count{
            name = item,
            quality = quality.name
          }}
        end
      end
    else
      -- no logistic network has been found, or player does not have the right technologies unlocked
      window["widih-error-no-network"].visible = true
      window["widih-error-bad-entity"].visible = false
      window["widih-content-table"].visible = false
    end
  end
end)