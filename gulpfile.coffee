
### =======================================
## Build Script
## Originally created by Sayem Shafayet
## extended by ParticleIT
======================================= ###

gulp = require('gulp')
gutil = require('gulp-util')
connect = require('gulp-connect')
uglify = require('gulp-uglify')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
sourcemaps = require('gulp-sourcemaps')
webserver = require('gulp-webserver')
runSequence = require('run-sequence')
del = require('del')
rename = require("gulp-rename")
pathlib = require 'path'
modify = require('gulp-modify')
cache = require('gulp-cached')
htmlreplace = require('gulp-html-replace')
stripDebug = require('gulp-strip-debug')
os = require('os')
fs = require('fs')
plumber = require('gulp-plumber')
PolymerProject = require('polymer-build').PolymerProject
addServiceWorker = require('polymer-build').addServiceWorker
mergeStream = require('merge-stream')
glob = require('glob')
notify = require("gulp-notify")
javascriptObfuscator = require('gulp-javascript-obfuscator')

###
  The debug build process - 
    1. delete the build-debug directory
    2. copy all contents from src to build-debug
    3. in the [ '/assets', '/elements', '/', 'vendor-assets' ] directories under 'build-debug': 
      a) compile all *.coffee files and generate source maps
    4. keep watch and redo the tasks as necessary
###

paths = 
  src:
    all: [ 'src/**' ]
    allButBower: [ 'src/**', '!src/bower-assets/**']
  debug:
    root: 'build-debug'
    coffee: [
      'build-debug/assets/*.coffee'
      # '.build-debug/static-data/*.coffee'
      'build-debug/behaviors/*.coffee'
      'build-debug/vendor-assets/*.coffee'
      'build-debug/elements/*/*.coffee'
    ]


gulp.task 'clean-debug', ->
  return del paths.debug.root

gulp.task 'copy-debug', ->
  return gulp.src paths.src.all
  .pipe gulp.dest paths.debug.root

gulp.task 'copy-debug-watch', ->
  return gulp.src paths.src.allButBower
  .pipe cache 'copy'
  .pipe gulp.dest paths.debug.root

gulp.task 'build-debug-coffee', ->
  return gulp.src paths.debug.coffee
  .pipe(plumber({errorHandler: notify.onError("Error: <%= error %>")}))
  .pipe cache 'coffee'
  .pipe(sourcemaps.init())
  .pipe(coffee({bare: false}))
  .pipe(sourcemaps.write('.'))
  .pipe rename (path)->
    if path.extname is '.map'
      path.basename = path.basename.replace '.js', '.coffee-compiled.js'
    else if path.extname is '.js'
      path.basename = path.basename += '.coffee-compiled'
    else
      throw new Error 'Unknown Error 1'
    return path
  .pipe modify {
    fileModifier: (vfd, contents)->
      if (''+vfd.path).indexOf('.js.map') > -1
        json = JSON.parse contents
        json.file = json.file.replace '.js', '.coffee-compiled.js'
        contents = JSON.stringify json
      else if (''+vfd.path).indexOf('.js') > -1
        index = contents.indexOf 'sourceMappingURL='
        contents = contents.substr 0, (index + ('sourceMappingURL='.length))
        contents += pathlib.basename(vfd.path)+'.map'
      return contents
  }
  .pipe gulp.dest (vfd)->
    dirname = (pathlib.dirname vfd.path)
    sep = (if os.platform() is 'win32' then '\\' else '/')
    if dirname.indexOf('elements'+ sep) > -1
      dirname = dirname.split sep
      dirname.pop()
      dirname = dirname.join sep
    return dirname



gulp.task 'build-debug', (cbfn)->
  runSequence 'clean-debug', 'copy-debug', 'build-debug-coffee', cbfn
  return

gulp.task 'watch', ->
  gulp.watch paths.debug.coffee, ['build-debug-coffee']
  gulp.watch paths.src.allButBower, ['copy-debug-watch']

gulp.task 'serve-debug', ->
  gulp.src paths.debug.root
  .pipe webserver {
    livereload: {
      port: 36000
    }
    directoryListing: false
    host: 'localhost'
    port: 8005
    open: false
    fallback: '404.html'
  }
  return

gulp.task 'default', (cbfn)->
  runSequence 'build-debug', 'serve-debug', 'watch', cbfn
  return


