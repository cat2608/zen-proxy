###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/zenproxy
###
"use strict"

# Libraries
http      = require "http"

ZenProxy =

  addHost: (rule_name, host, port) ->
    for rule in global.config.rules when rule.name is rule_name
      rule.hosts.push
        address: host
        port   : port
      console.log "New host in #{rule.name}", rule.hosts
      break

  removeHost: (rule_name, server) ->
    for rule, index in global.config.rules when rule.name is rule_name
      rule.hosts.splice(index, 1)
      console.log "remove host in #{rule.name}", rule.hosts
      break

  run: ->
    console.log "ZENproxy starting..."
    queries = {}
    http.createServer((request, response) ->
      url   = "#{request.headers.host}#{request.url}"
      index = queries[url]
      rule  = if index >= 0 then global.config.rules[index] else __getRule url

      if rule
        if rule.strategy is "random"
          host = rule.hosts[Math.floor Math.random() * (rule.hosts.length)]
        else if rule.strategy is "roundrobin"
          host = rule.hosts.shift()
          rule.hosts.push host
        console.log "> #{rule.name} (#{rule.strategy}) << #{host.address}:#{host.port}"
        __proxyRequest request, response, rule, host.address, host.port
      else
        response.writeHead 200, "Content-Type": "text/plain"
        response.write "ZENproxy"
        response.end()
    ).listen config.port or 80

    __getRule = (url) ->
      for rule, index in global.config.rules when rule.domain? and rule.query?
        port = if global.config.port is 80 then "" else ":#{global.config.port}"
        regexQuery = new RegExp "#{rule.domain}#{port}#{rule.query}"
        if url.match regexQuery
          queries[url] = index
          return rule

    __proxyRequest = (request, response, rule, address, port = 80) ->
      options =
        hostname: address
        port    : port
        headers : request.headers
        path    : request.url
        method  : request.method
        agent   : false                 # Turn off socket pooling

      now = new Date()
      proxy = http.request options, (res) =>
        console.log "> #{rule.name} (#{rule.strategy}) >> #{address}:#{port} #{(new Date() - now)}ms"

        response.setHeader key, value for key, value of res.headers
        res.pipe response, end: true

      proxy.on "error", (error) ->
        console.log "ZENproxy (error): #{error}"

      request.pipe proxy, end: true

module.exports = ZenProxy
