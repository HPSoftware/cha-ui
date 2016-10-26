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


Api = require ('./api')
Winston = require('winston')
Winston.level = process.env.CHA_UI_LOGGER_LEVEL || 'warn'
_ = require 'lodash'

class Message
  constructor: (@name, @model, @type='auto')->

escapeJsonString = (str)->
  str
    .replace(/[\\]/g, '\\\\')
    .replace(/[\/]/g, '\\/')
    .replace(/[\b]/g, '\\b')
    .replace(/[\f]/g, '\\f')
    .replace(/[\n]/g, '\\n')
    .replace(/[\r]/g, '\\r')
    .replace(/[\t]/g, '\\t')

renderMessage = (msg, adapterName)->
  Winston.debug "Render message #{msg.name}"
  Api.Template.render(msg.name, msg.model)
    .then (m)->
      m = escapeJsonString(m)
      Winston.debug "Framework render result", m
      m = JSON.parse m
      Winston.debug m
      msg =
        data: m
      Api.renderMessage(msg, adapterName)

processMessage = (strs, robot, fx)->
  list = _.map strs, (s)->
    adapterName = robot.adapterName
    if s.type is 'auto'
      (require "./ext/framework_#{adapterName}")(Api.Dust)
    else if s.type is 'text'
      adapterName = 'base'
      (require "./ext/framework_base")(Api.Dust)
    renderMessage s, adapterName


  Promise.all(list)
    .then (ss)->
      _.forEach ss, (s)->
        t = s
        try
          s = escapeJsonString(s)
          s = JSON.parse(s)
        catch err
          s = t
          Winston.debug err
        fx(s)
    .catch (e)->
      robot.logger.debug e

initHubot = (robot)->
  Api.initHubot robot

  if robot._chaUIFrameworkReady
    return
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
    robot.logger.debug "To handle response.#{context.method} #{strs}"
    if strs.length > 0
      m = strs[0]
      if m instanceof Message
        processMessage strs, robot, (s)->
          s.username = robot.name
          s.as_user = false
          robot.logger.debug "Framework To send", s
          context.response[context.method](s)
        return
      else
        robot.logger.debug "Not a Cha-UI Message"
    next()
  robot._chaUIFrameworkReady = true

init = (chaUICfg, tool)->
  Api.loadCfg chaUICfg
  (require "./ext/framework_base")(Api.Dust)
  if tool is 'slack' || tool is 'flowdock'
    (require "./ext/framework_#{tool}")(Api.Dust)

module.exports = {
  Message,
  initHubot,
  init
}
