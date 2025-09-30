for index, data in pairs(storage or {}) do
  storage[index] = {
    dropdown = data,
    checkbox = false
  }
end