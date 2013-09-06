fs = require("fs")
exists = require("path").exists
exec = require("child_process").exec

nop = ->

Bacon = require("./Bacon")
exports.Bacon = Bacon
fromBinder = Bacon.fromBinder
fromCallback = Bacon.fromCallback
fromNodeCallback = Bacon.fromNodeCallback
Error = Bacon.Error

Bacon.FS = BFS = {}

# common methods
BFS.rename = (args...) -> fromNodeCallback(fs.rename, args...).toProperty()
BFS.truncate = (args...) -> fromNodeCallback(fs.truncate, args...).toProperty()
BFS.chmod = (args...) -> fromNodeCallback(fs.chmod, args...).toProperty()

BFS.stat = (args...) -> fromNodeCallback(fs.stat, args...).toProperty()  
BFS.lstat = (args...) -> fromNodeCallback(fs.lstat, args...).toProperty()
BFS.fstat = (args...) -> fromNodeCallback(fs.fstat, args...).toProperty()

BFS.link = (args...) -> fromNodeCallback(fs.link, args...).toProperty()  
BFS.symlink = (args...) -> fromNodeCallback(fs.symlink, args...).toProperty()
BFS.readlink = (args...) -> fromNodeCallback(fs.readlink, args...).toProperty()

BFS.realpath = (args...) -> fromNodeCallback(fs.realpath, args...).toProperty()

BFS.unlink = (args...) -> fromNodeCallback(fs.unlink, args...).toProperty()
BFS.rmdir = (args...) -> fromNodeCallback(fs.rmdir, args...).toProperty()

BFS.mkdir = (args...) -> fromNodeCallback(fs.mkdir, args...).toProperty()
BFS.readdir = (args...) -> fromNodeCallback(fs.readdir, args...).toProperty()

BFS.writeFile = (args...) -> fromNodeCallback(fs.writeFile, args...).toProperty()
BFS.readFile = (args...) -> fromNodeCallback(fs.readFile, args...).toProperty()

BFS.exists = (args...) -> fromNodeCallback(exists, args...).toProperty()
BFS.exec = (args...) -> fromNodeCallback(exec, args...).toProperty()


BFS.open = (path, flags, mode) ->
  fromBinder (handler) ->
    fs.open(path, flags, mode, (err, fd) ->
      if err
        handler(new Error(err))
      else
        handler(fd)
    )
    (-> fs.close(fd, nop))

BFS.close = (fd) ->
  fromCallback (handler) ->
    fs.close(fd, (err) ->
      if err
        handler(new Error(err))
      else
        handler(fd)
    )

BFS.write = (fd, buffer, offset, length, position) ->
  fromCallback (handler) ->
    callback = (err, written, innerBuffer) ->
      if err
        handler(new Error(err))
      else
        handler({fd, written, buffer:innerBuffer})

    #fs.write makes callback undefined when raw string data is passed 
    buffer = new Buffer(buffer) unless Buffer.isBuffer(buffer)
    fs.write(fd, buffer, offset, buffer.length, position, callback)

BFS.read = (fd, buffer, offset, length, position) ->
  fromCallback (handler) ->
    callback = (err, bytesRead, innerBuffer) ->
      if err
        handler(new Error(err))
      else
        handler({fd, bytesRead, buffer:innerBuffer})
    fs.read(fd, buffer, offset, length, position, callback)


BFS.watchFile = (args...) ->
  fromBinder (handler) ->
    fs.watchFile(args..., (curr,prev) ->
      handler({curr, prev})
    )
    (-> fs.unwatchFile(args..., nop))

module.exports = exports.Bacon