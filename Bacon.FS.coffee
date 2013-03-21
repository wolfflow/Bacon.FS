fs = require("fs")
exists = require("path").exists
exec = require("child_process").exec
Bacon = require("./Bacon")
exports.Bacon = Bacon
Bacon.FS = {}


methods = [
  "rename", "truncate", "chmod"
  "stat", "lstat", "fstat"
  "link", "symlink", "readlink"
  "realpath"
  "unlink", "rmdir"
  "mkdir", "readdir"
  "open", "close"
  "writeFile", "readFile"
]

createMethod = (name, f) ->
  Bacon.FS[name] = (a...) ->
    Bacon.fromCallback (handler) ->
      f(a..., (err, b...) ->
        if err
          handler(new Bacon.Error(err))
        else
          handler(new Bacon.Next(b...))
      )

# fs: most methods, except for: "write", "read", "watchFile" 
for k in methods
  createMethod(k, fs[k])

# fs: some other

Bacon.FS.write = (fd, buffer, offset, length, position) ->
  Bacon.fromCallback (handler) ->
    callback = (err, written, innerBuffer) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler(new Bacon.Next({written, buffer:innerBuffer}))

    fs.write(fd, buffer, offset, length, position, callback)

Bacon.FS.read = (fd, buffer, offset, length, position) ->
  Bacon.fromCallback (handler) ->
    callback = (err, bytesRead, innerBuffer) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler(new Bacon.Next({bytesRead, buffer:innerBuffer}))

    fs.read(fd, buffer, offset, length, position, callback)


Bacon.FS.watchFile = (a...) ->
  Bacon.fromCallback (handler) ->
    fs.watchFile(a..., (curr,prev) ->
      handler(new Bacon.Next({curr, prev}))
    )

# path.exists
Bacon.FS.exists = (a...) ->
  Bacon.fromCallback (handler) ->
    exists(a..., (exists) ->
      handler(new Bacon.Next(exists))
    )

# exec
Bacon.FS.exec = (a...) ->
  Bacon.fromCallback (handler) ->
    exec(a..., (err, stdout, stderr) ->
      if err
        handler(new Bacon.Error(err))
      else
        handler(new Bacon.Next({stdout, stderr}))
    )

module.exports = exports.Bacon