#!/usr/bin/env node
"use strict";

var _require = require("docopt");

var docopt = _require.docopt;

var _ = require("lodash");
var fs = require("fs");

var getOption = function (a, b, def, o) {
  "use strict";
  if (!_.isUndefined(o[a])) {
    return o[a];
  } else {
    if (!_.isUndefined(o[b])) {
      return o[b];
    } else {
      return def;
    }
  }
};

var getOptions = function (doc) {
  "use strict";
  var o = docopt(doc);
  var help = getOption("-h", "--help", false, o);
  return {
    help: help
  };
};

var doc = fs.readFileSync(__dirname + "/docs/usage.md", "utf8");

var main = function () {
  "use strict";

  var _getOptions = getOptions(doc);

  var help = _getOptions.help;
};

main();
