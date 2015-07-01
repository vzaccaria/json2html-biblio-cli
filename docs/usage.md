Usage:
    json2html-biblio-cli [-f INPUT] [-t JADE -c CONFIG] [-o HTML]
    json2html-biblio-cli -h | --help 

Options:
    -f, --file INPUT        Optional, original biblio.json file, if missing stdin is assumed.
    -o, --output HTML       Optional, output filename.
    -t, --template JADE     Specify Jade template to fill with this data.
    -c, --config CONFIG     JSON configuration file of the site (has a `baseUrl` property)
