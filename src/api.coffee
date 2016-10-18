###
Copyright 2016 Hewlett-Packard Development Company, L.P.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing,
Software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
###


_ = require 'lodash'
Dust = require 'dustjs-helpers'
Promise = require "bluebird"
Winston = require('winston')
Winston.level = process.env.CHA_LOGGER_LEVEL || 'warn'
yaml = require 'node-yaml'

# The message class
class Message
  constructor: (@data={})->

  text: (text) ->
    @data.text = text
    return @

  part: () ->
    part = new Part(@)
    @data.parts = [] if not @data.parts
    @data.parts.push part
    part

# Part action
class Action
  constructor: (@part, type ='button' )->
    @data =
      type: type

  name: (n)->
    @data.name = n
    @

  text: (t)->
    @data.text = t
    @

  style: (s)->
    @data.style = s
    @

  value: (v)->
    @data.value = v
    @

  # Provide nothing but button here. There are no other types of actions today.
  type: (type='button')->
    @data.type = type
    @

  confirm: (text, title='', ok_text='Okay', dismiss_text='Cancel') ->
    @data.confirm =
      title: title
      text: text
      ok_text: ok_text
      dismiss_text: dismiss_text
    @

# Message part
class Part
  constructor: (@message)->
    @data = {}

  pretext: (text)->
    @data.pretext = text
    @

  fallback: (text)->
    @data.fallback = text
    @

  title: (text)->
    @data.title = text
    @

  title_link: (text)->
    @data.title_link = text
    @

  text: (text)->
    @data.text = text
    @

  color: (c)->
    @data.color = c
    @

  footer: (f)->
    @data.footer = f
    @

  footer_icon: (footer_icon)->
    @data.footer_icon = footer_icon
    @

  field: (title, value, short = 'true')->
    @data.fields = [] if not @data.fields
    f =
      title: title
      value: value
      short: short

    @data.fields.push f
    @

  author_name: (author_name)->
    @data.author_name = author_name
    @

  author_link: (author_link)->
    @data.author_link = author_link
    @

  thumb_url: (thumb_url)->
    @data.thumb_url = thumb_url
    @

  ts: (ts)->
    @data.ts = ts
    @

  action: ->
    @data.actions = [] if not @data.actions
    a = new Action(@)
    @data.actions.push a
    a

# Template wrapper
class Template
  constructor: ()->

  add: (name, template)->
    # Winston.debug "Add template", template
    c = Dust.compile template, name
    Dust.loadSource c
    return @

  render: (name, data) ->
    f = (resolve, reject)->
      Dust.render name, data, (err, out)->
        if err
          reject err
        else
          resolve out
    return new Promise(f)

T = new Template()

loadCfg = (path, ns)->
  data = yaml.readSync path,
  encoding: 'utf-8',
  schema: yaml.schema.defaultSafe
  if data
    _.forEach data.templates, (v,k)->
      name = if ns
               "#{ns}.#{k}"
             else
               k
      Winston.debug "Add template #{name}"
      T.add name, v
    _.forEach data.widgets, (v, k)->
      name = if ns
              "#{ns}.widget.#{k}"
             else
              k
      Winston.debug "Add Widget #{name}"
      T.add name, v

    Dust.style = _.merge Dust.style, data.style
    Dust.labels = _.merge Dust.labels, data.labels
  else
    Winston.error 'Failed to load yaml file: #{path}'

renderMessage = (msg, adapterName)->
    Winston.debug "Render message cha.api.message_#{adapterName}"
    T.render("cha.api.message_#{adapterName}", msg.data)


processMessage = (strs, robot, fx)->
  list = _.map strs, (s)->
    renderMessage s, robot.adapterName
  Promise.all(list)
    .then (ss)->
      _.forEach ss, (s)->
        s = JSON.parse(s)
        fx(s)
    .catch (e)->
      robot.logger.debug e


initHubot = (robot)->
  if robot._chaApiReady
    return
  path = require("path").join(__dirname, "./api-tpls_#{robot.adapterName}.yaml")
  loadCfg path, "cha.api"
  path = require("path").join(__dirname, "./api-tpls_base.yaml")
  loadCfg path, "cha.api"

  robot.send = _.wrap robot.send, (func, env, strs...)->
    if strs.length >0
      m = strs[0]
      if(m instanceof Message)
        processMessage strs, robot, (s)->
          func.apply(robot, [env, s])
        return
    func.apply(robot, [env, strs...])

  robot.responseMiddleware (context, next, done)->
    strs = context.strings
    # robot.logger.debug "To handle response", context
    if strs.length > 0
      m = strs[0]
      if m instanceof Message
        processMessage strs, robot, (s)->
          s.username = robot.name
          s.as_user = false
          robot.logger.debug "API To send", s
          context.response[context.method](s)

        return
    next()
  robot._chaApiReady = true

module.exports = {
  Message,
  Template:T,
  loadCfg,
  initHubot,
  renderMessage,
  Dust
}
