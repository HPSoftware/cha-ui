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
