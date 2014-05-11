path = require 'path'
fs = require 'fs'
http = require 'http'
util = require 'util'
es = require 'event-stream'
gulp = require 'gulp'
gutil = require 'gulp-util'
ssg = require 'gulp-ssg' # non standard version
watch = require 'gulp-watch'
marked = require 'gulp-marked'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
frontmatter = require 'gulp-front-matter'
handlebars = require 'handlebars'
ecstatic = require 'ecstatic'
lr = require "tiny-lr"
livereload = require "gulp-livereload"
gulpFilter = require 'gulp-filter'
# through = require 'through'
exec = require 'gulp-exec'
awspublish = require 'gulp-awspublish'
# _ = require 'underscore'
wj_helpers = require "./wj-helpers"
handlebars = wj_helpers.registerHbs handlebars  # registers our helpers

config = require './config'
# options  = fs.readFileSync('config.coffee'))


site =
  title: 'My Site'
  baseUrl: '/'

# gulp.src(['./**/*.js','!./node_modules/**','!./libs/**']) # e.g. 
image_glob = ["content/**/**.jpg","content/**/**.png", "content/**/**.gif", "content/**/**.jpeg"]
content_glob = ["content/**/*.md", "content/**/**.jpg","content/**/**.png", "content/**/**.gif", "content/**/**.jpeg"]
md_glob = ["content/**/*.md"]

image_extnames = ('.'+s.split('.')[-1..] for s in image_glob)

# Initial load of templates, get reloaded when one is edited
templates = {}
templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))

lr_server = lr()
gulp.task "listen", (next) ->
  gutil.log 'livereload listening...'
  lr_server.listen 35729, (err) ->
    return console.error(err) if err
    next()


gulp.task "template", ->
  watch {glob: 'templates/*.html', name:'template watch~'}, -> # verbose:true,
    templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))
    gulp.start "generate"

gulp.task "html", ->
  watch {glob: md_glob, name:'md watch~'}, -> # verbose:true,
    gulp.start "generate"

gulp.task "generate", ->
    md_filter = gulpFilter("**/**.md")
    gulp.src(content_glob)
    .pipe(md_filter)
    .pipe(frontmatter(property: "meta"))
    .pipe(marked())
    .pipe(es.map((file, cb) ->
      file.meta.isHtml = true # hacky
      cb null, file
      ))
    .pipe(md_filter.restore())
    .pipe(ssg(site, {property: "meta", prettyUrls: '.md'}))
    .pipe(es.map((file, cb) ->
      # console.log file.meta.name
      # console.log file.meta.sectionUrl
      if path.extname(file.path) not in image_extnames
        # console.log file.meta.name
        # console.log file.meta.section.name
        # console.log ( f.meta.name  for f in file.meta.section.files)
        # captions = file.meta?captions 
        html = templates['base'] # render
          page: file.meta
          site: site
          base: site.baseUrl
          content: String(file.contents)
          # console.log site.index.sections
          # console.log '----------------------------------------------------'
        file.contents = new Buffer(html)
      cb null, file

    ))
    .pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "less", ->
  gulp.src("assets/style.less").pipe(watch()).pipe(less())
  .pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "coffee", ->
  gulp.src("assets/script.coffee").pipe(watch()).pipe(coffee({bare: true}).on('error', gutil.log)) # .pipe(concat('script.js'))
  .pipe(gulp.dest("./public")).pipe(livereload(lr_server))

gulp.task "image_resize", ->
    gulp.src(image_glob)
        .pipe(gulp.dest("public/"))
        # .pipe(exec('sips  <%= file.path %> --resampleHeight 200 --out <%= options.label_size(file.path, "-small") %>', {label_size: wj_helpers.label_size, silent:true}))
        .pipe(exec('sips  <%= file.path %> --resampleWidth 300 --out <%= options.label_size(file.path, "-small") %>', {label_size: wj_helpers.label_size, silent:true}))

gulp.task "serve", ->
  http.createServer(
    ecstatic({ root: __dirname + '/public'  })
  ).listen(8888)

# Todo put these in a separate file
# publisher = awspublish.create({ key: '...',  secret: '...', bucket: '...' })
publisher = awspublish.create(config.aws)

gulp.task "publish", ->
  gulp.src('public/**/**')
  .pipe(publisher.publish())
  .pipe(awspublish.reporter())

gulp.task 'default', ['html', 'serve', 'less', 'coffee', 'listen', 'template']

# gulp.task 'images', ->
#   gulp.src(image_globs)
#     .pipe(through(process_img))
#     .pipe(gulp.dest("output/"))
#     .pipe(exec('sips  <%= file.path %> --resampleWidth 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
#     # .pipe(exec('sips  <%= file.path %> --resampleHeight 200 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
#     # .pipe(exec('sips  <%= file.path %> -z 230 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))


