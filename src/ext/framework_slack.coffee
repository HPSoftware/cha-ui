module.exports = (Dust)->
  slackFormat = (chunk, context, bodies, params, c)->
    (chunk, context, bodies, params) ->
      body = bodies.block
      chunk.write(c)
      chunk.render(body, context)
      chunk.write(c)
      chunk

  # Markdown - Code
  Dust.helpers.c =  (chunk, context, bodies, params)->
    slackFormat chunk, context, bodies, params, '`'

  # Markdown - Italic
  Dust.helpers.i =  (chunk, context, bodies, params)->
    slackFormat chunk, context, bodies, params, '_'

  # Markdown - Bold
  Dust.helpers.b =  (chunk, context, bodies, params)->
    slackFormat chunk, context, bodies, params, '*'

  # Markdown - Strike
  Dust.helpers.s =  (chunk, context, bodies, params)->
    slackFormat chunk, context, bodies, params, '~'

  Dust.filters.inc = (value)->
    value+1