gulp.task 'concat', ->
  gulp.src [
    'build-debug/vendor-assets/*.js'
    'build-debug/assets/config-production.coffee-compiled.js'
    'build-debug/assets/pages.coffee-compiled.js'
    'build-debug/assets/lib.coffee-compiled.js'
    'build-debug/assets/db.coffee-compiled.js'
    'build-debug/assets/lang.coffee-compiled.js'
    'build-debug/assets/app.coffee-compiled.js'
  ]
  .pipe concat 'all.js'
  .pipe uglify()
  .pipe gulp.dest './build-debug'


gulp.task 'increment-version', ->
  config = fs.readFileSync('src/assets/config-production.coffee', 'utf8')
  searchString = "clientVersion: '"
  index = config.indexOf searchString
  index2 = config.indexOf "'", (index + searchString.length + 1)
  first = config.slice 0, (index + searchString.length)
  middle = config.slice (index + searchString.length), index2 
  last = config.slice index2, config.length
  version = middle.split(".")
  version[2] = (parseInt version[2]) + 1
  middle = version.join(".")
  finalConfig = first + middle + last
  fs.writeFileSync 'src/assets/config-production.coffee', finalConfig
  

gulp.task 'html-replace', ->
  gulp.src 'build-debug/index.html'
  .pipe htmlreplace {
    concat: 'all.js'
    sentry: '<script src="https://cdn.ravenjs.com/3.26.1/raven.min.js" crossorigin="anonymous"></script>
    <script>Raven.config("https://737e518089514fffa628ff1e683e2834@sentry.io/1206718").install();</script>'
    sw: '<script>"serviceWorker"in navigator&&window.addEventListener("load",function(){navigator.serviceWorker.register("./service-worker.js")});</script>'
  }
  .pipe gulp.dest './build-debug'

gulp.task 'build', ->
  runSequence 'clean-debug', 'increment-version', 'copy-debug', 'build-debug-coffee-prod', 'concat', 'html-replace'
  return

gulp.task 'build-onsite', ->
  runSequence 'clean-debug', 'increment-version', 'copy-debug', 'build-debug-coffee-onsite', 'concat', 'html-replace', 'polymer-build-onsite'
  return


# POLYMER BUILD TASK
# ====================================================

gulp.task 'polymer-build', ->
  paths = glob.sync('build-debug/elements/**/*.html')
  fragments = []
  for item in paths
    path = item.split("/").slice(1).join("/")
    fragments.push path
  
  project = new PolymerProject({
    root: 'build-debug'
    entrypoint: "index.html"
    shell: "elements/root-element/root-element.html"
    fragments: fragments
    sources: [
      "elements/**/*.js"
      "elements/**/*.html"
      "assets/**/*"
      "images/**/*"
      "behaviors/*"
      "styles/*"
    ]
    extraDependencies: [
      "all.js"
      "manifest.json"
      "bower-assets/webcomponentsjs/webcomponents-lite.min.js"
      "vendor-assets/he.min.js"
    ]
    lint: {
      rules: ["polymer-1"]
    }
    builds: [{
      bundle: true,
      js: {minify: true},
      css: {minify: true},
      html: {minify: true},
    }]
  })
  
  waitFor = (stream) ->
    return new Promise( (resolve, reject) =>
      stream.on('end', resolve)
      stream.on('error', reject)
    )

  return new Promise (resolve, reject) =>
    del 'polymer-build'
      .then =>
        buildStream = mergeStream(project.sources(), project.dependencies())
          .pipe(project.bundler())
          .pipe(gulp.dest('polymer-build/'))
        return waitFor(buildStream)
      .then =>
       addServiceWorker({
          buildRoot: 'polymer-build/build-debug/'
          project: project
          bundled: true
          swPrecacheConfig: {
            navigateFallback: '/index.html'
            stripPrefix: 'build-debug/'
            staticFileGlobs: [
              '/all.js'
              '/assets/**/*'
              '/bower-assets/webcomponentsjs/webcomponents-lite.min.js'
              '/images/**/*'
            ]
          }
        })



