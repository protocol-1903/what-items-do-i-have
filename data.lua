-- generate default keybind to search for items
data:extend({
  {
    type = "custom-input",
    name = "widih-search-network",
    key_sequence = "ALT + Z",
    action = "lua",
    include_selected_prototype = true
  },
  {
    type = "custom-input",
    name = "widih-update-hand",
    key_sequence = "SHIFT + ALT + Z",
    action = "lua"
  },
  {
    type = "shortcut",
    name = "widih-update-hand",
    icon = "__what-items-do-i-have__/graphics/info.png",
    small_icon = "__what-items-do-i-have__/graphics/info.png",
    action = "lua",
    toggleable = true,
    associated_control_input = "widih-update-hand"
  },
  {
    type = "custom-input",
    name = "widih-update-hover",
    key_sequence = "CONTROL + ALT + Z",
    action = "lua"
  },
  {
    type = "shortcut",
    name = "widih-update-hover",
    icon = "__what-items-do-i-have__/graphics/info2.png",
    small_icon = "__what-items-do-i-have__/graphics/info2.png",
    action = "lua",
    toggleable = true,
    associated_control_input = "widih-update-hand"
  },
  {
    type = "sprite",
    name = "widih-pin-white",
    filename = "__what-items-do-i-have__/graphics/pin.png",
    size = 32,
    position = {32, 0}
  },
  {
    type = "sprite",
    name = "widih-pin-black",
    filename = "__what-items-do-i-have__/graphics/pin.png",
    size = 32
  },
  {
    type = "sprite",
    name = "widih-gear-white",
    filename = "__what-items-do-i-have__/graphics/gear.png",
    size = 32,
    position = {32, 0}
  },
  {
    type = "sprite",
    name = "widih-gear-black",
    filename = "__what-items-do-i-have__/graphics/gear.png",
    size = 32
  }
})