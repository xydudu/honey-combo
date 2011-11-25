###
 some functions
 xydudu 8.3/2011

###

fs = require 'fs'
path = require 'path'
request = require 'request'
jsp = require( 'uglify-js' ).parser
pro = require( 'uglify-js' ).uglify
wrench = require 'wrench'


projectPaths 
    tazai: 'http://js.tazai.com/honey-2.0/'
    honey: 'http://honey.local/'
    test: 'http://honey.local/'

exports.getFiles = ( $query, $project ) ->
    
    return false if not $query
    
    files = []
    files.push projectPaths[$project] + key for key of $query
    return files

exports.readFiles = ( $files, $fun ) ->

    l = $files.length
    count = 1
    ast = ''
    content = ''
    arr = {}
    
    for filename in $files
        #fs.readFile filename, ( ( $f ) ->
        request.get uri: filename, encode: 'utf8', ( ( $f ) ->
            return ( $err, $res, $data ) ->
                if $err
                    content = "/*** #{ $f } 404 ***/"
                else
                    ast = jsp.parse $data
                    ast = pro.ast_mangle ast
                    ast = pro.ast_squeeze ast
                    #console.log $data
                    content = "\n/*** #{ $f } loaded ***/\n"
                    content += ";"+ pro.gen_code ast
                
                arr[ $f ] = content
                
                $fun arr if count is l
                count += 1

        )( filename )

exports.sendWithHead = ( $data, $key ) ->
   
    header =
        'Content-Type': 'application/x-javascript'
        'Cache-Control': 'max-age=315360000'
        'Expires': new Date((new Date()).getTime() + (60 * 60 * 1000 * 365 * 10))
        'Etag': $key
        'Content-Encoding': 'gzip'
        'Content-Length': $data.length

    @writeHead 200, header
    @write $data
    @end()

exports.getTemp = ( $temp, $fun )->

    fs.readFile $temp, 'utf8', ( $err, $data )->
        if not $err then $fun $data

exports.saveToTemp = ( $vars, $temp )->
    
    dirs =
        temp: "#{ __dirname }/temp"
        project: "#{ __dirname }/temp/#{ $vars[0] }"
        version: "#{ __dirname }/temp/#{ $vars[0] }/#{ $vars[1] }"

    if not path.existsSync dirs.version
        try
            wrench.rmdirSyncRecursive dirs.project
        catch error
            console.log 'do nothing'
        wrench.mkdirSyncRecursive dirs.version
           
    fs.writeFile "#{ dirs.version }/#{ $vars[2] }", $temp, 'utf8', ( $err )->
            if $err
                console.log $err
            else
                console.log 'It\'s saved!'
 
