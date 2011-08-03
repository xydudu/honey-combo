###
 some functions
 xydudu 8.3/2011
###

fs = require 'fs'
jsp = require( 'uglify-js' ).parser
pro = require( 'uglify-js' ).uglify

projectPaths =
    tazai: '/www/js/honey.svn/'
    revive: '/www/revive/public/js/'


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
        
        fs.readFile filename, ( ( $f ) ->
            
            return ( $err, $data ) ->
                if $err
                    content = "/*** #{ $f } 404 ***/"
                else
                    ast = jsp.parse $data.toString()
                    ast = pro.ast_mangle ast
                    ast = pro.ast_squeeze ast
                    content = "\n/*** #{ $f } loaded ***/\n"
                    content += ";"+ pro.gen_code ast
                
                arr[ $f ] = content
                
                $fun arr if count is l
                count += 1

        )( filename )

exports.sendWithHead = ( $data, $key ) ->

    ###
    @header 'Content-Type', 'text/plain'
    @header 'Content-Length', $data.length
    @header 'Cache-Control', 'max-age=315360000'
    @header 'Vary', 'Accept-Encoding'
    @header 'Date', new Date()
    @header 'Age', '300'
    @header 'Connection', 'close'
    @header 'Accept-Ranges', 'bytes'
    @header 'Transfer-Encoding', 'gzip'
    @header 'Expires', new Date((new Date()).getTime() + (60 * 60 * 1000 * 365 * 10))
    ###

    header =
        'Content-Type': 'application/x-javascript'
        'Cache-Control': 'max-age=315360000'
        #'Content-Encoding': 'gzip'
        #'Connection': 'close'
        #'Content-Length': $data.length + 1
        'Etag': $key

    @writeHead 200, header
    @write $data
    @end()
