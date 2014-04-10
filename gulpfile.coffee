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

# through = require 'through'
# exec = require 'gulp-exec'
# _ = require 'underscore'

util = require 'util'

site =
  title: 'My Site'

imageSite = 
  title: "Images"

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



gulp.task "image", ->
  watch {glob: ['content/**/*.jpg', 'content/**/*.png'], name:'img watch~'}, -> # verbose:true,
    gulp.start 'generate_image'

gulp.task "generate_image", ->
    gulp.src(['content/**/*.jpg', 'content/**/*.png','content/**/images.html'])
    .pipe(ssg(imageSite,
      property: "meta"
      prettyUrls: false
    ))
    .pipe(es.map((file, cb) ->
      # console.log util.inspect(file.meta, {depth: null, colors:true})
      if path.extname(file.path) is '.html'
        file.meta.isIndex = true # close enough
        # render
        html = templates['images']
          page: file.meta
          site: site
          content: String(file.contents)

        file.contents = new Buffer(html)
      cb null, file
      return
    )).pipe(gulp.dest("public/")).pipe(livereload(lr_server))


gulp.task "template", ->
  watch {glob: 'templates/**/*.html', name:'template watch~'}, -> # verbose:true,
    templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))
    templates['images']  = handlebars.compile String(fs.readFileSync('templates/images.html'))
    gulp.start "generate"
    gulp.start "generate_image"

gulp.task "html", ->
  watch {glob: 'content/**/*.md', name:'md watch~'}, -> # verbose:true,
    gulp.start "generate"

gulp.task "generate", ->  
    gulp.src("content/**/*.md")
    .pipe(frontmatter(property: "meta"))
    .pipe(marked())
    .pipe(ssg(site,
      property: "meta"
    ))
    .pipe(es.map((file, cb) ->
      # util.inspect file.meta
      html = templates['base'](
        page: file.meta
        site: site
        content: String(file.contents)
      )
      file.contents = new Buffer(html)
      cb null, file
      return
    )).pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "less", ->
  gulp.src("style/style.less").pipe(watch()).pipe(less())
  .pipe(gulp.dest("public/")).pipe(livereload(lr_server))

gulp.task "serve", ->
  http.createServer(
    ecstatic({ root: __dirname + '/public'  })
  ).listen(8745)

gulp.task 'default', ['html', 'serve', 'less', 'listen', 'template', 'image']



# image_globs= ["input/**/**.jpg","input/**/**.png", "input/**/**.gif", "input/**/**.jpeg"]
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
