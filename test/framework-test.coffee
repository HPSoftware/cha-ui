assert = require 'assert'
fs = require 'fs-extra'
async = require 'async'
Framework = require '../src/framework.coffee'
process.env.CHA_LOCALE='zh-CN'
robot = {}
robot.adapterName = 'slack'
robot.logger = {}
robot.logger.debug = (str)->
  console.log str
robot.send = (env, strings...)  ->
  assert.ok strings[0].text.includes "中   文"



robot.responseMiddleware = (middleware) ->
    return undefined
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


Framework.initHubot robot
path = require("path").join __dirname, "./template/cha-tpls.yaml"
Framework.init path, robot.adapterName



describe 'Framework', () ->
  fs.mkdirsSync './locales'
  fs.copySync './test/locales', './locales'

  after ()->
    fs.removeSync './locales'

  describe 'translate', (done) ->
    it 'Template mapping fields and I18n supported.', () ->
      fs.mkdirsSync './locales'
      fs.copySync './test/locales', './locales'
      msg =
        name: "kick_off_warroom"
        # type: "text"
        model:
          title: "Digital banking slow"
          id: "IM1293"
          users: ['a','b','c']
          description: "Digital banking is very slow, timeout"
          severity: "high"
          submitter: "James, T, Cook"
          affectedService:
            id: "CI192283",
            name: "digital-banking"
          "@url": "/api/urest/r/incident/IM1293"
          text: "This is part title 1"
          color: "good"
          parts:[
            {
              fields:[
                {
                  "title": "field 1",
                  "value": "value 1"
                },
                {
                  "title": "field 2",
                  "value": "value 2"
                },
                {
                  "title": "field 3",
                  "value": "value 3"
                }
              ]
            }
          ]


      content = new Framework.Message msg.name, msg.model, msg.type
      env={}
      robot.send env, content
