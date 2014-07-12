/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      1.04.22
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
    @author       Catalina Oyaneder <catalina@tapquo.org> || @cataflu
*/
"use strict";

var CoffeeScript= require("coffee-script");
var fs          = require("fs");
var yaml        = require('js-yaml');
var path        = require('path');

// Register CoffeeScript if exits
if(CoffeeScript.register) CoffeeScript.register();

return require("./lib/zenproxy").run();
