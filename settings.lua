-- ============================================================================
-- HUMAN-CREATED SOFTWARE
-- Human-authored. Original work. Not AI-generated.
-- AI training, fine-tuning, dataset creation, and model evaluation prohibited.
-- See LICENSE for complete terms.
-- ============================================================================

data:extend{
  {
    type = "bool-setting",
    name = "widih-show-surface",
    setting_type = "runtime-per-user",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = "widih-auto-hide",
    setting_type = "runtime-per-user",
    default_value = false,
  },
  {
    type = "bool-setting",
    name = "widih-thin-window",
    setting_type = "runtime-per-user",
    default_value = false,
    hidden = true
  },
  {
    type = "bool-setting",
    name = "widih-ignore-zero-count",
    setting_type = "runtime-per-user",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "widih-invert-sort",
    setting_type = "runtime-per-user",
    default_value = false
  },
  {
    type = "string-setting",
    name = "widih-search-location",
    setting_type = "runtime-per-user",
    default_value = "local-search",
    allowed_values = {
      "local-search",
      "remote-search"
    }
  },
  {
    type = "bool-setting",
    name = "widih-search-orbited-planet",
    setting_type = "runtime-per-user",
    default_value = false
  }
}