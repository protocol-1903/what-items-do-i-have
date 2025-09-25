for index, data in pairs(storage) do
  game.get_player(index).mod_settings["widih-search-location"] = {value = data.dropdown == 1 and "local-search" or "remote-search"}
  game.get_player(index).mod_settings["widih-show-surface"] = {value = data.checkbox}
end

storage = nil

log(serpent.block(storage))