
fs = require("fs")
exists = require("path").exists
exec = require("child_process").exec

Bacon = require("./Bacon")
exports.Bacon = Bacon
Bacon.FS = {}
nop = ->

  # common methods
methods = [
  "rename", "truncate", "chmod"
  "stat", "lstat", "fstat"
  "link", "symlink", "readlink"
  "realpath"
  "unlink", "rmdir"
  "mkdir", "readdir"
  "writeFile", "readFile"
]

for name in methods
  Bacon.FS[name] = (args...) -> Bacon.fromNodeCallback("fs.#{name}", args...).toProperty()


Bacon.FS.open = (path, flags, mode) ->
  Bacon.fromBinder (handler) ->
    fs.open(path, flags, mode, (err, fd) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler(fd)
    )
    (-> fs.close(fd, nop))

Bacon.FS.close = (fd) ->
  Bacon.fromCallback (handler) ->
    fs.close(fd, (err) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler(fd)
    )

Bacon.FS.write = (fd, buffer, offset, length, position) ->
  Bacon.fromCallback (handler) ->
    callback = (err, written, innerBuffer) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler({fd, written, buffer:innerBuffer})

    #fs.write makes callback undefined when raw string data is passed 
    buffer = new Buffer(buffer) unless Buffer.isBuffer(buffer)
    fs.write(fd, buffer, offset, buffer.length, position, callback)


Bacon.FS.read = (fd, buffer, offset, length, position) ->
  Bacon.fromCallback (handler) ->
    callback = (err, bytesRead, innerBuffer) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler({fd, bytesRead, buffer:innerBuffer})
    fs.read(fd, buffer, offset, length, position, callback)


Bacon.FS.watchFile = (args...) ->
  Bacon.fromBinder (handler) ->
    fs.watchFile(args..., (curr,prev) ->
      handler({curr, prev})
    )
    (-> fs.unwatchFile(args..., nop))

Bacon.FS.exists = (args...) -> Bacon.fromNodeCallback(exists, args...).toProperty()
Bacon.FS.exec = (args...) -> Bacon.fromNodeCallback(exec, args...).toProperty()
module.exports = exports.Bacon