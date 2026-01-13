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
    type = "string-setting",
    name = "widih-search-location",
    setting_type = "runtime-per-user",
    default_value = "local-search",
    allowed_values = {
      "local-search",
      "remote-search"
    }
  }
}