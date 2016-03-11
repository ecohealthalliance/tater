StringHelpers = {}
StringHelpers.escapeRegex = (string) ->
  string.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
StringHelpers.pluralize = (unit, amount) ->
  if amount isnt 1 then "#{unit}s" else unit
