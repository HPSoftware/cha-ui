module.exports = (Dust)->
  flowdockFormat = (chunk, context, bodies, params, c)->
    (chunk, context, bodies, params) ->
      body = bodies.block

      chunk.write(c)
      chunk.render(body, context)
      chunk.write(c)
      chunk

  # Markdown - inline Code
  Dust.helpers.ic =  (chunk, context, bodies, params)->
    flowdockFormat chunk, context, bodies, params, '`'

  # Markdown - Code
  Dust.helpers.c =  (chunk, context, bodies, params)->
    flowdockFormat chunk, context, bodies, params, '```'

  # Markdown - Italic
  Dust.helpers.i =  (chunk, context, bodies, params)->
    flowdockFormat chunk, context, bodies, params, '_'

  # Markdown - Bold
  Dust.helpers.b =  (chunk, context, bodies, params)->
    flowdockFormat chunk, context, bodies, params, '**'

  Dust.filters.inc = (value)->
    value+1
