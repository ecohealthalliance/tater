StringHelpers = {}
StringHelpers.escapeRegex = (string) -> 
  string.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
