path = require 'path'
fs = require 'fs'
http = require 'http'

es = require 'event-stream'
gulp = require 'gulp'
gutil = require 'gulp-util'
ssg = require 'gulp-ssg'
watch = require 'gulp-watch'
marked = require 'gulp-marked'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
frontmatter = require 'gulp-front-matter'
handlebars = require 'handlebars'
ecstatic = require 'ecstatic'
lr = require "tiny-lr"
livereload = require "gulp-livereload"

# less = require 'gulp-less'
# through = require 'through'
# exec = require 'gulp-exec'
# _ = require 'underscore'

site =
  title: 'My Site'

base_template = handlebars.compile String(fs.readFileSync('templates/base.html'))

lr_server = lr()
gulp.task "listen", (next) ->
  gutil.log 'livereload listening...'
  lr_server.listen 35729, (err) ->
    return console.error(err)  if err
    next()






gulp.task "html", ->
  watch {glob: 'content/**/*.md', verbose:true, name:'md watch~'}, ->
    gulp.src("content/**/*.md")
    .pipe(frontmatter(property: "meta"))
    .pipe(marked())
    .pipe(ssg(site,
      property: "meta"
    ))
    .pipe(es.map((file, cb) ->
      html = base_template(
        page: file.meta
        site: site
        content: String(file.contents)
      )
      file.contents = new Buffer(html)
      cb null, file
      return
    )).pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "serve", ->
  http.createServer(
    ecstatic({ root: __dirname + '/public'  })
  ).listen(8745)

gulp.task 'default', ['html', 'serve', 'listen']