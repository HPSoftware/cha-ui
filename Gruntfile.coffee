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
