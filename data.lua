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
    icon = "__what-items-do-i-have__/info.png",
    small_icon = "__what-items-do-i-have__/info.png",
    action = "lua",
    toggleable = true,
    associated_control_input = "widih-update-hand"
  }
})