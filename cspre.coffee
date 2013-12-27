###
  CSPre - CoffeeScript Preprocessor
  Changing the way you write coffeescript pages.
  Authors: Joshua Davison <joshua@davison.asia>
###

fs = require 'fs'
path = require 'path'
coffeescript = require 'coffee-script'

defaultOptions =
  index: 'index'
  ext: 'coffee'
  cache: false
  cd: './'

options = {} #This is set when initialised.

createFunction = (contents) ->
  new Function 'req', 'res', 'next', 'console', contents

expressMiddleware = (req, res, next) ->
  cd = path.resolve options.cd
  p = cd + path.resolve '/', req._parsedUrl.pathname #Keep the path safe! (ie. disallow '../')
  ending = p.substr (- path.sep.length) #Just in-case we're on Windows ('\\')
  if ending is path.sep #Requesting a directory, Use index.fil
    p += "#{ options.index }.#{ options.ext }"
  getFile p, (contents) ->
    if !contents?
      next null #If it's undefined, Let's return!
    else
      contents(req, res, next, console);

getFile = (p, cb) ->
  fs.stat p, (err, stats) ->
    if err isnt null #Error: ENOENT, etc. (file not found)
      if path.extname(p) isnt ".#{ options.ext }" #eg. /index instead of /index.coffee
        getFile "#{ p }.#{ options.ext }", cb #Dust yourself off and try again. 
      else
        cb null
    else if stats.isDirectory() is true
      p += "#{ path.sep }#{ options.index }.#{ options.ext }" #add /index.coffee and retry
      getFile p, cb
    else if stats.isFile() is true #Yay! We have a file!
      if path.extname(p) isnt ".#{ options.ext }" #Oops. Not the file we want!
        getFile "#{ p }.#{ options.ext }", cb #Dust yourself off and try again. 
      else
        #FINALLY - Now, Let's get file and cache it?
        fileContents = ''
        fs.readFile p, (err, data) ->
          #console.log 'Last change: ' + stats.ctime.getTime()
          #Later we use this to cache results in database.
          if (err)
            cb null
          else
            try
              compiled = coffeescript.compile data.toString(), bare: on
              cb createFunction compiled
            catch {location, message}
              if location?
                result = "res.writeHead(200, {'Content-Type': 'text/html'});"
                result += "res.end('<strong>Parse Error</strong>: #{message} in <strong>#{ p }</strong>"
                result += " on line <strong>#{ location.first_line + 1 }</strong>');"
                cb createFunction result
    else #Not a file, might be device etc.
      cb null

module.exports = (opts = {}) ->
  opts.index ?= defaultOptions.index
  opts.ext ?= defaultOptions.ext
  opts.cd ?= defaultOptions.cd
  options = opts #Set options
  return expressMiddleware