gulp.task 'polymer-build-onsite', ->
  paths = glob.sync('build-debug/elements/**/*.html')
  fragments = []
  for item in paths
    path = item.split("/").slice(1).join("/")
    fragments.push path
  
  project = new PolymerProject({
    root: 'build-debug'
    entrypoint: "index.html"
    shell: "elements/root-element/root-element.html"
    fragments: fragments
    sources: [
      "elements/**/*.js"
      "elements/**/*.html"
      "assets/**/*"
      "images/**/*"
      "behaviors/*"
      "styles/*"
    ]
    extraDependencies: [
      "all.js"
      "bower-assets/webcomponentsjs/webcomponents-lite.min.js"
      "vendor-assets/he.min.js"
    ]
    lint: {
      rules: ["polymer-1"]
    }
    builds: [{
      bundle: true,
      js: {minify: true},
      css: {minify: true},
      html: {minify: true},
    }]
  })
  
  waitFor = (stream) ->
    console.log "-------------->", stream
    return new Promise( (resolve, reject) =>
      stream.on('end', resolve)
      stream.on('error', reject)
    )

  return new Promise (resolve, reject) =>
    del 'polymer-build'
      .then =>
        buildStream = mergeStream(project.sources(), project.dependencies())
          .pipe(project.bundler())
          .pipe(gulp.dest('polymer-build/'))
        return waitFor(buildStream)
      .then =>
       addServiceWorker({
          buildRoot: 'polymer-build/build-debug/'
          project: project
          bundled: true
          swPrecacheConfig: {
            navigateFallback: '/index.html'
            stripPrefix: 'build-debug/'
            staticFileGlobs: [
              '/all.js'
              '/assets/**/*'
              '/bower-assets/webcomponentsjs/webcomponents-lite.min.js'
              '/images/**/*'
            ]
          }
        })
  
# Production Only, Removes Log Statements
gulp.task 'build-debug-coffee-prod', ->
  return gulp.src paths.debug.coffee
  .pipe cache 'coffee'
  .pipe(sourcemaps.init())
  .pipe(coffee({bare: false}).on('error', gutil.log))
  .pipe(uglify({
    compress:
      drop_console: true
  }))
  .pipe(sourcemaps.write('.'))
  .pipe rename (path)->
    if path.extname is '.map'
      path.basename = path.basename.replace '.js', '.coffee-compiled.js'
    else if path.extname is '.js'
      path.basename = path.basename += '.coffee-compiled'
    else
      throw new Error 'Unknown Error 1'
    return path
  .pipe modify {
    fileModifier: (vfd, contents)->
      if (''+vfd.path).indexOf('.js.map') > -1
        json = JSON.parse contents
        json.file = json.file.replace '.js', '.coffee-compiled.js'
        contents = JSON.stringify json
      else if (''+vfd.path).indexOf('.js') > -1
        index = contents.indexOf 'sourceMappingURL='
        contents = contents.substr 0, (index + ('sourceMappingURL='.length))
        contents += pathlib.basename(vfd.path)+'.map'
      return contents
  }
  .pipe gulp.dest (vfd)->
    dirname = (pathlib.dirname vfd.path)
    sep = (if os.platform() is 'win32' then '\\' else '/')
    if dirname.indexOf('elements'+ sep) > -1
      dirname = dirname.split sep
      dirname.pop()
      dirname = dirname.join sep
    return dirname

gulp.task 'build-debug-coffee-onsite', ->
  return gulp.src paths.debug.coffee
  .pipe cache 'coffee'
  .pipe(sourcemaps.init())
  .pipe(coffee({bare: false}).on('error', gutil.log))
  .pipe(uglify({
    compress:
      drop_console: true
  }))
  .pipe(javascriptObfuscator())
  .pipe(sourcemaps.write('.'))
  .pipe rename (path)->
    if path.extname is '.map'
      path.basename = path.basename.replace '.js', '.coffee-compiled.js'
    else if path.extname is '.js'
      path.basename = path.basename += '.coffee-compiled'
    else
      throw new Error 'Unknown Error 1'
    return path
  .pipe modify {
    fileModifier: (vfd, contents)->
      if (''+vfd.path).indexOf('.js.map') > -1
        json = JSON.parse contents
        json.file = json.file.replace '.js', '.coffee-compiled.js'
        contents = JSON.stringify json
      else if (''+vfd.path).indexOf('.js') > -1
        index = contents.indexOf 'sourceMappingURL='
        contents = contents.substr 0, (index + ('sourceMappingURL='.length))
        contents += pathlib.basename(vfd.path)+'.map'
      return contents
  }
  .pipe gulp.dest (vfd)->
    dirname = (pathlib.dirname vfd.path)
    sep = (if os.platform() is 'win32' then '\\' else '/')
    if dirname.indexOf('elements'+ sep) > -1
      dirname = dirname.split sep
      dirname.pop()
      dirname = dirname.join sep
    return dirname

es = require 'event-stream'
log = require('gulp-util').log

logFile = (es) ->
  es.map (file, cb) ->
    log file.path
    cb()

gulp.task "logFile", ->
  gulp.src('./src/elements/**/*.html')
  .pipe logFile es

