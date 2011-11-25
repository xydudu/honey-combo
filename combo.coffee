### 
  ok, do something right, this is a combo handle API for honey
  xydudu 7.27/2011

  youapi/project/version/?file1.js&file2.js&file3.js

  TODO
    * css combo

###
path = require 'path'
express = require 'express'
gzip = require 'gzip'
x = require './unity'
keygrip = require 'keygrip'
app = express.createServer()

app.use express.bodyParser()
app.enable 'view cache'


app.get '/combo/:project/:version', ( req, res )->
    
    [ project, version ] = [ req.params.project, req.params.version ]

    files = x.getFiles req.query, project
    cacheKey = keygrip( files ).sign version + project

    if !files
        res.send( '/** sorry , 404  **/' )
        return
        
    content = '/* OK, Honey combo handler is working! */'
    if req.header('If-None-Match') is cacheKey
        res.writeHead 304, 'Content-Type': 'application/x-javascript'
        res.end()
    else
        temp = "#{ __dirname }/temp/#{ project }/#{ version }/#{ cacheKey }"
        if path.existsSync( temp )
            x.getTemp temp, (  $content )->
                gzip $content, ( $err, $data )->
                    if not $err
                        x.sendWithHead.call res, $data, cacheKey
        else
            x.readFiles files, ( $content )->
                for filename in files
                    content += $content[ filename ]
                
                #x.sendWithHead.call res, content, cacheKey
                gzip content, ( $err, $data )->
                    if not $err
                        x.saveToTemp [ project, version, cacheKey ], content
                        x.sendWithHead.call res, $data, cacheKey

app.get '/combo', ( req, res )->
    res.send '<title>Combo Handler - Honey Lab</title>合并javascript文件，来自 @Hunantv.com'

app.listen '8888'

