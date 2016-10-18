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


module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  grunt.initConfig
    mochaTest:
      test:
        options:
          report: 'spec'
          require: 'coffee-script'
        src: ['test/*.coffee']
    coffeelint:
      app: ['src/*.coffee', 'test/*.coffee', 'Gruntfile.coffee', 'index.coffee']
      options:
        configFile: 'coffeelint.json'

  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.registerTask('test', ['mochaTest'])
  grunt.registerTask('default', ['test'])
