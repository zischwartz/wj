path = require 'path'
fs = require 'fs'
http = require 'http'
util = require 'util'
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
# through = require 'through'
# exec = require 'gulp-exec'
# _ = require 'underscore'

gulpFilter = require 'gulp-filter'

site =
  title: 'My Site'

# imageSite = 
#   title: "Images"

image_glob = ["content/**/**.jpg","content/**/**.png", "content/**/**.gif", "content/**/**.jpeg"]
content_glob = ["content/**/*.md", "content/**/**.jpg","content/**/**.png", "content/**/**.gif", "content/**/**.jpeg"]
md_glob = ["content/**/*.md"]

image_extnames = ('.'+s.split('.')[-1..] for s in image_glob)

# valid glob
# gulp.src(['./**/*.js','!./node_modules/**','!./libs/**'])


# Initial load of templates, get reloaded when one is edited
templates = {}
templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))
templates['images']  = handlebars.compile String(fs.readFileSync('templates/images.html'))

lr_server = lr()
gulp.task "listen", (next) ->
  gutil.log 'livereload listening...'
  lr_server.listen 35729, (err) ->
    return console.error(err) if err
    next()

# gulp.task "image", ->
#   watch {glob: ['content/**/*.jpg', 'content/**/*.png'], name:'img watch~'}, -> # verbose:true,
#     gulp.start 'generate_image'

# gulp.task "generate_image", ->
#     gulp.src(['content/**/*.jpg', 'content/**/*.png','content/**/images.html'])
#     .pipe ssg imageSite,
#       property: "meta"
#       prettyUrls: false
#     .pipe(es.map((file, cb) ->
#       # console.log util.inspect(file.meta, {depth: null, colors:true})
#       if path.extname(file.path) is '.html'
#         file.meta.isIndex = true # close enough
#         html = templates['images'] # render
#           page: file.meta
#           site: site
#           content: String(file.contents)
#         file.contents = new Buffer(html)
#       cb null, file
#     )).pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "template", ->
  watch {glob: md_glob, name:'template watch~'}, -> # verbose:true,
    templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))
    templates['images']  = handlebars.compile String(fs.readFileSync('templates/images.html'))
    gulp.start "generate"
    # gulp.start "generate_image"

gulp.task "html", ->
  watch {glob: md_glob, name:'md watch~'}, -> # verbose:true,
    gulp.start "generate"

# close!
# problem is when we call restore, we lose the processed md files, frontmatter and marked womp.
gulp.task "generate", ->
    md_filter = gulpFilter("**/**.md")
    gulp.src(content_glob)
    .pipe(md_filter)
    .pipe(frontmatter(property: "meta"))
    .pipe(marked())
    .pipe(md_filter.restore())
    .pipe(ssg(site, {property: "meta", prettyUrls: '.md'}))
    .pipe(gulp.dest("public/")) #.pipe(livereload(lr_server))
    .pipe(es.map((file, cb) ->
      if path.extname(file.path) not in image_extnames
        # console.log file.meta
        # console.log util.inspect file.meta
        # console.log String(file.contents)
        html = templates['base'] # render
          page: file.meta
          site: site
          content: String(file.contents)
        file.contents = new Buffer(html)
      cb null, file

    ))
    # .pipe(md_filter.restore())
    .pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "less", ->
  gulp.src("style/style.less").pipe(watch()).pipe(less())
  .pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "serve", ->
  http.createServer(
    ecstatic({ root: __dirname + '/public'  })
  ).listen(8745)

gulp.task 'default', ['html', 'serve', 'less', 'listen', 'template']
# gulp.task 'default', ['serve', 'less', 'listen', 'generate']






# gulp.task 'images', ->
#   gulp.src(image_globs)
#     .pipe(through(process_img))
#     .pipe(gulp.dest("output/"))
#     .pipe(exec('sips  <%= file.path %> --resampleWidth 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
#     # .pipe(exec('sips  <%= file.path %> --resampleHeight 200 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
#     # .pipe(exec('sips  <%= file.path %> -z 230 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
# ### Images
# process_img = (file, cb = false) ->
#   Cache.set_img file.relative, file.relative
#   this.queue(file) if this.queue # if we're using it as a gulp task through `through`
