var {
    generateProject
} = require("diy-build")

generateProject(_ => {

    _.collect("docs", _ => {
        _.cmd("./node_modules/.bin/mustache package.json docs/readme.md | ./node_modules/.bin/stupid-replace '~USAGE~' -f docs/usage.md > readme.md")
    })

    _.collectSeq("all", _ => {
        _.collect("build", _ => {
            _.livescript("src/*.ls")
            _.cmd("mkdir -p ./man")
            _.cmd("pandoc -s -f markdown -t man readme.md > ./man/json2html-biblio.1")
        })
        _.cmd("((echo '#!/usr/bin/env node') && cat ./src/index.js) > index.js", "./src/index.js")
        _.cmd("chmod +x ./index.js")
    })

    _.collect("test", _ => {
        _.cmd("make all")
        _.cmd("./node_modules/.bin/mocha ./lib/test.js")
    })

    _.collect("update", _ => {
        _.cmd("make clean && ./node_modules/.bin/babel configure.js | node")
    });

    ["major", "minor", "patch"].map(it => {
        _.collect(it, _ => {
            _.cmd(`make all`)
            _.cmd(`./node_modules/.bin/xyz -i ${it}`)
        })
    })

})
