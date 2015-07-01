
{docopt} = require('docopt')
bb       = require('bluebird')
fs       = bb.promisifyAll(require 'fs')
beml     = require('beml')
jade = require 'jade'
_ = require 'underscore'

doc = """
Usage:
    json2html-biblio-cli [-f INPUT] [-t JADE -c CONFIG] [-o HTML]
    json2html-biblio-cli -h | --help 

Options:
    -f, --file INPUT        Optional, original biblio.json file, if missing stdin is assumed.
    -o, --output HTML       Optional, output filename.
    -t, --template JADE     Specify Jade template to fill with this data.
    -c, --config CONFIG     JSON configuration file of the site (has a `baseUrl` property)
"""

get-option = (a, b, def, o) ->
    if not o[a] and not o[b]
        return def
    else 
        return o[b]

o = docopt(doc)


filename      = get-option('-f' , '--file'     , '/dev/stdin'  , o)
output        = get-option('-o' , '--output'   , '/dev/stdout' , o)
template-name = get-option('-t' , '--template' , "", o)
config        = get-option('-c' , '--config'   , "", o)


read-json = -> JSON.parse(fs.readFileSync(it, 'utf-8'))

fs.readFileAsync(filename, 'utf-8').then (data) ->
    data = JSON.parse(data) 
    for p in data 
        process-data(p)

    if template-name == ""
        if output == '/dev/stdout'
            console.log JSON.stringify(data, 0, 4)
        else
            fs.writeFileAsync(output, JSON.stringify(data, 0, 4), 'utf8').then ->
                console.error "done"
    else
        locals   = { filename: template-name, data: data, pretty: true }
        conf   = read-json config
        locals   = _.extend(locals, conf)
        template = fs.readFileSync(template-name, 'utf-8')
        result   = jade.compile(template, locals)(locals)
        result   = beml.process(result)

        if output == '/dev/stdout'
            console.log result
        else
            fs.writeFileAsync(output, result, 'utf8').then ->
                console.error "done"

     
process-data = (p) ->
          p.keyword ?= []
          p.type = 
            | 'bookc' in p.keyword      => 'bookchapter'
            | 'journal' in p.keyword    => 'journal'
            | 'book'    in p.keyword    => 'book'
            | 'conference' in p.keyword => 'conference'
            | 'techreport' in p.keyword => 'techreport'
            | 'workshop' in p.keyword   => 'workshop'
            | 'patent' in p.keyword     => 'patent'
            | 'techreport' in p.keyword => 'techreport'
            | 'talk' in p.keyword       => 'talk'
            | 'forum' in p.keyword       => 'talk'
            | 'thesis' in p.keyword     => 'thesis'
            | _                         => 'not categorized'


          if p.type == 'journal'
            p.booktitle = p.journal.name

          if p.type == 'thesis'
            p.booktitle = p.school 

          if p.type == 'techreport'
            p.booktitle = p.institution

          if p.type == 'patent'
            p.booktitle = "#{p.address} #{p.number}"

          if p.type == 'talk'
            p.booktitle = "#{p.address}"

          if not p.pages?
            p.pages = '—'

          if not p['bdsk-url-1']?
            p.link = url: 'vittorio.zaccaria@polimi.it'
          else 
            p.link = url: p['bdsk-url-1']

          if p.booktitle?
            s  = p.booktitle
            n  = s.index-of(':')
            if n != -1
              s  = s.substring(0, n)
              p.smartbooktitle = s
            else 
              p.smartbooktitle = s
    