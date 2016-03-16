ErrorHelpers = {}
ErrorHelpers.handleError = (error) ->
  if _.isObject error.reason
    for key, value of error.reason
      toastr.error "Error: #{value}"
  else if error.reason
    toastr.error "Error: #{error.reason}"
  else if error.message
    toastr.error "Error: #{error.message}"
  else
    toastr.error 'Unknown Error'
