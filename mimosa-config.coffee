exports.config =
  modules: [
    'import-source'
    'rename'
    'copy'
    'coffeescript'
    # 'combine'
    'minify-js'
    'minify-json'
    'groundskeeper'
    'server'
  ]
  
  watch:
    sourceDir: 'src'
    exclude: ['bower-assets']
    javascriptDir: null
    compiledDir: 'build-debug'
  server:
    port: 8006
    defaultServer:
      enabled: true
      onePage: true
    views:
      path: 'build-debug'
      compileWith: 'html',
      extension: '.html',
  combine:
    removeCombined: {
      enabled:false
    }
    folders: [{
      folder: 'assets'
      output: 'all.js'
      include: [/\.js$/]
      order:[
        'database-engine.coffee-compiled.js'
        'date-format-library.coffee-compiled.js'
        'evolvenode-stdlib-0.0.3.coffee-compiled.js'
        'config.coffee-compiled.js'
        'pages.coffee-compiled.js'
        'lib.coffee-compiled.js'
        'db.coffee-compiled.js'
        'lang.coffee-compiled.js'
        'app.coffee-compiled.js'
      ]
    }]

  rename:
    map: [
      [/(build-debug\\behaviors\\.*).js/g, '$1.coffee-compiled.js']
      [/(build-debug\\elements\\.*\\.*).js/g, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\config).js/, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\pages).js/, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\lib).js/, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\db).js/, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\lang).js/, '$1.coffee-compiled.js']
      [/(.build-debug\\assets\\app).js/, '$1.coffee-compiled.js']
      # [/(build-debug\\assets\\.*).js/g, '$1.coffee-compiled.js']
      [/(build-debug\\vendor-assets\\date-format-library).js/, '$1.coffee-compiled.js']
      [/(build-debug\\vendor-assets\\database-engine).js/, '$1.coffee-compiled.js']
    ]
  importSource:
    usePolling: false
    copy: [
      {
        from: 'src/bower-assets'
        to: 'build-debug/bower-assets'
      }
    ]
