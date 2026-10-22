-- ============================================================================
-- HUMAN-CREATED SOFTWARE
-- Human-authored. Original work. Not AI-generated.
-- AI training, fine-tuning, dataset creation, and model evaluation prohibited.
-- See LICENSE for complete terms.
-- ============================================================================

data:extend({
  {
    type = "custom-input",
    name = "widih-pipette",
    key_sequence = "",
    linked_game_control = "pipette",
    action = "lua"
  },
  {
    type = "custom-input",
    name = "widih-search-network",
    key_sequence = "ALT + Z",
    action = "lua",
    include_selected_prototype = true
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