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
