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


table = require 'easy-table'
I18 = require 'i18next'
Backend = require 'i18next-sync-fs-backend'

# environment variable CHA_LOCALE AND CHA_NAMESPACE
Init_optinos =
  debug: false
  ns: process.env.CHA_NAMESPACE || 'translation'
  keySeparator: false,
  lng: process.env.CHA_LOCALE || 'en-US'
  fallbackLng: 'en-US'
  backend:
    loadPath: 'locales/{{lng}}/{{ns}}.json'
I18.use(Backend).init Init_optinos

module.exports = (Dust)->
  Dust.filters.inc = (value)->
    value + 1

  Dust.filters.color = (value)->
    colors = Dust?.style?.colors
    r = if colors then colors[value] else value
    r

  Dust.helpers.label = (chunk, context, bodies, params)->
    if Dust.labels
      if params.t
        label = Dust.labels[params.t]
        chunk.write label
    chunk

  Format = (chunk, context, bodies, params, c)->
    (chunk, context, bodies, params) ->
      body = bodies.block
      chunk.write(c)
      chunk.render(body, context)
      chunk.write(c)
      chunk

  Dust.helpers.c =  (chunk, context, bodies, params)->
    Format chunk, context, bodies, params, ''

  Dust.helpers.i =  (chunk, context, bodies, params)->
    Format chunk, context, bodies, params, ''

  Dust.helpers.b =  (chunk, context, bodies, params)->
    Format chunk, context, bodies, params, ''

  Dust.helpers.s =  (chunk, context, bodies, params)->
    Format chunk, context, bodies, params, ''

  Dust.helpers.table = (chunk, context, bodies, params)->
    fields = context.stack.head.fields
    t = new table
    fields.forEach (product) ->
      t.cell('title', product.title)
      t.cell('value', product.value)
      t.newRow()

    chunk.write t.toString()
    chunk

  Dust.helpers.t = (chunk, context, bodies, params)->
    chunk.write I18.t params.val,  {ns: Init_optinos.ns}
