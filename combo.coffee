### 
  ok, do something right, this is a combo handle API for honey
  xydudu 7.27/2011

  youapi/project/version/?file1.js&file2.js&file3.js

  TODO
    * header
    * cache
    * css combo

###

sys = require 'sys'
url = require 'url'
path = require 'path'
express = require 'express'
x = require './unity'
keygrip = require 'keygrip'
app = express.createServer()

app.use express.bodyParser()
app.enable 'view cache'

cacheFiles = {}

app.get '/:project/:version', ( req, res ) ->
    
    [ project, version ] = [ req.params.project, req.params.version ]

    files = x.getFiles req.query, project
    cacheKey = keygrip( files ).sign version + project

    if !files
        res.send( '/** sorry , 404  **/' )
        return
        
    content = '/*OK*/'
    console.log req.header('If-None-Match')
    if req.header('If-None-Match') is cacheKey
        res.writeHead 304, 'Content-Type': 'application/x-javascript'
        res.end()
    else
        x.readFiles files, ( $content )->
            for filename in files
                content += $content[ filename ]

            x.sendWithHead.call res, content, cacheKey


app.listen '8888'



