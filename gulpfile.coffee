# Normal nodejs module loading of stuff we'll need
path = require 'path'
fs = require 'fs'
http = require 'http'
es = require 'event-stream'
gulp = require 'gulp'

# Our development server
ecstatic = require 'ecstatic'

# Not the standard version of `gulp-ssg`. See [github](https://github.com/zischwartz/gulp-ssg) & [PR](https://github.com/paulwib/gulp-ssg/pull/2)
site_generator = require 'gulp-ssg'

# ## Setup

# `gulp-load-plugins` loads all the modules in your `package.json` that begin with 'gulp-
# Converting  dashes to camelcase, e.g. 'gulp-front-matter' becomes `plugins.frontMatter`
# Link here about npm
gulpLoadPlugins = require 'gulp-load-plugins'
plugins = gulpLoadPlugins()

handlebars = require 'handlebars'
wj_helpers = require "./wj-helpers"
# Registers our handlebar helpers and partials from `wj-helpers.coffee`, for use in the templates (`.html` files). [More info about handlebars](http://handlebarsjs.com/)
handlebars = wj_helpers.registerHbs handlebars

try
  config = require './config'
catch err
  plugins.util.log plugins.util.colors.bgRed 'No config.coffee found'
  plugins.util.log plugins.util.colors.red 'You won\'t be able to upload to s3. '

# Our livereload server
lr = require "tiny-lr"
lr_server = lr()

# Configuration for the site generator.

# If your site will be at the root (http://something.com), you can leave it as `/`. If not (http://something.com/your_site/), set it to the path (`/yoursite/`)
site =
  title: 'Zach Schwartz'
  baseUrl: '/'

# Globs are a bit confusing. Strings, or arrays of strings, that specify what files match (and in this case, what files gulp should read and use)
image_glob = ["./content/**/**.jpg","./content/**/**.png", "./content/**/**.gif", "./content/**/**.jpeg"]
content_glob = ["./content/**/*.md", "./content/**/**.jpg","./content/**/**.png", "./content/**/**.gif", "./content/**/**.jpeg"]
md_glob = ["./content/**/*.md"]

# Example of a complex glob from the gulp docs
# ```
# gulp.src(['./**/*.js','!./node_modules/**','!./libs/**'])
# ```

# Grab the image file extensions we care about (`png`)
image_extnames = ('.'+s.split('.')[-1..] for s in image_glob)

# Initial load of templates, get reloaded when edited
# Add more templates here, like this. And below.
templates = {}
templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))

# ## Tasks
# Gulp tasks are functions that you name, and can be run from the command line

# Start up the livereload server
gulp.task "listen", (next) ->
  plugins.util.log 'livereload listening...'
  lr_server.listen 35729, (err) ->
    return console.error(err) if err
    next()

# Watch our templates files for changes
gulp.task "template", ->
  plugins.watch {glob: ['templates/*.html', 'templates/*.hbs'], name:'template watch~'}, -> # verbose:true,
    # update the base template
    templates['base']  = handlebars.compile String(fs.readFileSync('templates/base.html'))
    # and rebuild the site
    gulp.start "generate"

gulp.task "html", ->
  plugins.watch {glob: md_glob, name:'md watch~'}, ->
    # build the site
    gulp.start "generate"

# ## The Generate Task
# The big one. Take in content (`md` files and images), index, and output the site

# `gulp-filter` keeps things simple, by allowing us to temporarily filter some files out of the stream

gulp.task "generate", ->
    md_filter = plugins.filter("**/**.md")
    gulp.src(content_glob)
    .pipe(md_filter)
    # Grab that YAML frontmatter from our posts
    .pipe(plugins.frontMatter(property: "meta"))
    .pipe(plugins.marked())
    .pipe(es.map((file, cb) ->
      # hacky, but useful in templates later
      file.meta.isHtml = true
      # give it back to the gulp file stream
      cb null, file
      ))
    # use the filter's `restore()` method to restore the images our stream of files
    .pipe(md_filter.restore())
    # Index our nascent site
    .pipe(site_generator(site, {property: "meta", prettyUrls: '.md'}))
    # Take our markdown files and metadata (YAML, other files in the same directory), and mashes it into our template
    .pipe(es.map((file, cb) ->
      if path.extname(file.path) not in image_extnames
        # render, calls template(options)
        html = templates['base']
          page: file.meta
          site: site
          base: site.baseUrl
          content: String(file.contents)
        # put it in a buffer, because that's the way files work
        file.contents = new Buffer(html)
      # give it back to the gulp file stream
      cb null, file
    ))
    # actually write out the files, and reload the browser
    .pipe(gulp.dest("public/")).pipe(plugins.livereload(lr_server))


gulp.task "less", ->
  gulp.src("assets/*.less").pipe(plugins.watch()) # careful not to include the less subdir, use @import for those
  .pipe(plugins.less()).pipe(plugins.continuousConcat('style.css'))
  .pipe(gulp.dest("public/")).pipe(plugins.livereload(lr_server))

gulp.task "coffee", ->
  coffee_filter = plugins.filter("*.coffee")
  gulp.src(["assets/**.coffee", "assets/**.js"]).pipe(plugins.watch())
  .pipe(coffee_filter).pipe(plugins.coffee({bare: true}).on('error', plugins.util.log)).pipe(coffee_filter.restore())
  .pipe(plugins.continuousConcat('script.js')).pipe(gulp.dest("./public/")).pipe(plugins.livereload(lr_server))

gulp.task "image_resize", ->
    gulp.src(image_glob)
        .pipe(gulp.dest("public/"))
        .pipe(plugins.exec('sips  <%= file.path %> --resampleWidth 300 --out <%= options.label_size(file.path, "-small") %>', {label_size: wj_helpers.label_size, silent:true}))

gulp.task "serve", ->
  http.createServer(
    ecstatic({ root: __dirname + '/public'  })
  ).listen(6789)

gulp.task "publish", ->
  publisher = plugins.awspublish.create(config.aws) # this was outside, of the task XXX test this
  gulp.src('public/**/**')
  .pipe(publisher.publish())
  .pipe(plugins.awspublish.reporter())

# this defines what happens when we simply run `gulp` from the command line
gulp.task 'default', ['html', 'serve', 'less', 'coffee', 'listen', 'template', 'image_resize']

# Useful logging within the es.map() above
# ```
# console.log file.meta.name, file.meta.sectionUrl, file.path
# console.log file.meta.name, file.meta.section.name
# console.log ( f.meta.name  for f in file.meta.section.files)
# captions = file.meta?captions
# ```

# Alternate resize modes
# ```
# .pipe(exec('sips  <%= file.path %> --resampleWidth 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
# .pipe(exec('sips  <%= file.path %> --resampleHeight 200 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
# .pipe(exec('sips  <%= file.path %> -z 230 280 --out <%= options.label_size(file.path, "-small") %>', {label_size: label_size, silent:true}))
# ```
