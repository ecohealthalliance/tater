fs = Npm.require('fs')
path = Npm.require('path')
Picker.route '/revision.txt', (params, req, res, next) ->
  appDirectory = path.join(process.cwd().split('tater')[0], 'tater')
  fs.readFile path.join(appDirectory, 'revision.txt'), 'utf8', (err, data)->
    if err
      console.log(err)
      res.end("Error getting revision. Check the server log for details.")
    else
      res.end(data)
