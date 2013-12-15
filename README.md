Coffee-Script preprocessor
===
This is an alpha version - We do not recommend using it in production environments, etc.<br>
Options, Objects, and syntax are subject to change.

## CSPre allows you to run a CoffeeScript file directly as if it was a static resource.

### Usage

The easiest way to use CSP is to Using this middleware is as simple as:

    var cspre = require('cspre')()

However, you may wish to specify options, ie.

    var options = { index: 'default', ext: '.cs', cd: '/home/ }
    var cspre = require('cspre'){options}

### Options

CSPre currently supports four options
#### index
This is the default file to serve when a directory is requested
##### default: 'index'

#### ext
This is the default file extension that will be checked if omitted in the request
##### default: '.coffee'

#### cd
Directory to serve files from (relative to current script's location).
##### default: './'

#### cache
There is no cache in the current implementation
##### default: false

### Accessible Objects
Three objects are available from within CSPre scripts: *[req](http://expressjs.com/api.html#req.params)*, *[res](http://expressjs.com/api.html#res.status)* and *next*.<br>
Please see the Express API documentation for more information.

Requirements
---
  - [node.js](http://nodejs.org/)
  - [Express](http://expressjs.com/)